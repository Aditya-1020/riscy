`timescale 1ps/1ps
`default_nettype none

module top_tb;
    reg clk;
    reg reset;
    
    wire [31:0] pc_if, pc_id;
    wire [31:0] instruction_if, instruction_id;
    wire [31:0] cycle_count, instruction_count, stall_count;
    wire [31:0] branch_count, branch_mispredicts;
    wire branch_mispredict, icache_stall;
    
    top dut (
        .clk(clk),
        .reset(reset),
        .pc_if_debug(pc_if),
        .pc_id_debug(pc_id),
        .instruction_if_debug(instruction_if),
        .instruction_id_debug(instruction_id),
        .cycle_count(cycle_count),
        .instruction_count(instruction_count),
        .stall_count(stall_count),
        .branch_count(branch_count),
        .branch_mispredicts(branch_mispredicts),
        .branch_mispredict_signal(branch_mispredict),
        .icache_stall_signal(icache_stall)
    );
    
    initial begin
        clk = 0;
        forever #5000 clk = ~clk;  // 5ns
    end
    
    initial begin
        $display("RISC-V RV32I Pipeline CPU Testbench");
    
        reset = 1;
        #20000;  // Hold reset 20ns
        reset = 0;
        
        $display("\nTime=%0t: Reset released, starting execution", $time);
        $display("PC_IF\t\tPC_ID\t\tInstr_IF\tInstr_ID");
        
        // Monitor execution
        repeat(200) begin
            @(posedge clk);
            #1000;
            if (instruction_id !== 32'h00000013) begin
                $display("%0t\t%h\t%h\t%h\t%h", 
                    $time, pc_if, pc_id, instruction_if, instruction_id);
            end
    
            if (pc_if == pc_id && instruction_if == 32'h0000006f) begin
                $display("\n End marker detected (infinite loop)");
                #50000;
                $finish;
            end
        end
        
        $display("Performance Summary");
        $display("Total Cycles:           %0d", cycle_count);
        $display("Instructions Executed:  %0d", instruction_count);
        $display("Stall Cycles:           %0d", stall_count);
        $display("Branch Count:           %0d", branch_count);
        $display("Branch Mispredicts:     %0d", branch_mispredicts);
        
        if (instruction_count > 0) begin
            $display("CPI:                    %0f", 
                real'(cycle_count) / real'(instruction_count));
            $display("IPC:                    %0f", 
                real'(instruction_count) / real'(cycle_count));
        end
        
        if (branch_count > 0) begin
            $display("Branch Prediction Acc:  %0f%%", 
                100.0 * (1.0 - real'(branch_mispredicts)/real'(branch_count)));
        end
        
        $display("Register File State (Sample)");

        $display("x1  = %h", dut.dp.register_inst.registers[1]);
        $display("x2  = %h", dut.dp.register_inst.registers[2]);
        $display("x3  = %h", dut.dp.register_inst.registers[3]);
        $display("x10 = %h", dut.dp.register_inst.registers[10]);
        $display("x24 = %h", dut.dp.register_inst.registers[24]);
        $display("x30 = %h", dut.dp.register_inst.registers[30]);
        
        $display("\nTest completed successfully!");
        $finish;
    end
    
    initial begin
        #10000000;  // 10us timeout
        $display("\n*** ERROR: Simulation timeout! ***");
        $finish;
    end
    
    initial begin
        $dumpfile("cpu_test.vcd");
        $dumpvars(0, top_tb);
    end
    
    always @(posedge clk) begin
        if (icache_stall && !reset) begin
            $display("%0t: I-Cache stall detected", $time);
        end
        if (branch_mispredict && !reset) begin
            $display("%0t: Branch misprediction at PC=%h", $time, pc_id);
        end
    end

endmodule