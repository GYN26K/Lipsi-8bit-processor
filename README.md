# LIPSI 8-bit Processor — Verilog Implementation
 
> **School of Electrical and Computer Sciences**  
> Indian Institute of Technology, Bhubaneswar  
> **Author:** Yashmith Gali (24EC01019)  
> **Supervisor:** Dr. Srinivas Boppu  
> **Branch:** ECE | **Date:** 16th May 2026
 
---
 
## Overview
 
This repository contains a complete Verilog implementation of the **Lipsi processor** — a compact 8-bit accumulator-based microcontroller originally proposed by Martin Schoeberl in *"Lipsi: Probably the Smallest Processor in the World"* (ARCS 2018).
 
Lipsi is designed for FPGA deployment where minimal hardware resource usage is paramount. The entire processor — including instructions and data — fits inside a single 512-byte block RAM, making it ideal for embedded peripheral control and finite state machine logic inside a larger system-on-chip.
 
This implementation extends the baseline architecture with:
- A complete modular Verilog hierarchy (14 modules)
- A 4-digit seven-segment display driver for real-time output
- A pre-loaded Fibonacci number computation program
- Clock divider for human-visible FPGA operation
---
 
## Architecture
 
| Feature | Detail |
|---|---|
| Data width | 8-bit |
| Architecture | Accumulator-based (von Neumann) |
| Memory | 512 bytes unified block RAM (instructions + data) |
| Register file | 16 bytes (r0–r15) at lowest data addresses |
| Control unit | 12-state Moore FSM (S0–S11) |
| Instruction set | 12 instructions, 1–2 bytes each |
| Execution model | Multi-cycle sequential (non-pipelined) |
| ALU operations | 12 (ADD, SUB, ADC, SBB, AND, OR, XOR, LD, LSL, LSR, ASL, ASR) |
| Target | Xilinx FPGA (Vivado) |
 
---
 
## Repository Structure
 
```
Lipsi-8bit-processor/
├── Design Sources/
│   ├── alu.v               # 8-bit combinational ALU (12 operations)
│   ├── accumulator.v       # 8-bit accumulator register
│   ├── pc.v                # 8-bit program counter
│   ├── add_1.v             # PC+1 incrementer
│   ├── memory.v            # 512-byte unified block RAM
│   ├── ctrl_unit.v         # 12-state Moore FSM control unit
│   ├── mux2x1.v            # 8-bit 2-to-1 multiplexer
│   ├── mux4x1.v            # 8-bit 4-to-1 multiplexer
│   ├── cpu.v               # Datapath top-level
│   ├── clk_div.v           # 100 MHz → 1 Hz clock divider
│   ├── bin_to_bcd.v        # Binary to BCD converter
│   ├── display_mux.v       # 4-digit 7-segment display mux
│   ├── seg7_decoder.v      # 7-segment encoding (0–9)
│   └── main_module.v       # FPGA top-level wrapper
├── Constraint Files/
│   └── imports/new/        # XDC pin constraint files
└── README.md
```
 
---
 
## Memory Organisation
 
The 512-byte block RAM is split at the midpoint by the MSB of the 9-bit address:
 
| Region | Address Range | Size | Purpose |
|---|---|---|---|
| Data / Register | `0x000 – 0x0FF` | 256 bytes | r0–r15 register file + general data |
| Instruction | `0x100 – 0x1FF` | 256 bytes | Program code |
 
The lowest 16 bytes of the data region (`mem[0]`–`mem[15]`) act as the software register file, directly addressable via the 4-bit register field in each instruction.
 
---
 
## Instruction Set
 
| Encoding | Mnemonic | Operation |
|---|---|---|
| `0fff rrrr` | `f rx` | `A = A f m[r]` — ALU register |
| `1000 rrrr` | `st rx` | `m[r] = A` — Store |
| `1001 rrrr` | `brl rx` | `m[r] = PC; PC = A` — Branch and Link |
| `1010 rrrr` | `ldind` | `A = m[m[r]]` — Load Indirect |
| `1011 rrrr` | `stind` | `m[m[r]] = A` — Store Indirect |
| `1100 -fff nnnn nnnn` | `fi n` | `A = A f n` — ALU Immediate |
| `1101 --00 aaaa aaaa` | `br` | `PC = a` — Unconditional Branch |
| `1101 --10 aaaa aaaa` | `brz` | `if A==0: PC = a` — Branch if Zero |
| `1101 --11 aaaa aaaa` | `brnz` | `if A!=0: PC = a` — Branch if Not Zero |
| `1110 --ff` | `sh` | `A = shift(A)` — ALU Shift |
| `1111 aaaa` | `io` | `IO = A; A = IO` — I/O |
| `1111 1111` | `exit` | Halt processor |
 
