`timescale 1ps/1ps
`default_nettype none
`include "rtl/isa.v"

module hazard_unit (
    input wire [4:0] rs1_id_in, rs2_id_in,
    input wire [4:0] rd_ex_in,
    input wire MemRead_in,
    input wire branch_in, jump_in,

    output wire stall,
    output wire flush_ex
);

    wire hazard_rs1_rs2;
    assign hazard_rs1_rs2 = (rd_ex_in == rs1_id_in && rs1_id_in != 0) || (rd_ex_in == rs2_id_in != 0);

    wire load_use_hazard;
    assign load_use_hazard = MemRead_in && hazard_rs1_rs2;

    wire control_hazard;
    assign control_hazard = branch_in | jump_in;

    assign stall = load_use_hazard;
    assign flush = control_hazard;

endmodule