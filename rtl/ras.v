// return address stack
`timescale 1ps/1ps
`default_nettype none
`include "isa.v"

module ras (
    input wire clk,
    input wire reset,
    input wire flush,
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

    //rd = x1 ir x5
    wire is_call = (opcode == `OP_J_JAL || opcode == `OP_J_JALR) && (rd == 5'd1 || rd == 5'd5);
    wire is_return = (opcode == `OP_J_JALR) && (rs1 == 5'd1 || rs1 == 5'd5) && (rd != 5'd1 && rd != 5'd5);

    assign top_stack_address = stack[stack_ptr];
    assign stack_ptr_out = stack_ptr;
    assign valid_ras = |stack_ptr;

    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            for (i = 0; i < `RAS_SIZE; i = i + 1)
                stack[i] <= {`XLEN{1'b0}};
            stack_ptr <= 0;
        end else begin
            if (push_en && is_call) begin
                stack_ptr <= (stack_ptr + 1) % `RAS_SIZE;
                stack[stack_ptr] <= return_addresss;
            end else if (pop_en && is_return && valid_ras) begin
                stack_ptr <= (stack_ptr - 1) % `RAS_SIZE;
            end
        end
    end

endmodule