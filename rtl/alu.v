`timescale 1ps/1ps
`default_nettype none
`include "rtl/isa.v"

module alu (
    input [`XLEN-1:0] a,
    input [`XLEN-1:0] b,
    input [3:0] ALUControl,
    output reg zero,
    output reg [`XLEN-1:0] result
);
    
    wire [4:0] shift_amount;
    assign shift_amount = b[4:0];

    wire signed [`XLEN-1:0] signed_a = $signed(a);
    wire signed [`XLEN-1:0] signed_b = $signed(b);

    wire signed [63:0] mul_result_signed = signed_a * signed_b;
    wire [63:0] mul_result_unsigned = a * b;
    wire signed [63:0] mul_result_su = signed_a * $signed({1'b0, b});

    always @(*) begin
        case (ALUControl)
            `ALU_ADD: result = a + b;
            `ALU_SUB: result = a - b;
            `ALU_SLL: result = a << shift_amount;
            `ALU_SLT: result = (signed_a < signed_b) ? 32'd1 : 32'd0;
            `ALU_SLTU: result = (a < b) ? 32'd1 : 32'd0;
            `ALU_XOR: result = a ^ b;
            `ALU_SRL: result = a >> shift_amount;
            `ALU_SRA: result = signed_a >>> shift_amount;
            `ALU_OR: result = a | b;
            `ALU_AND: result = a & b;
            `ALU_PASS_A: result = a;
            `ALU_PASS_B: result = b;
            `ALU_MUL: result = mul_result_signed[31:0];
            `ALU_MULH: result = mul_result_signed[63:32];
            `ALU_MULHU: result = mul_result_unsigned[63:32];
            `ALU_MULHSU: result = mul_result_su[63:32];
            default: result = a + b;
        endcase

        zero  = (result == {`XLEN{1'b0}});
    end

endmodule