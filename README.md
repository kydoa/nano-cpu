# nano-cpu

[![HDL](https://img.shields.io/badge/HDL-SystemVerilog-0b6fa4)](nanoCPU.sv)
[![Simulator](https://img.shields.io/badge/Simulator-ModelSim%20SE--64-1f6feb)](sim.do)
[![Status](https://img.shields.io/badge/Simulation-Passing%20(locally)-2ea043)](transcript)

A compact 16-bit CPU written in SystemVerilog, created as a final project for a Fundamentals of Digital Systems course.
The design includes a small register bank, an ALU, and a finite-state control unit that executes a minimal instruction set against a 256x16 memory.

## Table of Contents

- [What This Project Does](#what-this-project-does)
- [Why This Project Is Useful](#why-this-project-is-useful)
- [Architecture Overview](#architecture-overview)
- [Instruction Set](#instruction-set)
- [Getting Started](#getting-started)
- [Usage Examples](#usage-examples)
- [Project Structure](#project-structure)
- [Where To Get Help](#where-to-get-help)
- [Maintainers and Contributions](#maintainers-and-contributions)

## What This Project Does

`nano-cpu` implements a simple processor core and a simulation testbench:

- `NanoCPU` in [nanoCPU.sv](nanoCPU.sv): CPU datapath + control FSM.
- `nanoCPU_TB` in [nanoTB.sv](nanoTB.sv): memory-backed testbench programs.
- `sim.do` and `wave.do`: ModelSim automation for compile, simulate, and waveform setup.

Main characteristics:

- 16-bit datapath.
- 4 general-purpose 16-bit registers (`R0`-`R3`).
- 8-bit address space (`0..255`) with 16-bit memory words.
- Memory-mapped instruction/data fetch through a shared bus (`dataR`, `dataW`, `address`, `we`, `ce`).

## Why This Project Is Useful

This repository is useful if you want to:

- Study a complete, readable CPU implementation in idiomatic SystemVerilog.
- Learn how datapath and control FSM interact in a multi-cycle processor.
- Experiment with custom assembly-like programs directly in a testbench memory image.
- Reuse a minimal simulation workflow (`.do` files) for teaching, demos, or architecture labs.

## Architecture Overview

The CPU is organized into two main blocks:

- Datapath:
	- Register bank (4x `Reg16bit` registers)
	- Instruction Register (IR)
	- Program Counter (PC)
	- ALU (ADD, SUB, XOR, LESS, INC, DEC and write pass-through)
- Control:
	- FSM states: `IDLE`, `FETCH`, `EXEC`, `LD`, `WRITE`, `ALU`, `JMP`, `BRANCH`, `fim`
	- Decoder from `IR[15:12]` to instruction type

Execution model:

1. Fetch instruction from `PC`
2. Decode opcode
3. Execute one of load/store/branch/jump/ALU paths
4. Update registers and/or memory
5. Advance or redirect `PC`

## Instruction Set

The opcode is `IR[15:12]`.

| Opcode | Mnemonic | Behavior |
| --- | --- | --- |
| `0x0` | `READ` | Load register from memory |
| `0x1` | `WRITE` | Store register to memory |
| `0x2` | `JMP` | Unconditional jump |
| `0x3` | `BRANCH` | Conditional branch (uses `RS2[0]`) |
| `0x4` | `XOR` | `RS1 ^ RS2` |
| `0x5` | `SUB` | `RS1 - RS2` |
| `0x6` | `ADD` | `RS1 + RS2` |
| `0x7` | `LESS` | Signed compare: result is `1` if `RS1 < RS2`, else `0` |
| `0x8` | `INC` | `RS1 + 1` |
| `0x9` | `DEC` | `RS1 - 1` |
| other | `END` | Stop (`fim` state) |

## Getting Started

### Prerequisites

- Siemens EDA ModelSim/Questa with `vlib`, `vmap`, `vlog`, and `vsim` in `PATH`
- Linux/macOS shell (or equivalent terminal on Windows)

### Run the simulation

From repository root:

```bash
vsim -do sim.do
```

What this runs:

1. Recreates `work` library
2. Compiles [nanoCPU.sv](nanoCPU.sv) and [nanoTB.sv](nanoTB.sv)
3. Starts `work.nanoCPU_TB`
4. Loads waveform configuration from [wave.do](wave.do)
5. Simulates `820 ns`

The latest checked-in transcript in [transcript](transcript) shows successful compile/sim runs (0 errors, 0 warnings in listed runs).

## Usage Examples

### 1) Use the default testbench program

The active memory image in [nanoTB.sv](nanoTB.sv) currently demonstrates a division-style routine that writes quotient and remainder to memory locations `32` and `33`.

After running simulation, inspect in waveform:

- `/nanoCPU_TB/memory[32]` (quotient)
- `/nanoCPU_TB/memory[33]` (remainder)

### 2) Swap to an alternative sample program

The testbench already includes additional program images (`memory1`, `memory2`).
To try one, assign the active `memory` variable to the desired image in [nanoTB.sv](nanoTB.sv), rerun:

```bash
vsim -do sim.do
```

## Project Structure

```text
.
├── nanoCPU.sv       # CPU core (datapath + control)
├── nanoTB.sv        # Testbench and program/data memory images
├── sim.do           # ModelSim compile/run script
├── wave.do          # Waveform setup
├── transcript       # Example simulation transcript
└── modelsim.ini     # ModelSim library/config mapping
```

## Where To Get Help

- Start from [nanoCPU.sv](nanoCPU.sv) for core behavior and [nanoTB.sv](nanoTB.sv) for executable program examples.
- Use [sim.do](sim.do) as the reference simulation entry point.

## Maintainers

Maintainer:

- [@kydoa](https://github.com/kydoa)
