# AdiRiscV
A 32-bit RISC-V processor implementation in Verilog supporting the RV32I base integer instruction set with a 5-stage pipeline and branch prediction.

## Features
- 5-stage pipeline (Fetch, Decode, Execute, Memory, Writeback)
- Full RV32I ISA support (arithmetic, logical, memory, branch, jump instructions)
- Branch prediction with 64-entry Branch Target Buffer (BTB)

### Performance
- CPI (Cycles Per Instruction): 1.000
- Branch Prediction Accuracy: 99.9%
- Pipeline Stall Rate: 0.0%
- Test Execution: 4,998 instructions in 5,000 cycles
- Clock Frequency: 70-80 MHz

### File Tree
```md
├── full_synthesis.log
├── LICENSE
├── README.md
├── riscv-spec.pdf
├── rtl/
│   ├── alu_control.v
│   ├── alu.v
│   ├── branch_control.v
│   ├── branch_predictor.v
│   ├── btb.v
│   ├── cache_controler.v
│   ├── control_unit.v
│   ├── data_memory.v
│   ├── datapath.v
│   ├── decode_funct7.v
│   ├── forwarding_unit.v
│   ├── hazard_unit.v
│   ├── imm_gen.v
│   ├── instruction_mem.v
│   ├── isa.v
│   ├── pc_plus4.v
│   ├── pc.v
│   ├── pipeline.v
│   ├── ras.v
│   ├── regfile.v
│   ├── test.hex
│   └── top.v
├── tb/
│   └── top_tb.v
└── sim
```


### Build
- Icarus Verilog (for simulation)
- Yosys (for synthesis)
- GTKWave (for waveform viewing)

```bash
# Compile and run testbench
iverilog -g2012 -o sim tb/top_tb.v rtl/*.v
./sim

# View waveforms
gtkwave pipeline.vcd
```