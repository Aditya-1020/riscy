`timescale 1ps/1ps
`default_nettype none
`include "isa.v"

module datapath (
    input wire clk,
    input wire reset,
    input wire branch_id, MemRead_id, MemToReg_id,
    input wire [3:0] ALU_op_id,
    input wire MemWrite_id, ALUSrc_id,
    input wire RegWrite_id, is_jal_id, is_jalr_id,

    output wire [`XLEN-1:0] pc_if_debug,
    output wire [`XLEN-1:0] instruction_if_debug,
    output wire [`XLEN-1:0] pc_id_debug, instruction_id_debug
);

    wire [`XLEN-1:0] pc_if, pc_next_if, pc_plus4_if, instruction_if;
    wire [`XLEN-1:0] pc_id, instruction_id;
    wire [4:0] rs1_id, rs2_id, rd_id;
    wire [2:0] funct3_id;
    wire [6:0] opcode_id;
    wire instr_30_id;
    wire [`XLEN-1:0] rs1_data_id, rs2_data_id, immediate_id;

    wire [`XLEN-1:0] pc_ex, rs1_data_ex, rs2_data_ex, immediate_ex;
    wire [4:0] rs1_addr_ex, rs2_addr_ex, rd_ex;
    wire [2:0] funct3_ex;
    wire [6:0] opcode_ex;
    wire instr_30_ex;
    wire RegWrite_ex, MemToReg_ex, MemWrite_ex, MemRead_ex;
    wire ALUSrc_ex, branch_ex;
    wire [3:0] ALU_op_ex;
    wire is_jal_ex, is_jalr_ex;

    wire [`XLEN-1:0] alu_in_a, alu_in_b, alu_result_ex;
    wire alu_zero_ex;
    wire [`XLEN-1:0] forwarded_rs1_ex, forwarded_rs2_ex;
    wire [1:0] forward_a, forward_b;
    wire branch_taken_ex;
    wire [`XLEN-1:0] branch_target_ex;
    wire [`XLEN-1:0] alu_result_mem, rs2_data_mem;
    wire [4:0] rd_mem;
    wire RegWrite_mem, MemToReg_mem, MemWrite_mem, MemRead_mem;
    wire branch_mem;
    wire [`XLEN-1:0] branch_target_mem;
    wire branch_taken_mem;
    wire [2:0] funct3_mem;
    wire [`XLEN-1:0] mem_read_data;
    wire [3:0] write_enable_mem;
    wire [1:0] load_type_mem;
    wire [`XLEN-1:0] mem_data_wb, alu_result_wb;
    wire [4:0] rd_wb;
    wire RegWrite_wb, MemToReg_wb;
    wire [`XLEN-1:0] write_back_data;
    wire stall, flush_if, flush_id, flush_ex;
    wire control_hazard;

    assign opcode_id = instruction_id[6:0];
    assign rs1_id = instruction_id[19:15];
    assign rs2_id = instruction_id[24:20];
    assign rd_id = instruction_id[11:7];
    assign funct3_id = instruction_id[14:12];
    assign instr_30_id = instruction_id[30];

    assign control_hazard = branch_taken_ex | is_jal_ex | is_jalr_ex;
    assign flush_if = control_hazard;
    assign flush_id = control_hazard;
    assign flush_ex = 1'b0;

    hazard_unit hazard_unit_inst (
        .rs1_id_in(rs1_id),
        .rs2_id_in(rs2_id),
        .rd_ex_in(rd_ex),
        .MemRead_in(MemRead_ex),
        .branch_in(branch_ex),
        .jump_in(is_jal_ex | is_jalr_ex),
        .stall(stall),
        .flush_ex(flush_ex)
    );

    forwarding_unit forwarding_unit_inst (
        .rs1_ex(rs1_addr_ex),
        .rs2_ex(rs2_addr_ex),
        .rd_mem(rd_mem),
        .rd_wb(rd_wb),
        .RegWrite_mem(RegWrite_mem),
        .RegWrite_wb(RegWrite_wb),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    wire [`XLEN-1:0] jalr_target_ex = (forwarded_rs1_ex + immediate_ex) & ~32'h1;
    assign branch_target_ex = pc_ex + immediate_ex;

    assign pc_next_if = control_hazard ? (is_jalr_ex ? jalr_target_ex : branch_target_ex) : pc_plus4_if;

    pc pc_inst (
        .clk(clk),
        .reset(reset),
        .pc_next(stall ? pc_if : pc_next_if),
        .pc(pc_if)
    );

    pc_plus4 pc_plus4_inst (
        .pc_in(pc_if),
        .pc_plus4(pc_plus4_if)
    );

    instruction_mem instruction_mem_inst (
        .clk(clk),
        .reset(reset),
        .address(pc_if[11:2]),
        .instruction(instruction_if)
    );

    IF_ID_reg if_id_reg_inst (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .flush(flush_if),
        .pc_in(pc_if),
        .instruction_in(instruction_if),
        .pc_out(pc_id),
        .instruction_out(instruction_id)
    );

    regfile register_inst (
        .clk(clk),
        .reset(reset),
        .rs1_addr(rs1_id),
        .rs2_addr(rs2_id),
        .rd(rd_wb),
        .write_data(write_back_data),
        .wr_en(RegWrite_wb),
        .rs1_data(rs1_data_id),
        .rs2_data(rs2_data_id)
    );

    imm_gen imm_gen_inst (
        .instruction(instruction_id),
        .immediate(immediate_id)
    );

    ID_EX_reg ID_EX_reg_inst (
        .clk(clk),
        .reset(reset),
        .flush(flush_id),
        .stall(1'b0),
        .RegWrite_in(stall ? 1'b0 : RegWrite_id),
        .MemToReg_in(stall ? 1'b0 : MemToReg_id),
        .MemWrite_in(stall ? 1'b0 : MemWrite_id),
        .MemRead_in(stall ? 1'b0 : MemRead_id),
        .ALUSrc_in(ALUSrc_id),
        .branch_in(stall ? 1'b0 : branch_id),
        .ALU_op_in(ALU_op_id),
        .is_jal_in(is_jal_id),
        .is_jalr_in(is_jalr_id),
        .pc_in(pc_id),
        .rs1_data_in(rs1_data_id),
        .rs2_data_in(rs2_data_id),
        .immediate_in(immediate_id),
        .rs1_addr_in(rs1_id),
        .rs2_addr_in(rs2_id),
        .rd_addr_in(rd_id),
        .funct3_in(funct3_id),
        .opcode_in(opcode_id),
        .instr_30_in(instr_30_id),
        .RegWrite_out(RegWrite_ex),
        .MemToReg_out(MemToReg_ex),
        .MemWrite_out(MemWrite_ex),
        .MemRead_out(MemRead_ex),
        .ALUSrc_out(ALUSrc_ex),
        .branch_out(branch_ex),
        .ALU_op_out(ALU_op_ex),
        .is_jal_out(is_jal_ex),
        .is_jalr_out(is_jalr_ex),
        .pc_out(pc_ex),
        .rs1_data_out(rs1_data_ex),
        .rs2_data_out(rs2_data_ex),
        .immediate_out(immediate_ex),
        .rs1_addr_out(rs1_addr_ex),
        .rs2_addr_out(rs2_addr_ex),
        .rd_addr_out(rd_ex),
        .funct3_out(funct3_ex),
        .opcode_out(opcode_ex),
        .instr_30_out(instr_30_ex)
    );
    
    assign forwarded_rs1_ex = (forward_a == 2'b10) ? alu_result_mem : (forward_a == 2'b01) ? write_back_data : rs1_data_ex;
    assign forwarded_rs2_ex = (forward_b == 2'b10) ? alu_result_mem : (forward_b == 2'b01) ? write_back_data : rs2_data_ex;

    assign alu_in_a = forwarded_rs1_ex;
    assign alu_in_b = ALUSrc_ex ? immediate_ex : forwarded_rs2_ex;

    alu alu_inst (
        .a(alu_in_a),
        .b(alu_in_b),
        .ALUControl(ALU_op_ex),
        .zero(alu_zero_ex),
        .result(alu_result_ex)
    );

    branch_control branch_control_inst (
        .funct3(funct3_ex),
        .opcode(opcode_ex),
        .alu_zero(alu_zero_ex),
        .rs1_data(forwarded_rs1_ex),
        .rs2_data(forwarded_rs2_ex),
        .branch_enable(branch_ex),
        .branch_taken(branch_taken_ex)
    );

    EX_MEM_reg EX_MEM_reg_inst (
        .clk(clk),
        .reset(reset),
        .stall(1'b0),
        .flush(flush_ex),
        .alu_result_in(alu_result_ex),
        .rs2_data_in(forwarded_rs2_ex),
        .RegWrite_in(RegWrite_ex),
        .MemToReg_in(MemToReg_ex),
        .MemWrite_in(MemWrite_ex),
        .MemRead_in(MemRead_ex),
        .branch_in(branch_ex),
        .rd_addr_in(rd_ex),
        .funct3_in(funct3_ex),
        .branch_target_in(branch_target_ex),
        .branch_taken_in(branch_taken_ex),
        .alu_result_out(alu_result_mem),
        .rs2_data_out(rs2_data_mem),
        .RegWrite_out(RegWrite_mem),
        .MemToReg_out(MemToReg_mem),
        .MemWrite_out(MemWrite_mem),
        .MemRead_out(MemRead_mem),
        .branch_out(branch_mem),
        .rd_addr_out(rd_mem),
        .funct3_out(funct3_mem),
        .branch_target_out(branch_target_mem),
        .branch_taken_out(branch_taken_mem)
    );

    wire funct3S_check = (funct3_mem == `FUNCT3_SB ? 4'b0001 : funct3_mem == `FUNCT3_SH ? 4'b0011 : funct3_mem == `FUNCT3_SW ? 4'b1111 : 4'b0000);
    assign write_enable_mem = MemWrite_mem ? funct3S_check : 4'b0000;
    
    assign load_type_mem = (funct3_mem == `FUNCT3_LB || funct3_mem == `FUNCT3_LBU) ? 2'b00 : (funct3_mem == `FUNCT3_LH || funct3_mem == `FUNCT3_LHU) ? 2'b01 : 2'b10;

    data_memory data_memory_inst (
        .clk(clk),
        .reset(reset),
        .address(alu_result_mem),
        .WriteData(rs2_data_mem),
        .WriteEnable(write_enable_mem),
        .load_type(load_type_mem),
        .MemRead(MemRead_mem),
        .ReadData(mem_read_data)
    );

    MEM_WB_reg MEM_WB_reg_inst (
        .clk(clk),
        .reset(reset),
        .stall(1'b0),
        .flush(1'b0),
        .mem_data_in(mem_read_data),
        .alu_result_in(alu_result_mem),
        .RegWrite_in(RegWrite_mem),
        .MemToReg(MemToReg_mem),
        .rd_addr_in(rd_mem),
        .mem_data_out(mem_data_wb),
        .alu_result_out(alu_result_wb),
        .RegWrite_out(RegWrite_wb),
        .MemToReg_out(MemToReg_wb),
        .rd_addr_out(rd_wb)
    );

    assign write_back_data = MemToReg_wb ? mem_data_wb : alu_result_wb;

    assign pc_if_debug = pc_if;
    assign instruction_if_debug = instruction_if;
    assign pc_id_debug = pc_id;
    assign instruction_id_debug = instruction_id;
    
endmodule