.section .text.init
.globl _start
.type _start, @function
_start:
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop
    lui sp, %hi(_stack_top)
    addi sp, sp, %lo(_stack_top)
    la t0, _bss_start
    la t1, _bss_end
1:  bgeu t0, t1, 2f
    sw zero, 0(t0)
    addi t0, t0, 4
    j 1b
2:
    la t0, _matrix_start
    la t1, _matrix_end
4:  bgeu t0, t1, 5f
    sw zero, 0(t0)
    addi t0, t0, 4
    j 4b
5:
    call main
    li t0, -4
    sw a0, 0(t0)
    ebreak
6:  j 6b
.size _start, .-_start
