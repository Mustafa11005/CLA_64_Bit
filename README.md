# Generic Carry Lookahead Adder (CLA)

[![IEEE](https://img.shields.io/badge/IEEE-ASU%20Student%20Branch-blue.svg)](https://ieee.asu.edu.eg)
[![SystemVerilog](https://img.shields.io/badge/SystemVerilog-Universal-blue.svg)](https://standards.ieee.org/ieee/1800/4519/)
[![Vivado](https://img.shields.io/badge/Xilinx-Vivado-orange.svg)](https://www.xilinx.com/products/design-tools/vivado.html)

A parameterized, hierarchical Carry Lookahead Adder (CLA) implementation in SystemVerilog that supports logarithmic scales of 4 (4, 16, 64, 256 bits). This project was developed as part of the IEEE ASU Student Branch Digital Design Team filtration task.<br>

## 📋 Project Overview

This implementation features a multi-level hierarchical CLA architecture that combines 4-bit CLA blocks to create larger adders with optimized carry propagation delay. The design is fully parameterized and has been verified through extensive simulation and FPGA implementation.<br>

### Key Features
- **Parameterized Design**: Supports any DATA_WIDTH that's a power of 4 (4, 16, 64, 256, ...)<br>
- **Hierarchical Architecture**: Multi-level CLA tree for optimal performance<br>
- **Full Verification**: Comprehensive testbench with 1100+ test cases<br>
- **FPGA Proven**: Synthesized and implemented on VCU118 board<br>
- **Clean RTL**: Well-commented, modular SystemVerilog code<br>

## 🏗️ Architecture

### Block Diagram

CLA_top (N-bit)<br>
├── gp_gen (Generate/Propagate)<br>
├── Level 0: N/4 × cla_4bit (4-bit groups)<br>
├── Level 1: N/16 × cla_4bit (16-bit groups)<br>
├── ...<br>
└── Sum_blk (Final sum calculation)<br>


### Module Hierarchy
- **CLA_top**: Top-level parameterized CLA<br>
- **cla_4bit**: 4-bit Carry Lookahead block (carry network)<br>
- **gp_gen**: Generate/Propagate signal generator<br>
- **Sum_blk**: Final sum calculation using XOR<br>

## 📁 File Structure

CLA_Generic/<br>
├── RTL/<br>
│ ├── CLA_top.sv # Top-level parameterized CLA<br>
│ ├── CLA_4_bit.sv # 4-bit CLA carry network<br>
│ ├── GP_gen.sv # Generate/Propagate generator<br>
│ └── Sum_blk.sv # Sum calculation block<br>
├── Verification/<br>
│ └── CLA_tb.sv # Comprehensive testbench<br>
├── Documentation/<br>
│ ├── Generic_Carry_Look_Ahead_report.pdf<br>
│ └── IEEE_Digital_Design_Team-Filtration_Task.pdf<br>
└── README.md<br>


## 🔧 Module Specifications

### CLA_top
```systemverilog
module CLA_top #(
    parameter int DATA_WIDTH = 64
)(
    input  logic [DATA_WIDTH-1:0] A,    // First operand
    input  logic [DATA_WIDTH-1:0] B,    // Second operand  
    input  logic                  cin,  // Carry input
    output logic [DATA_WIDTH-1:0] sum,  // Sum output
    output logic                  cout  // Carry output
);
```

## cla_4bit
Inputs: cin, g0_i, p0_i, g1_i, p1_i, g2_i, p2_i, g3_i, p3_i<br>

Outputs: c1_o, c2_o, c3_o, c4_o, p_o, g_o<br>

Function: 4-bit carry network with group propagate/generate<br>

## gp_gen
Function: Computes bit-level generate (A & B) and propagate (A ^ B) signals

## Sum_blk
Function: Final sum calculation using sum = p_i ^ cin

### 🚀 Usage
## Simulation
# DO File
vlib work<br>
vlog -f src_files.list +cover -covercells<br>
vsim -voptargs=+acc work.top_tb -cover -l sim.log<br>
add wave *<br>
coverage save CLA.ucdb -onexit<br>
run -all<br>
quit -sim<br>
vcover report CLA.ucdb -details -annotate -all -output CLA_coverage_rpt.txt<br>

# SRC_FILES.LIST
GP_gen.sv<br>
Sum_blk.sv<br>
CLA_4_bit.sv<br>
CLA_top.sv<br>
CLA_tb.sv<br>

### 📊 Results
Simulation Results<br>
Total Tests: 1100<br>
Passed Tests: 1100 (100%)<br>
Failed Tests: 0<br>
Status: ALL TESTS PASSED ✓<br>

## FPGA Implementation (VCU118 Board)
Resource | Utilization | Available | Utilization %<br>
LUT	     |    136	   |  134,600  |    0.10%<br>
I/O	     |    194	   |    500	   |   38.80%<br>

### ⚠️ Limitations

1- Parameter Constraints:<br>
    - DATA_WIDTH must be a power of 4 (4, 16, 64, 256, ...)<br>
    - Non-power-of-4 values will not function correctly<br>

2- Architecture:<br>
    - Fixed 4-bit building blocks<br>
    - Limited to hierarchical CLA structure<br>

3- Performance:<br>
    - Optimal for power-of-4 bit widths<br>
    - Suboptimal for other bit widths<br>

### 🧪 Test Coverage
The testbench includes comprehensive verification:
    - ✅ Corner cases (all zeros, all ones, max values).
    
    - ✅ Power-of-2 additions
    
    - ✅ Alternating bit patterns
    
    - ✅ Sequential values
    
    - ✅ Random vectors (1000+ tests)
    
    - ✅ Near-overflow stress tests

### 📚 References

    - Parhami, B. (2010). Computer Arithmetic: Algorithms and Hardware Designs (2nd ed.). Oxford University Press. (Chapter 6)<br>
    - UCSB ECE 252B, Spring 2020, Lecture 4: Carry-Lookahead Adders<br>
    - IEEE Standard 1800-2017 - SystemVerilog Language Reference Manual<br>

### 👥 Author
Mustafa Tamer EL-Sherif

Email: elsherifmustafa04@gmail.com

GitHub: Mustafa11005

LinkedIn: Mustafa El-Sherif

Organization: IEEE ASU Student Branch, Digital IC Design Team

### 🔗 Links
[IEEE ASU Student Branch](https://ieee.asu.edu.eg/)

[VCU118 Board Documentation](https://www.xilinx.com/products/boards-and-kits/vcu118.html)

[SystemVerilog IEEE Standard](https://standards.ieee.org/ieee/1800/4519/)