---
 
## FSM Control Unit
 
The control unit (`ctrl_unit.v`) is a **Moore FSM** with 12 states:
 
| State | Role | Cycles |
|---|---|---|
| S0 | Instruction Decode | — |
| S1 | ALU Register Execute | 2 total |
| S2 | Store Complete | 2 total |
| S3 | Branch and Link | 2 total |
| S4–S5 | Indirect Load (2-phase) | 3 total |
| S6–S7 | Indirect Store (2-phase) | 3 total |
| S8 | Immediate ALU Execute | 2 total |
| S9 | Branch Taken | 2 total |
| S10 | Branch Not Taken | 2 total |
| S11 | Halt (absorbing) | ∞ |
 
The shift instruction (`1110`) completes entirely within S0 (single-cycle). Branch conditions (BRZ/BRNZ) are evaluated in S0 using the live accumulator value.
 
---
 
## Fibonacci Program
 
The processor is pre-loaded with a Fibonacci number computation. The N-th Fibonacci number is computed iteratively and displayed on the four-digit seven-segment display.
 
**Register usage:**
 
| Register | Purpose | Init |
|---|---|---|
| r0 | F_{n-1} (previous) | 0 |
| r1 | F_n (current) | 1 |
| r2 | Temporary (F_{n+1}) | 0 |
| r3 | Loop counter | N |
| r4 | Constant 1 | 1 |
 
**Algorithm:**
```
F0 = 0, F1 = 1
repeat N times:
    temp = F0 + F1
    F0   = F1
    F1   = temp
result displayed in A
```
 
---
 
## How to Run
 
### Prerequisites
- Xilinx Vivado (2020.x or later)
- Basys 3 / Nexys A7 or compatible Xilinx FPGA board
### Steps
 
1. **Clone the repository**
   ```bash
   git clone https://github.com/GYN26K/Lipsi-8bit-processor.git
   cd Lipsi-8bit-processor
   ```
 
2. **Open Vivado and create a new project**
   - Add all `.v` files from `Design Sources/` as design sources
   - Add the constraint file from `Constraint Files/imports/new/`
   - Set `main_module` as the top-level module
3. **Set the value of N**  
   In `memory.v`, the parameter `N` is the input to the Fibonacci program.  
   Connect it to switches on your FPGA board or set a fixed 4-bit value.
4. **Synthesise, implement, and generate bitstream**
   ```
   Flow Navigator → Run Synthesis → Run Implementation → Generate Bitstream
   ```
 
5. **Program the FPGA**  
   Connect your board and use *Open Hardware Manager → Program Device*.
6. **Observe the result**  
   The N-th Fibonacci number will appear on the four-digit seven-segment display.
---
 
## Module Descriptions
 
| Module | Description |
|---|---|
| `ctrl_unit` | 12-state Moore FSM — decodes all instructions and drives every control signal |
| `alu` | Combinational 8-bit ALU: 12 operations including shifts and carry arithmetic |
| `accumulator` | 8-bit synchronous register with enable and reset |
| `pc` | 8-bit program counter with synchronous enable and reset |
| `add_1` | Combinational PC+1 incrementer |
| `memory` | 512-byte unified block RAM; Fibonacci pre-loaded on reset |
| `mux2x1` | 8-bit 2-to-1 mux for write-address and write-data selection |
| `mux4x1` | 8-bit 4-to-1 mux for PC input source selection |
| `cpu` | Datapath top-level — instantiates all processor modules |
| `clk_div` | Divides 100 MHz to 1 Hz for visible CPU operation |
| `bin_to_bcd` | Converts 8-bit result to BCD digits |
| `display_mux` | Multiplexed 4-digit seven-segment driver (~1.5 kHz refresh) |
| `seg7_decoder` | Seven-segment encoding for digits 0–9 |
| `main_module` | FPGA top-level wrapper |
 
---
 
## References
 
1. Martin Schoeberl, *"Lipsi: Probably the Smallest Processor in the World"*, Architecture of Computing Systems (ARCS), Springer, 2018.
2. Original Lipsi reference implementation (Chisel): https://github.com/schoeberl/lipsi
3. IEEE Std 1364-2005 — Verilog HDL Reference Manual
4. Xilinx UG473 — 7 Series FPGAs Block RAM Resources
---
 
## License
 
This project is submitted as part of the ECE curriculum at IIT Bhubaneswar. For academic use only.
