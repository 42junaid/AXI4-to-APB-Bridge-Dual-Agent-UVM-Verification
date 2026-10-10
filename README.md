# AXI4-to-APB Bridge UVM Verification Project

**Author:** Junaid Uz Zaman
**Date:** October 2026
**Tool:** Synopsys VCS (L-2016.06)
**Methodology:** UVM 1.2

---

## 📋 Project Overview

This project implements a complete **UVM-based functional verification environment** for the **AXI4-to-APB Bridge (`axi2apb`)** RTL design. The DUT converts AXI4 read/write transactions into APB single transfers and returns responses back to the AXI side.

The verification environment uses a **dual-agent architecture**:
- **AXI Master Agent** — drives AXI transactions to the DUT
- **APB Slave Agent** — responds to APB requests from the DUT

The environment includes a **scoreboard** for transaction-level checking, **functional coverage**, and **directed + random tests**.

---

## 🏗️ Project Structure
axi2apb/
│
├── docs/ # Documentation
│ └── README.md
│
├── rtl/ # RTL source files (DUT + dependencies)
│ ├── axi2apb.sv # Main DUT (32-bit version)
│ ├── axi2apb_64_32.sv # 64-bit AXI → 32-bit APB version
│ ├── axi2apb_wrap.sv # Wrapper module
│ ├── axi_aw_buffer.sv # AXI write address FIFO
│ ├── axi_ar_buffer.sv # AXI read address FIFO
│ ├── axi_w_buffer.sv # AXI write data FIFO
│ ├── axi_r_buffer.sv # AXI read data FIFO
│ ├── axi_b_buffer.sv # AXI write response FIFO
│ ├── axi_single_slice.sv # FIFO wrapper
│ ├── axi_slice.sv # AXI slice
│ ├── fifo.sv # Generic FIFO
│ └── ...
│
├── tb/ # Testbench (UVM environment)
│ ├── axi_if.sv # AXI interface (AXI_BUS)
│ ├── apb_if.sv # APB interface (APB_BUS)
│ ├── axi_seq_item.sv # AXI transaction class
│ ├── apb_seq_item.sv # APB transaction class
│ ├── axi_sequencer.sv # AXI sequencer
│ ├── apb_sequencer.sv # APB sequencer
│ ├── axi_driver.sv # AXI Master driver
│ ├── apb_driver.sv # APB Slave driver
│ ├── axi_monitor.sv # AXI monitor
│ ├── apb_monitor.sv # APB monitor
│ ├── axi_agent.sv # AXI agent
│ ├── apb_agent.sv # APB agent
│ ├── axi2apb_scoreboard.sv # Scoreboard (comparison)
│ ├── axi2apb_coverage.sv # Functional coverage
│ ├── axi2apb_env.sv # Environment
│ ├── axi2apb_seq.sv # Sequences
│ ├── axi2apb_base_test.sv # Base test
│ ├── axi2apb_test.sv # All test classes
│ ├── axi2apb_pkg.sv # Package (includes all classes)
│ └── tb_top.sv # Top testbench module
│
├── sim/ # Simulation
│ ├── build.flist # File list for compilation
│ ├── makefile # Makefile for VCS
│ └── out/ # Simulation outputs
│
└── README.md # This file
## 📁 Files Description

### Interfaces

| File | Description |
|------|-------------|
| `axi_if.sv` | AXI4 interface with `AXI_BUS` (PULP-compatible), `Slave` and `Master` modports |
| `apb_if.sv` | APB interface with `APB_BUS`, `Master` and `Slave` modports |

### AXI Master Agent

| File | Description |
|------|-------------|
| `axi_seq_item.sv` | AXI transaction class with all AXI4 signals and constraints |
| `axi_sequencer.sv` | UVM sequencer for AXI transactions |
| `axi_driver.sv` | AXI Master driver — drives AW, W, AR channels; receives B, R channels |
| `axi_monitor.sv` | AXI monitor — captures complete AXI read/write transactions |
| `axi_agent.sv` | AXI agent — contains sequencer, driver, monitor |

### APB Slave Agent

| File | Description |
|------|-------------|
| `apb_seq_item.sv` | APB transaction class (PADDR, PWRITE, PWDATA, PRDATA, PREADY, PSLVERR) |
| `apb_sequencer.sv` | UVM sequencer for APB |
| `apb_driver.sv` | APB Slave driver — responds to APB requests with configurable wait states |
| `apb_monitor.sv` | APB monitor — captures APB transactions |
| `apb_agent.sv` | APB agent — contains sequencer, driver, monitor |

