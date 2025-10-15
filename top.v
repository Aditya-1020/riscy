`timescale 1ps/1ps
`default_nettype none
`include "isa.v"

module top (
    input wire clk,
    input wire reset,
    output wire [`XLEN-1:0] pc_debug,
    output wire [`XLEN-1:0] instruction_debug
);

    wire [`XLEN-1:0] instruction;
    wire branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
    wire [3:0] ALU_op;

    control_unit ctrl (
        .instruction(instruction),
        .branch(branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALU_op(ALU_op),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite)
    );

    datapath dp (
        .clk(clk),
        .reset(reset),
        .branch(branch),
        .MemRead(MemRead),
        .MemToReg(MemtoReg),
        .ALU_op(ALU_op),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .current_pc(pc_debug),
        .current_instruction(instruction)
    );

    assign instruction_debug = instruction;

endmodule