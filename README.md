# Writing an OS in Swift

A minimal aarch64 Embedded Swift kernel.

## Goals

My goal is to create a simple and modern starting template with minimal friction.

I want to use this as a starting point for a series of blog posts on OS development with Swift.
## Roadmap
1. Enable the MMU
2. Timers
3. Allocators
4. Integrate Swift concurrency
5. Device tree?

## What I got so far

I've created a `swift-embedded-arch` companion project to compensate for the lack of inline assembly in Swift.

Using it, I can create this minimal kernel fully in Swift.
- The `_start` function sets up the stack and jumps into Swift.
- The `kmain` function prints `Hello, world!\n` via UART.
## How to build
```bash
swift build -c release --triple aarch64-none-none-elf --toolset toolset.json --build-system native
