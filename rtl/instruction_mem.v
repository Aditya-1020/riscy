`timescale 1ps/1ps
`default_nettype none
`include "isa.v"

module instruction_mem (
    input wire clk,
    input wire reset,
    input [`WORD_ADDRESS-1:0] address,
    output reg [`XLEN-1:0] instruction
);

    reg [`XLEN-1:0] instruction_memory [0:`MEM_SIZE-1];

    `ifdef SIMULATION
    initial begin
        $readmemh("test.hex", instruction_memory);
    end
    `endif

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            instruction <= {`XLEN{1'b0}};
        end else begin
            instruction <= instruction_memory[address];
        end
    end

endmodule