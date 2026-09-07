# DESIGNING A RISC PROCESSOR

![Verilog](https://img.shields.io/badge/Language-Verilog_HDL-blue.svg)
![Tools](https://img.shields.io/badge/Tools-Xilinx_Vivado-orange.svg)
![Target](https://img.shields.io/badge/Architecture-RISC-green.svg)

## 1. Introduction

**Reduced Instruction Set Computer (RISC)** is a computer architecture designed to
keep each individual instruction to the computer simple. By bridging the gap between
theoretical hardware architectures and practical Electronic Design Automation (EDA)
workflows, this project demonstrates a complete digital design cycle emphasizing
modularity, structural integrity, and robust control-flow routing. In alignment with modern digital engineering paradigms, this project realizes an upgraded 9-bit custom RISC
processor modeled in Verilog HDL, building upon foundational microarchitectural design
and synchronous hardware development methodologies.

---

## 2. Architecture Overview

### 2.1 Hierarchy Design
The hierarchy design is divided into 7 modules to ensure readability, testing, and debugging convenience.

![cpu hierarchy](Picture/hierarchy.png)

### 2.2 Signal Specifications

| Signal Name | Width | Description |
| :--- | :---: | :--- |
| `clk` / `rst` | 1-bit | Global clock and active-HIGH synchronous reset. |
| `halt` | 1-bit | Controller output signaling program execution halt. |
| `rd` / `wr` | 1-bit | Memory read and write enable control flags. |
| `ld_ir`, `ld_pc`, `ld_ac` | 1-bit | Load enable signals for IR, PC, and AC. |
| `inc_pc` | 1-bit | Program Counter increment control signal. |
| `sel` | 1-bit | Address MUX select line (1: PC address, 0: Operand address). |
| `data_e` | 1-bit | Tri-state buffer enable driving AC data onto `data_bus` during STO. |
| `zero` | 1-bit | Asynchronous ALU zero flag for SKZ instruction evaluation. |
| `old_overflow` | 1-bit | Previous signed arithmetic overflow for 9-bit operations. |
| `new_overflow` | 1-bit | Temporary signed arithmetic overflow for 9-bit operations. |
| `ac_out` | 9-bit | Current 9-bit Accumulator value routed to ALU input A. |
| `alu_out` | 9-bit | Processed 9-bit ALU output routed to Accumulator input. |
| `opcode` | 4-bit | Operation code controlling ALU function and Controller FSM transitions. |
| `operand` | 5-bit | Target data operand address extracted from lower IR bits. |
| `pc_addr` | 5-bit | Current program execution address from Program Counter. |
| `addr` | 5-bit | Target memory address selected by Address MUX (`pc_addr`/`operand`). |
| `data_bus` | 9-bit | Primary bidirectional data bus for memory read/write. |

### 2.3 Opcode Table

| Opcode | Instruction | Description |
| :---: | :---: | :--- |
| `0000` | **HLT** | Halt processor execution |
| `0001` | **SKZ** | Skip next instruction if zero flag is asserted |
| `0010` | **ADD** | Unsigned addition |
| `0011` | **AND** | Bitwise AND operation |
| `0100` | **XOR** | Bitwise XOR operation |
| `0101` | **LDA** | Load data from memory to Accumulator |
| `0110` | **STO** | Store Accumulator value to memory |
| `0111` | **JMP** | Jump to target address |
| `1000` | **SUB** | Subtraction operation |
| `1001` | **OR**  | Bitwise OR operation |
| `1010` | **MUL** | Unsigned multiplication |
| `1011` | **___** | Mini Floating-Point Multiplier |
| `1100` | **SHL** | Shift left operation |
| `1101` | **SHR** | Shift right operation |
| `1110` | **NOT** | Invert the Accumulator value |
| `1111` | **SKO** | Skip next instruction if overflow flag is asserted |

### 2.4 System Workflow

The processor executes each instruction through an 8-state FSM sequence managed by the Controller over 8 consecutive clock cycles:

1. **`INST_ADDR` (Instruction Address):** Controller sets `sel = 1`, routing `pc_addr` through the Address MUX to Memory's address.

2. **`INST_FETCH` (Instruction Fetch):** Controller asserts `rd = 1` to read instruction data from Memory onto `data_bus`.
3. **`INST_LOAD` (Instruction Load):** Controller asserts `ld_ir = 1` to latch instruction data into the Instruction Register (IR).
4. **`IDLE` (Decode & Stabilize):** IR exposes `opcode` to Controller/ALU and `operand` address to Address MUX.
5. **`OP_ADDR` (Operand Address):** Controller sets `sel = 0` to route operand address to Memory, while asserting `inc_pc = 1` to advance PC.
6. **`OP_FETCH` (Operand Fetch):** Controller asserts `rd = 1` for memory-referencing instructions to fetch data onto `data_bus` (ALU input `inB`).
7. **`ALU_OP` (ALU Operation):** ALU processes `inA` (Accumulator) and `inB` (Memory):
   - **`SKZ` / `SKO`:** Asserts `inc_pc = 1` if skip condition is satisfied.
   - **`JMP`:** Asserts `ld_pc = 1` to load target jump address into PC.
   - **`STO`:** Asserts `data_e = 1` to drive Accumulator data onto `data_bus`.
8. **`STORE` (Writeback):** Controller asserts `ld_ac = 1` to update Accumulator, or `wr = 1` during `STO` to write back to Memory.

Upon completing **`STORE`**, execution cycles back to **`INST_ADDR`** unless a `HLT` instruction halts the processor.

---

The table below details the control signal outputs generated by the Controller FSM across the 8 execution phases:

| Control Signal | INST_ADDR | INST_FETCH | INST_LOAD | IDLE | OP_ADDR | OP_FETCH | ALU_OP | STORE | Description / Activation Condition |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| `sel` | 1 | 1 | 1 | 1 | 0 | 0 | 0 | 0 | **1**: Selects Program Counter address (`pc_addr`), **0**: Selects operand address (`operand`). |
| `rd` | 0 | 1 | 1 | 1 | 0 | ALUOP | ALUOP | ALUOP | Asserts `1` to read memory during instruction fetch or operand fetch. |
| `ld_ir` | 0 | 0 | 1 | 1 | 0 | 0 | 0 | 0 | Latches fetched instruction from `data_bus` into Instruction Register (IR). |
| `halt` | 0 | 0 | 0 | 0 | HALT | 0 | 0 | 0 | Asserts `1` to halt processor execution upon decoding `HLT` (`0000`). |
| `inc_pc` | 0 | 0 | 0 | 0 | 1 | 0 | SKIP | 0 | Increments PC by 1 at `OP_ADDR`; asserts again at `ALU_OP` if skip condition is met. |
| `ld_ac` | 0 | 0 | 0 | 0 | 0 | 0 | 0 | ALUOP | Latches ALU computation result into Accumulator during `STORE` phase. |
| `ld_pc` | 0 | 0 | 0 | 0 | 0 | 0 | JMP | JMP | Loads target jump address into PC upon decoding `JMP` (`0111`). |
| `wr` | 0 | 0 | 0 | 0 | 0 | 0 | 0 | STO | Asserts `1` during `STORE` phase to write Accumulator data into Memory. |
| `data_e` | 0 | 0 | 0 | 0 | 0 | 0 | STO | STO | Enables tri-state buffer to drive Accumulator data onto `data_bus` for `STO`. |

---

#### Control Condition Definitions (Legend)

* **`ALUOP`**: Asserts `1` for instructions performing arithmetic/logic operations or requiring Accumulator updates (`ADD`, `SUB`, `AND`, `OR`, `XOR`, `MUL`, `FPU_MUL`, `LDA`, `SHL`, `SHR`, `NOT`).
* **`HALT`**: Asserts `1` when Opcode = `0000` (`HLT`).
* **`JMP`**: Asserts `1` when Opcode = `0111` (`JMP`).
* **`STO`**: Asserts `1` when Opcode = `0110` (`STO`).
* **`SKIP`**: Asserts `1` when branch conditions are evaluated as true:
  * Opcode = `0001` (`SKZ`) **AND** `zero == 1`
  * Opcode = `1111` (`SKO`) **AND** `overflow == 1`

---

## 3. Code Tree

```text
designing-risc-cpu/
├── RTL/
│   ├── ac.v                    
│   ├── addr_mux.v
│   ├── alu.v
│   ├── controller.v
│   ├── cpu.v
│   ├── ir.v
│   ├── memory.v
│   └── pc.v
├── Testbench/                             
│   ├── ac_tb.v                    
│   ├── addr_mux_tb.v
│   ├── alu_tb.v
│   ├── controller_tb.v
│   ├── cpu_tb.v
│   ├── ir_tb.v
│   ├── memory_tb.v
│   └── pc_tb.v
├── docs/
├── .gitignore                  
└── README.md
```

---

## 4. Verification Workflow

---

## 5. Synthesis Results

| Performance Criteria | Synthesized Value |
| :---: | :---: |
| Look-up Tables (LUTs) | 135 LUTs |
| Flip-Flops | 41 FFs |
| Distributed Memory (LUTRAM) | 9 LUTRAMS |
| Input / Output Pins (IO) | 3 Pins |
| Worst Negative Slack (WNS) | 0.472 ns |
| Worst Hold Slack (WHS) | 0.132 ns |
| Total Power | 0.081 W |
| Junction Temperature | 25.9 °C |

---

## 6. Demo instruction

This project includes unit testbenches for individual RTL modules and a top-level CPU testbench running all program testcases (`cpu_testcases.v`). Test results are automatically verified via terminal and signals can be tracked from waveform.

### Prerequisites

* **AMD/Xilinx Vivado**
* **Git**
---

### Step 1: Clone the Repository

Open your terminal or command prompt and clone the repository:

```bash
git clone [https://github.com/pmhuy2302/designing-risc-cpu.git](https://github.com/pmhuy2302/designing-risc-cpu.git)
cd designing-risc-cpu
```

---

### Step 2: Set Up the Vivado Project

1. Launch **Vivado**.
2. Click **Create Project** -> Name your project and click **Next**.
3. Select **RTL Project** (leave *Do not specify sources at this time* unchecked).
4. **Add Source Files:**
   * Click **Add Files** and select all `.v` files inside the `RTL/` directory (`ac.v`, `addr_mux.v`, `alu.v`, `controller.v`, `cpu.v`, `ir.v`, `memory.v`, `pc.v`).
   * Set `cpu.v` as the Top Module if prompted.
5. **Add Simulation Sources:**
   * Click **Add Files** and select all `.v` files inside the `Testbench/` directory (`ac_tb.v`, `alu_tb.v`, `cpu_tb.v`, etc.).
6. Select your target FPGA board/part and click **Finish**.

---

### Step 3: Run Unit Tests (Module-Level)

To test individual hardware modules (`alu`, `controller`, `pc`, `ir`, `memory`, etc.):

1. In the Vivado **Sources** panel, expand **Simulation Sources** -> `sim_1`.
2. Right-click the desired module testbench (e.g., `alu_tb.v`) and select **Set as Top**.
3. In the left Flow Navigator, click **Run Simulation** -> **Run Behavioral Simulation**.
4. Check the **Tcl Console / Simulation Terminal**:
   * Inspect the `if/else` print statements verifying module outputs against expected values.
5. Inspect the **Waveform Window** to verify signal timings, state transitions, and flag assertions.

---

### Step 4: Run Top-Level CPU Integration Test

To verify complete instruction execution across the entire RISC CPU pipeline:

1. In **Simulation Sources**, right-click `cpu_tb.v` (or `cpu_testcases.v`) and select **Set as Top**.
2. Click **Run Simulation** -> **Run Behavioral Simulation**.
3. Observe the **Tcl Console Output**:
   * The testbench will execute pre-loaded program memory routines.
   * Review the terminal output logs for printed pass/fail status updates generated by the `if/else` checks.
4. **Inspect CPU Waveforms:**
   * Key signals to add to the Waveform viewer: `clk`, `rst`, `pc_addr`, `ir_opcode`, `acc_out`, `alu_out`, and `fsm_state`.
   * Confirm that instructions advance across clock cycles following the 8-state controller sequence (`INST_ADDR` to `STORE`).