/// instruction cache
`timescale 1ps/1ps
`default_nettype none
`include "isa.v"

module icache (
    input wire clk,
    input wire reset,
    input wire [`XLEN-1:0] pc,
    input wire fetch_en,
    input wire mem_ready,
    input wire [`XLEN-1:0] mem_data,
    output reg hit,
    output reg miss,
    output reg ready,
    output reg mem_read,
    output reg [`XLEN-1:0] mem_addr,
    output wire [`XLEN-1:0] instruction
);
    
    localparam IDLE = 2'b00;
    localparam REFILL = 2'b01;
    
    reg [1:0] state, refill_count;

    // 128 bits per line cache (4 words)
    reg valid [0:31];
    reg [22:0] tag [0:31];
    reg [31:0] data [0:31][0:3];

    // PC decode
    wire [4:0] index = pc[8:4];
    wire [1:0] word_offset = pc[3:2];
    wire [22:0] tag_in = pc[31:9];

    wire tag_match = valid[index] && (tag[index] == tag_in);
    
    // Outputs
    assign instruction = data[index][word_offset];
    
    // Combinational logic for hit/miss/ready
    always @(*) begin
        hit = tag_match && fetch_en && (state == IDLE);
        miss = fetch_en && !tag_match && (state == IDLE);
        ready = (state == IDLE) && tag_match;
    end

    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            mem_read <= 1'b0;
            mem_addr <= 32'h0;
            refill_count <= 2'b0;
            for (i = 0; i < 32; i = i + 1) begin
                valid[i] <= 1'b0;
                tag[i] <= 23'h0;
            end
        end else begin
            case (state)
                IDLE: begin
                    mem_read <= 1'b0;
                    refill_count <= 2'b0;
                    if (miss) begin
                        state <= REFILL;
                        mem_addr <= {pc[31:4], 4'b0000};
                        mem_read <= 1'b1;
                    end
                end

                REFILL: begin
                    if (mem_ready) begin
                        data[index][refill_count] <= mem_data;

                        if (refill_count == 2'b11) begin
                            valid[index] <= 1'b1;
                            tag[index] <= tag_in;
                            mem_read <= 1'b0;
                            state <= IDLE;
                            refill_count <= 2'b0;
                        end else begin
                            refill_count <= refill_count + 2'b1;
                            mem_addr <= mem_addr + 4;
                        end
                    end
                end
                
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule