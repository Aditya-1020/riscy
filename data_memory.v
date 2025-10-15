`timescale 1ps/1ps
`default_nettype none
`include "isa.v"

module data_memory (
    input wire clk,
    input wire reset,
    input wire [`XLEN-1:0] address,
    input wire [`XLEN-1:0] WriteData,
    input wire WriteEnable,
    input wire MemRead,
    output reg [`XLEN-1:0] ReadData
);

    reg [`XLEN-1:0] data_mem [0:`MEM_SIZE-1];

    wire [`WORD_ADDRESS-3:0] word_address;
    assign word_address = address[`WORD_ADDRESS-1:2];

    integer i;
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < (`MEM_SIZE/`WORD_BYTES); i = i + 1) begin
                data_mem[i] <= {`XLEN{1'b0}};
            end
        end
        else if (WriteEnable) begin
            data_mem[word_address] <= WriteData;
        end
    end

    always @(posedge clk) begin
        if (MemRead) begin
            ReadData <= data_mem[word_address];
        end
        else begin
            ReadData <= {`XLEN{1'b0}};
        end
    end
    
endmodule