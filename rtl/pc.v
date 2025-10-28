`timescale 1ps/1ps
`default_nettype none
`include "rtl/isa.v"

module pc (
    input wire clk,
    input wire reset,
    input wire [`XLEN-1:0] pc_next,
    output reg [`XLEN-1:0] pc
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= `RESET_PC;
        else
            pc <= pc_next;
    end
    
endmodule