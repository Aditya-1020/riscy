`timescale 1ps/1ps
`default_nettype none
`include "isa.v"

module top (
    input wire clk,
    input wire reset,
    output wire [`XLEN-1:0] pc_if_debug, pc_id_debug,
    output wire [`XLEN-1:0] instruction_if_debug, instruction_id_debug,
    output wire [31:0] cycle_count, instruction_count, stall_count,
    output wire [31:0] branch_count, branch_mispredicts
);
    wire branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
    wire [3:0] ALU_op;
    wire is_branch, is_jump, is_jal, is_jalr, is_load, is_store;

    wire [`XLEN-1:0] instruction_id;
    assign instruciton_id = instruction_id_debug;

    control_unit control_unit_inst (
        .instruction(instruction),
        .branch(branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALU_op(ALU_op),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite)
        .is_branch(is_branch),
        .is_jump(is_jump),
        .is_jal(is_jal),
        .is_jalr(is_jalr),
        .is_load(is_load),
        .is_store(is_store)
    );

    datapath dp (
        .clk(clk),
        .reset(reset),
        .branch_id(branch),
        .MemRead_id(MemRead),
        .MemToReg_id(MemToReg),
        .ALU_op_id(ALU_op),
        .MemWrite_id(MemWrite),
        .ALUSrc_id(ALUSrc),
        .RegWrite_id(RegWrite),
        .is_jal_id(is_jal),
        .is_jalr_id(is_jalr),
        .pc_if_debug(pc_if_debug),
        .instruction_if_debug(instruction_if_debug),
        .pc_id_debug(pc_id_debug),
        .instruction_id_debug(instruction_id_debug)
    );

    perforamnce_counters perforamnce_counters_inst (
        .clk(clk),
        .reset(reset),
        .instruction_valid(instruciton_id_debug != `NOP_INSTRUCTION),
        .is_branch(is_branch),
        .branch_taken(1'b0),
        .branch_predict(1'b0),
        .stall(1'b0),
        .cycle_count(cycle_count),
        .instruction_count(instruction_count),
        .stall_count(stall_count),
        .branch_count(branch_count),
        .branch_mispredicts(branch_mispredicts)
    );

endmodule

module perforamnce_counters (
    input wire clk,
    input wire reset,
    input wire instruction_valid,
    input wire is_branch, branch_taken, branch_predict,
    input wire stall,
    output reg [31:0] cycle_count, instruction_count, stall_count,
    output reg [31:0] branch_count, branch_mispredicts
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            cycle_count <= 32'b0;
            instruction_count <= 32'b0;
            stall_count <= 32'b0;
            branch_count <= 32'b0;
            branch_mispredicts <= 32'b0;
        end else begin
            cycle_count <= cycle_count + 1;

            if (instruction_valid && !stall)
                instruction_count <= instruction_count + 1;

            if (stall)
                stall_count <= stall_count + 1;
            
            if (is_branch)
                branch_count <= branch_count + 1;
            
            if (is_branch && (branch_taken != branch_predict))
                branch_mispredicts <= branch_mispredicts + 1;
        end
    end

endmodule