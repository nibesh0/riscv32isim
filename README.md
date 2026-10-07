# RV32I Verilog CPU and Matrix-Multiplication Benchmark

This repository contains a runnable single-cycle RV32I processor written in
Verilog. It executes bare-metal C compiled with `-march=rv32i -mabi=ilp32` and
does not contain an M-extension multiplier. The benchmark has both an explicit
shift/add multiplier and a compiler/libgcc software-multiply baseline; the ELF
image converter rejects any M-extension opcode before simulation.

## Layout

- `rtl/` — ALU, RV32I decoder/control, register file, immediate generator, CPU,
  instruction memory, and byte-addressable data memory.
- `tb/` — ALU, control, register-file, memory, and parameterized CPU testbenches.
- `software/` — startup assembly, linker script, C fixtures, signed shift/add
  multiply, baseline/optimized kernels, and all six loop organizations.
- `programs/` — hand-assembled smoke programs, a hand-assembled 4×4 matmul,
  and expected result images.
- `scripts/` — deterministic program generation, RV32I C build/image conversion,
  simulation, and benchmark orchestration.
- `results/` — measured CSV, toolchain metadata, and image-size reports.

## Install

```sh
sudo apt-get install iverilog gcc-riscv64-unknown-elf binutils-riscv64-unknown-elf
```

## CPU/memory details

The CPU supports RV32I ALU/register operations, immediate ALU operations,
loads/stores for byte/halfword/word forms, all six conditional branches,
JAL/JALR, LUI, AUIPC, FENCE as an in-order no-op, and `ebreak` completion.
Misaligned/out-of-range accesses and unsupported encodings raise a simulation
trap. Data memory uses `$readmemh`; the C image converter produces separate
word-oriented instruction/data hex images and poisons NOLOAD storage until the
startup code clears it.

Software writes timer markers to `0xfffffff0` and completion/exit status to
`0xfffffffc`. The CPU testbench observes those markers, counts cycles, checks
the result image, and prints `PASS` or fails the simulation.