### Environment

| File | Description |
|------|-------------|
| `axi2apb_scoreboard.sv` | Compares AXI and APB transactions; reports match/mismatch |
| `axi2apb_coverage.sv` | Functional coverage collector with covergroups |
| `axi2apb_env.sv` | Top environment — contains both agents, scoreboard, coverage |

### Sequences

| File | Description |
|------|-------------|
| `axi2apb_seq.sv` | Write, Read, Random sequences |

### Tests

| File | Description |
|------|-------------|
| `axi2apb_base_test.sv` | Base test class (builds env) |
| `axi2apb_test.sv` | All test classes (Basic, Directed, All Directed) |

### Package & Top

| File | Description |
|------|-------------|
| `axi2apb_pkg.sv` | UVM package that includes all classes |
| `tb_top.sv` | Top testbench module with DUT instantiation and waveform dump |

---

## ✅ Verification Features Implemented

### 1. Dual-Agent UVM Environment
- **AXI Master Agent** — drives DUT
- **APB Slave Agent** — responds to DUT

### 2. Scoreboard (Transaction-Level Comparison)
- AXI write ↔ APB write comparison (address + data)
- AXI read ↔ APB read comparison (address + data)
- Match/Mismatch reporting
- Queue-based synchronization (handles timing skew)

### 3. Functional Coverage
- Transaction type (read vs write)
- Address ranges (zero, low, mid, high, max)
- Data patterns (all-zero, all-one, alternating, random)
- IDs and USER values
- PREADY latency
- Cross coverage

### 4. Directed Tests (4 Implemented)

| Test | What It Verifies |
|------|------------------|
| **Write with Wait States** | APB PREADY delayed by 3 cycles; bridge waits in `WAIT_W_PREADY` |
| **Read with Wait States** | APB PREADY delayed by 3 cycles; bridge waits in `WAIT_R_PREADY` |
| **Read with RREADY Delayed** | AXI RREADY delayed by 3 cycles; bridge holds RVALID |
| **Write with BREADY Delayed** | AXI BREADY delayed by 3 cycles; bridge holds BVALID |

### 5. Random Tests
- 5 random read/write transactions
- Constrained randomization (word-aligned addresses, valid IDs)

### 6. All-Directed Test
- Runs all 4 directed tests sequentially in one simulation

---

## 🚀 How to Run

### Prerequisites
- Synopsys VCS (L-2016.06 or later)
- UVM 1.2
- Linux environment

### Compile
```bash
cd sim/
make compile TEST=<test_name>
🧪 Available Tests
Command	Description
make sim TEST=axi2apb_test	Basic Test: 1 Write + 1 Read + 5 Random (7 transactions)
make sim TEST=axi2apb_write_wait_test	Directed: Write with 3 wait cycles
make sim TEST=axi2apb_read_wait_test	Directed: Read with 3 wait cycles
make sim TEST=axi2apb_rready_delay_test	Directed: Read with RREADY delayed 3 cycles
make sim TEST=axi2apb_bready_delay_test	Directed: Write with BREADY delayed 3 cycles
make sim TEST=axi2apb_all_directed_test	All 4 Directed Tests in one run
🔍 Key RTL Observations Verified
From the provided RTL specification, the following behaviors were verified:

#	RTL Behavior	Verification Method
1	IDLE state gives priority to ARVALID over AWVALID	Observed in random test
2	Write accepted only when both AWVALID and WVALID are high	Verified by timing
3	Write waits in WAIT_W_PREADY while PREADY=0	Directed Test 1
4	Read waits in WAIT_R_PREADY while PREADY=0	Directed Test 2
5	RVALID and RLAST asserted for single read	All read tests
6	BID = AWID and BUSER = AWUSER	All write tests
7	BRESP/RRESP = OKAY by default (PSLVERR ignored)	Pending
8	No burst support (single beat only)	Pending
9	WSTRB/WLAST ignored by FSM	Pending
10	Async active-low reset	Reset behavior
🛠️ Tools & Methodology
Item	Details
Simulator	Synopsys VCS L-2016.06
Methodology	UVM 1.2
Language	SystemVerilog
Waveform	VPD (waveform.vpd)
Coverage	VCS Coverage (-cm line+cond+tgl+fsm)

