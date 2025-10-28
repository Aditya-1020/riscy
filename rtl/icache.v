/// instruction cache
`timescale 1ps/1ps
`default_nettype none
`include "rtl/isa.v"

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
    output reg [`XLEN-1:0] instruction
);
    
    localparam IDLE = 2'b00;
    localparam REFILL = 2'b01;
    
    reg [1:0] state, next_state;
    reg [1:0] refill_count, next_refill_count;

    // 128 bits per line cache (4 words)
    reg valid [0:31];
    reg [22:0] tag [0:31];
    reg [31:0] data [0:31][0:3];

    // pc decde
    wire [4:0] index = pc[8:4];
    wire [1:0] word_offset = pc[3:2];
    wire [22:0] tag_in = pc[31:9];

    wire tag_match = valid[index] && (tag[index] == tag_in);
    
    // Refill control
    wire [4:0] refill_index = mem_addr[8:4];
    wire [1:0] refill_word_offset = refill_count;

    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            refill_count <= 2'b0;
            mem_read <= 1'b0;
            mem_addr <= 32'h0;
            
            for (i = 0; i < 32; i = i + 1) begin
                valid[i] <= 1'b0;
                tag[i] <= 23'h0;
                data[i][0] <= 32'h0;
                data[i][1] <= 32'h0;
                data[i][2] <= 32'h0;
                data[i][3] <= 32'h0;
            end
        end else begin
            state <= next_state;
            refill_count <= next_refill_count;
            
            case (state)
                IDLE: begin
                    if (fetch_en && !tag_match) begin
                        mem_addr <= {pc[31:4], 4'b0000};
                        mem_read <= 1'b1;
                    end else begin
                        mem_read <= 1'b0;
                    end
                end

                REFILL: begin
                    if (mem_ready) begin
                        data[refill_index][refill_word_offset] <= mem_data;
                        
                        if (refill_count == 2'b11) begin
                            valid[refill_index] <= 1'b1;
                            tag[refill_index] <= mem_addr[31:9];
                            mem_read <= 1'b0;
                        end else begin
                            mem_addr <= mem_addr + 4;
                        end
                    end
                end
            endcase
        end
    end

    always @(*) begin
        // Defaults
        next_state = state;
        next_refill_count = refill_count;
        hit = 1'b0;
        miss = 1'b0;
        ready = 1'b0;
        instruction = `NOP_INSTRUCTION;
        
        case (state)
            IDLE: begin
                if (fetch_en) begin
                    if (tag_match) begin
                        hit = 1'b1;
                        ready = 1'b1;
                        instruction = data[index][word_offset];
                        next_state = IDLE;
                    end else begin
                        miss = 1'b1;
                        ready = 1'b0;
                        next_state = REFILL;
                        next_refill_count = 2'b0;
                    end
                end else begin
                    ready = 1'b1;
                    next_state = IDLE;
                end
            end

            REFILL: begin
                ready = 1'b0;
                
                if (mem_ready) begin
                    if (refill_count == 2'b11) begin
                        next_state = IDLE;
                        next_refill_count = 2'b0;
                    end else begin
                        next_refill_count = refill_count + 2'b1;
                        next_state = REFILL;
                    end
                end else begin
                    next_state = REFILL;
                end
            end
            
            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule