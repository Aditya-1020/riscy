// return address stack
`timescale 1ps/1ps
`default_nettype none
`include "isa.v"

module ras (
    input wire clk,
    input wire reset,
    input wire push_en,
    input wire [`XLEN-1:0] return_addresss,
    input wire [6:0] opcode,
    input wire [4:0] rd,
    // pop if jlar
    input wire pop_en,
    input wire [4:0] rs1,
    input wire flush,
    
    output wire [`XLEN-1:0] top_stack_address,
    output wire valid_ras,
    output wire [`RAS_PTR_WIDTH-1:0] stack_ptr_out
);

    reg [`XLEN-1:0] stack [0:`RAS_SIZE-1];
    reg [`RAS_PTR_WIDTH-1:0] stack_ptr;
    reg [`RAS_PTR_WIDTH-1:0] count;

    wire is_call = (opcode == `OP_J_JAL || opcode == `OP_J_JALR) && (rd == 5'd1 || rd == 5'd5);
    wire is_return = opcode == `OP_J_JALR) && (rs1 == 5'd1 || rs1 == 5'd5) && (rd != 5'd1 && rd != 5'd5);

    