import _Volatile
import EmbeddedArch

var uart: VolatileMappedRegister<UInt8> {
	unsafe VolatileMappedRegister<UInt8>(unsafeBitPattern: 0x0900_0000)
}

@c @section(".text.boot")
func _start() -> Never {
	set_sp(topOfStack)
	bl(kmain)
	hang()
}

@c @inline(never)
func kmain() {
	uart("Hello, world!\n")
}

func uart(_ c: UInt8) {
	uart.store(c)
}

func uart(_ s: StaticString) {
	s.withUTF8Buffer { buffer in
		for unsafe c in unsafe buffer {
			uart.store(c)
		}
	}
}

@_extern(c, "__stack_top") @usableFromInline
nonisolated(unsafe) var __stack_top: UInt8

@_transparent
var topOfStack: UInt {
	unsafe withUnsafePointer(to: &__stack_top, UInt.init(bitPattern:))
}
