RISC-V RV32I 5-Stage Pipeline
- Core Features: Classic pipeline with hazard detection, forwarding, and branch prediction
- Key Components: Instruction fetch unit, decoder with immediate generation, ALU with bypass logic, data cache interface, writeback stage
- Cache: 512B direct-mapped I-cache 
- Memory Interface: AXI4-Lite (industry standard, impressive on resume)
- Advanced Features: Branch target buffer (BTB), return address stack, pipeline stall/flush logic
- Deliverables: Complete RTL, comprehensive testbench with RISC-V compliance tests, synthesis reports
- Target: 60-100MHz simulation, measure CPI
- Benchmark Programs: Matrix multiply, quicksort

---
btb.v
- acts as cache of branch and map targts
- lookup durthing IF stage and update after execution once target is known

icache.v
