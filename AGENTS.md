# QWEN.md

This file provides guidance to Qwen Code when working with code in this repository.

## Project Overview

A minimal **aarch64 Embedded Swift kernel**. It is intended as a simple, modern starting
template with minimal friction, and doubles as the starting point for a series of blog
posts on OS development with Swift.

- The kernel is written entirely in Swift using the **Embedded** mode and a companion
  project, `swift-embedded-arch`, which supplies the architectural primitives normally
  provided by inline assembly (stack setup, `branch/link`, halt, volatile MMIO).
- `_start` (in `Sources/boot.swift`, placed in section `.text.boot`) sets up the stack and
  jumps into Swift via `kmain`.
- `kmain` currently prints `Hello, world!\n` over the PL011 UART at `0x0900_0000`.

Key architectural pieces:
- **`Sources/boot.swift`** — the only source file. Defines the UART register
  (`VolatileMappedRegister<UInt8>`), `_start`, `kmain`, and helper `uart` writers. It
  declares an external `__stack_top` symbol (`@_extern(c, "__stack_top")`) that the linker
  script provides.
- **`linker.ld`** — custom linker script. Entry `_start`, load address `0x8000` (QEMU `virt`),
  a 128 KiB stack (`.stack`), `.vectors` kept in `.text`, BSS alignment at 16, and discards
  Swift metadata/debug sections.
- **`toolset.json`** — Swift **native build system** toolset. Compiles with
  `-no-allocations`, `-function-sections`, disabled stack protector, links `-nostdlib -static`
  with lld using `linker.ld`, and configures a QEMU `aarch64 virt` debugger.
- **`Package.swift`** — SwiftPM manifest. Swift tools version **6.4**, Swift language mode
  **v6**, C standard **c2x**. Depends on the local path
  `swift-embedded-arch` (`/Users/lancelot/Developer/Embedded/swift-embedded-arch`) via the
  `EmbeddedArch` product.
- **`.swift-version`** — pins the toolchain to a `main` snapshot.

## Roadmap

The author's stated next steps (useful for understanding where the project is heading):
1. Enable the MMU
2. Timers
3. Allocators
4. Integrate Swift concurrency
5. Device tree?

## Building and Running

Build (from the repository root):

```bash
swift build -c release \
  --triple aarch64-none-none-elf \
  --toolset toolset.json \
  --build-system native
```

This produces a bare-metal ELF. Run it under QEMU (matching `toolset.json`'s debugger
config) with:

```bash
qemu-system-aarch64 -machine virt -cpu cortex-a57 -nographic -kernel <kernel.elf>
```

Notes:
- The `--build-system native` and `--toolset toolset.json` flags are required; a plain
  `swift build` will not produce a bare-metal ELF.
- The `swift-embedded-arch` dependency is currently referenced by **local path**. There is a
  commented-out `package(url:)` line in `Package.swift` for the remote GitHub repository —
  swap to it before committing if the local path should not be hardcoded.

There are no tests in this project (it is a bare-metal kernel).

## Development Conventions

- **Strict memory safety**: the manifest enables `.strictMemorySafety()`. All raw/unsafe
  operations must be inside explicit `unsafe` blocks (e.g. the `VolatileMappedRegister`
  initializers in `boot.swift`).
- **Warnings are errors**: `.treatAllWarnings(as: .error)` is set — keep builds warning-free.
- **Experimental / upcoming Swift features** are enabled in `Package.swift`
  (`Embedded`, `Extern`, `Lifetimes`, `SafeInteropWrappers`, `Volatile`,
  `InternalImportsByDefault`, `MemberImportVisibility`, `ExistentialAny`, etc.). Rely on them
  only as used by the kernel; do not casually remove or change them.
- Use the **`@c` / `@section`** attributes and `@_extern` / `@_transparent` /
  `@usableFromInline` interop annotations to bridge to linker-provided symbols and the C ABI.
- Keep the kernel **allocation-free**: `-no-allocations` is a compiler flag, so avoid
  dynamic allocation in kernel code.