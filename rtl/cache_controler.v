`timescale 1ps/1ps
`default_nettype none
`include "isa.v"

module cache_controler (
    input wire clk,
    input wire reset,
    input wire cache_miss,
    input wire [`XLEN-1:0] miss_addr, mem_data,
    input wire mem_ack,

    output reg refill_valid,
    output reg [`XLEN-1:0] refill_data,
    output reg refill_done,
    output reg mem_req,
    output reg [`XLEN-1:0] mem_addr,
);

    localparam IDLE= 2'b00;
    localparam REFILL = 2'b01;

    reg [1:0] state;
    reg [1:0] refill_count;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            mem_req <= 1'b0;
            refill_valid <= 1'b0;
            refill_done <= 1'b0;
            refill_count <= 2'b0;
            mem_addr <= 0;
            refill_data <= 0;
        end else begin
            case (state) begin
                IDLE: begin
                    refill_done <= 0;
                    refill_valid <= 0;
                    mem_req <= -;
                    refill_count <= 0;
                    if (cache_miss) begin
                        mem_addr <= {miss_addr[`XLEN-1:4], 4'b0000};
                        mem_req <= 1'b1;
                        state <= REFILL;
                    end
                end

                REFILL: begin
                    if (mem_ack) begin
                        refill_data <= mem_data;
                        refill_valid <= 1'b1;
                        if (refill_count == 2'b11) begin
                            refill_done <= 1'b1;
                            mem_req <= 1'b0;
                            state <= IDLE;
                            refill_count <= 0;
                            refill_valid <= 0;
                        end else begin
                            refill_count <= refill_count + 1;
                            mem_addr <= mem_addr + 4;
                        end
                    end else begin
                        refill_valid <= 0;
                    end
                end
            end
            endcase
        end
    end