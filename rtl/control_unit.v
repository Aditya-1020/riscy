`timescale 1ps/1ps
`default_nettype none
`include "isa.v"
// `include "decode_funct7.v"

module control_unit (
    input [`XLEN-1:0] instruction,
    output reg branch,
    output reg MemRead,
    output reg MemtoReg,
    output reg [3:0] ALU_op,
    output reg MemWrite,
    output reg ALUSrc,
    output reg RegWrite
);

    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [3:0] decoded_funct7;

    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];

    decode_funct7 decode_inst (
        .funct7(funct7),
        .alu_op(decoded_funct7)
    );

    always @(*) begin
        branch = 1'b0;
        MemRead = 1'b0;
        MemtoReg = 1'b0;
        ALU_op = `ALU_ADD;
        MemWrite = 1'b0;
        ALUSrc = 1'b0;
        RegWrite = 1'b0;
        
        
        case (opcode)
            `OP_R_TYPE: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b0;
                MemtoReg = 1'b0;

                case (funct3)
                    `FUNCT3_ADD_SUB: ALU_op = decoded_funct7;
                    `FUNCT3_XOR: ALU_op = `ALU_XOR;
                    `FUNCT3_OR: ALU_op = `ALU_OR;
                    `FUNCT3_AND: ALU_op = `ALU_AND;
                    `FUNCT3_SLL: ALU_op = `ALU_SLL;
                    `FUNCT3_SRL_SRA: ALU_op = decoded_funct7;
                    `FUNCT3_SLT: ALU_op = `ALU_SLT;
                    `FUNCT3_SLTU: ALU_op = `ALU_SLTU;
                    default: ALU_op = `ALU_ADD;
                endcase
            end

            `OP_IMM: begin
                RegWrite = 1'b1;
                ALUSrc = 1'b1;
                MemtoReg = 1'b0;

                case (funct3)
                    `FUNCT3_ADD_SUB: ALU_op = `ALU_ADD;
                    `FUNCT3_XOR: ALU_op = `ALU_XOR;
                    `FUNCT3_OR: ALU_op = `ALU_OR;
                    `FUNCT3_AND: ALU_op = `ALU_AND;
                    `FUNCT3_SLL: ALU_op = `ALU_SLL;
                    `FUNCT3_SRL_SRA: ALU_op = decoded_funct7;
                    `FUNCT3_SLT: ALU_op = `ALU_SLT;
                    `FUNCT3_SLTU: ALU_op = `ALU_SLTU;
                    default: ALU_op = `ALU_ADD;
                endcase
            end

            `OP_IMM_LOAD: begin
                RegWrite = 1'b1;
                ALUSrc = 1'b1;
                MemRead = 1'b1;
                MemtoReg = 1'b1;
                ALU_op = `ALU_ADD;
            end

            `OP_S_TYPE: begin
                RegWrite = 1'b0;  // RISC-V S-type does NOT write registers
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
                ALU_op   = `ALU_ADD; // Usually ADD for address calculation
            end

            `OP_B_TYPE: begin
                branch   = 1'b1;
                RegWrite = 1'b0;  // B-type does NOT write registers
                ALUSrc   = 1'b0;
                ALU_op   = `ALU_SUB;
            end

            `OP_U_LUI: begin
                RegWrite = 1'b1;
                ALU_op = `ALU_PASS_A;
                ALUSrc = 1'b1;
            end

            `OP_U_AUIPC: begin
                RegWrite = 1'b1;
                ALU_op = `ALU_ADD;
                ALUSrc = 1'b1;
            end

            `OP_J_JAL, `OP_J_JALR: begin
                RegWrite = 1'b1;
                ALU_op = `ALU_ADD;
                ALUSrc = 1'b1;
            end

            default: begin
                
            end
        endcase
    end

endmodule