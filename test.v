`timescale 1ps/1ps
`default_nettype none
`include "isa.v"

module test;
    reg clk, reset;
    wire [`XLEN-1:0] pc;

    wire [`XLEN-1:0] pc_debug;
    wire [`XLEN-1:0] instruction_debug;

    integer cycles;
    
    always @(posedge clk) begin
        cycles = cycles + 1;
    end

    top dut (
        .clk(clk),
        .reset(reset)
        // .pc_debug(pc_debug),
        // .instruction_debug(instruction_debug)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        cycles = 0;
        reset = 1;
        #20 reset = 0;
        #500 $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, dut);
    end

endmodule