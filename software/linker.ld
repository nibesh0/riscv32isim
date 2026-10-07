OUTPUT_ARCH(riscv)
ENTRY(_start)
MEMORY
{
    CODE (rx) : ORIGIN = 0x00000000, LENGTH = 0x4000
    DATA (rw) : ORIGIN = 0x00004000, LENGTH = 0x4000
    SIGNATURE (rw) : ORIGIN = 0x8000, LENGTH = 0x1000
    MATRIX (rw) : ORIGIN = 0x9000, LENGTH = 0x3000
    STACK (rw) : ORIGIN = 0xc000, LENGTH = 0x4000
}
SECTIONS
{
    .text : { KEEP(*(.text.init)) *(.text .text.*) } > CODE
    .rodata : { *(.rodata .rodata.*) } > DATA
    .data : { *(.data .data.*) *(.sdata .sdata.*) } > DATA
    .bss (NOLOAD) : {
        . = ALIGN(4);
        _bss_start = .;
        *(.bss .bss.*) *(.sbss .sbss.*) *(COMMON)
        . = ALIGN(4);
        _bss_end = .;
    } > DATA
    .signature (NOLOAD) : { KEEP(*(.signature)) } > SIGNATURE
    .matrix_results (NOLOAD) : {
        . = ALIGN(4);
        _matrix_start = .;
        KEEP(*(.matrix_results))
        . = ALIGN(4);
        _matrix_end = .;
    } > MATRIX
    __global_pointer$ = ORIGIN(DATA) + 0x800;
    _stack_top = ORIGIN(STACK) + LENGTH(STACK);
    /DISCARD/ : { *(.comment) *(.eh_frame*) }
}
