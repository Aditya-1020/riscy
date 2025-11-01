`timescale 1ps/1ps
`default_nettype none
`include "rtl/isa.v"

module instruction_mem (
    input wire clk,
    input wire reset,
    input [`WORD_ADDRESS-1:0] address,
    output reg [`XLEN-1:0] instruction
);

    reg [`XLEN-1:0] instruction_memory [0:`MEM_SIZE-1];

    integer i;
    initial begin
        for (i = 0; i < `MEM_SIZE; i = i + 1) begin
            instruction_memory[i] = `NOP_INSTRUCTION;
        end

        $readmemh("rtl/matrix_mult.hex", instruction_memory);
        // two files for testing: "matrix_mult.hex" and "test.hex"
        
        `ifndef SYNTHESIS
            $display("imem initialized:");
            $display("[0] = %h", instruction_memory[0]);
            $display("[1] = %h", instruction_memory[1]);
            $display("[2] = %h", instruction_memory[2]);
            $display("[3] = %h", instruction_memory[3]);
        `endif
    end

    always @(*) begin
        if (address < `MEM_SIZE)
            instruction = instruction_memory[address];
        else
            instruction = `NOP_INSTRUCTION;
    end

    //always @(posedge clk) begin
//        instruction <= (address < `MEM_SIZE) ? instruction_memory[address] : `NOP_INSTRUCTION;
  //  end

endmodule