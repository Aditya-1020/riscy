`timescale 1ps/1ps
`default_nettype none
`include "isa.v"

module datapath (
    input wire clk,
    input wire reset,
    input wire branch,
    input wire MemRead,
    input wire MemToReg,
    input wire [3:0] ALU_op,
    input wire MemWrite,
    input wire ALUSrc,
    input wire RegWrite,
    output wire [`XLEN-1:0] current_pc,
    output wire [`XLEN-1:0] current_instruction
);

    wire [`XLEN-1:0] pc_out, pc_plus4_out;
    wire [`XLEN-1:0] reg_data1, reg_data2;
    wire [`XLEN-1:0] instruction, immediate;
    wire [`XLEN-1:0] alu_result, alu_in_b;
    wire [`XLEN-1:0] mem_read_data, reg_write_data;
    wire alu_zero, pc_src;
    wire [`XLEN-1:0] branch_target;
    wire [4:0] rs1, rs2, rd;
    wire [2:0] funct3;
    wire [`XLEN-1:0] address;
    wire [`XLEN-1:0] pc_next;
    wire [6:0] opcode;
    wire branch_taken;


    wire opcode = instruction[6:0];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd = instruction[11:7];
    assign funct3 = instruction[14:12];

    assign address = alu_result;
    assign current_pc = pc_out;
    assign current_instruction = instruction;

    branch_control branch_control_inst (
        .funct3(funct3),
        .opcode(opcode),
        .alu_zero(alu_zero),
        .rs1_data(reg_data1),
        .rs2_data(reg_data2),
        .branch_enable(branch),
        .branch_taken(branch_taken)
    );

    assign branch_target = pc_out + immediate;

    wire is_jal = (opcode == `OP_J_JAL);
    wire is_jalr = (opcode == `OP_J_JALR);
    wire [`XLEN-1:0] jalr_target = (reg_data1 + immediate) & ~32'h1;

    assign pc_src = branch_taken | is_jal | is_jalr;
    assign pc_next = is_jalr ? jalr_target : pc_src ? branch_target : pc_plus4_out;
    
    pc pc_inst (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_next),
        .pc(pc_out)
    );

    pc_plus4 pc_plus4_inst (
        .pc_in(pc_out),
        .pc_plus4(pc_plus4_out)
    );

    instruction_mem inst_mem (
        .clk(clk),
        .reset(reset),
        .address(pc_out[11:2]),
        .instruction(instruction)
    );

    regfile register_inst (
        .clk(clk),
        .reset(reset),
        .rs1_addr(rs1),
        .rs2_addr(rs2),
        .rd(rd),
        .write_data(reg_write_data),
        .wr_en(RegWrite),
        .rs1_data(reg_data1),
        .rs2_data(reg_data2)
    );

    imm_gen imm_gen_inst (
        .instruction(instruction),
        .immediate(immediate)
    );

    assign alu_in_b = ALUSrc ? immediate : reg_data2;

    alu alu_inst (
        .a(reg_data1),
        .b(alu_in_b),
        .ALUControl(ALU_op),
        .zero(alu_zero),
        .result(alu_result)
    );

    data_memory dmem_inst (
        .clk(clk),
        .reset(reset),
        .address(address),
        .WriteData(reg_data2),
        .WriteEnable(MemWrite),
        .MemRead(MemRead),
        .ReadData(mem_read_data)
    );

    // writeback
    wire write_pc_plus4 = is_jal | is_jalr;
    assign reg_write_data = write_pc_plus4 ? pc_plus4_out : MemToReg ? mem_read_data : alu_result;

endmodule