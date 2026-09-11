`timescale 1ns / 1ps

module controller_tb;
    
    parameter OPCODE_WIDTH = 4;
    parameter OPERAND_WIDTH = 12;

    reg clk, rst, zero, overflow;
    reg [OPCODE_WIDTH - 1:0] opcode;
    wire sel, rd, ld_ir, halt, inc_pc, ld_ac, ld_pc, wr, data_e;

    reg obs_halt, obs_ld_ac, obs_ld_pc, obs_wr, obs_data_e;
    reg [1:0] obs_inc_pc; 

    controller #(.OPCODE_WIDTH(OPCODE_WIDTH)) dut (
        .clk(clk), 
        .rst(rst), 
        .opcode(opcode), 
        .zero(zero), 
        .overflow(overflow),
        .sel(sel), 
        .rd(rd), 
        .ld_ir(ld_ir), 
        .halt(halt),
        .inc_pc(inc_pc), 
        .ld_ac(ld_ac), 
        .ld_pc(ld_pc), 
        .wr(wr), 
        .data_e(data_e)
    );

    task print_result;
        input [64:0] test_name;
        input expected_halt;
        input [1:0] expected_inc_pc;
        input expected_ld_ac;
        input expected_ld_pc;
        input expected_wr;
        input expected_data_e;
        begin
            $display("");
            $display("--- %s ---", test_name);
            $display("--- EXPECTED VALUE ---");
            $display("opcode = %b \t halt = %b \t inc_pc = %0d \t ld_ac = %b \t ld_pc = %b \t wr = %b \t data_e = %b",
                     opcode, expected_halt, expected_inc_pc, expected_ld_ac, expected_ld_pc, expected_wr, expected_data_e);
            $display("--- RECEIVED VALUE ---");
            $display("opcode = %b \t halt = %b \t inc_pc = %0d \t ld_ac = %b \t ld_pc = %b \t wr = %b \t data_e = %b",
                     opcode, obs_halt, obs_inc_pc, obs_ld_ac, obs_ld_pc, obs_wr, obs_data_e);

            if (obs_halt !== expected_halt || obs_inc_pc !== expected_inc_pc || obs_ld_ac !== expected_ld_ac ||
                obs_ld_pc !== expected_ld_pc || obs_wr !== expected_wr || obs_data_e !== expected_data_e) begin
                $display("RESULT: FAIL\n");
            end else begin
                $display("RESULT: PASS\n");
            end
        end
    endtask
    
    task run_instruction;
        input [64:0] test_name;
        input [OPCODE_WIDTH - 1:0] op;
        input z;
        input ov;
        input exp_halt;
        input [1:0] exp_inc_pc;
        input exp_ld_ac;
        input exp_ld_pc;
        input exp_wr;
        input exp_data_e;
        begin
            opcode = op;
            zero = z;
            overflow = ov;
            
            obs_halt = 0; obs_inc_pc = 0; obs_ld_ac = 0; obs_ld_pc = 0; obs_wr = 0; obs_data_e = 0;
            
            repeat(8) begin
                @(negedge clk);
                obs_halt   = obs_halt | halt;
                obs_ld_ac  = obs_ld_ac | ld_ac;
                obs_ld_pc  = obs_ld_pc | ld_pc;
                obs_wr     = obs_wr | wr;
                obs_data_e = obs_data_e | data_e;
                if (inc_pc) obs_inc_pc = obs_inc_pc + 1;
            end
            
            print_result(test_name, exp_halt, exp_inc_pc, exp_ld_ac, exp_ld_pc, exp_wr, exp_data_e);
        end
    endtask

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        rst = 1;
        opcode = {OPCODE_WIDTH{1'b0}};
        zero = 0;
        overflow = 0;
        
        #15; 
        rst = 0;
        
        run_instruction("Test 1", 4'b0010, 0, 0,  0, 1, 1, 0, 0, 0); // ADD
        run_instruction("Test 2", 4'b0001, 1, 0,  0, 2, 0, 0, 0, 0); // SKZ (zero=1 -> inc_pc 2)
        run_instruction("Test 3", 4'b0001, 0, 0,  0, 1, 0, 0, 0, 0); // SKZ (zero=0 -> inc_pc 1)
        run_instruction("Test 4", 4'b0111, 0, 0,  0, 1, 0, 1, 0, 0); // JMP
        run_instruction("Test 5", 4'b0110, 0, 0,  0, 1, 0, 0, 1, 1); // STO
        run_instruction("Test 6", 4'b1000, 0, 0,  0, 1, 1, 0, 0, 0); // SUB
        run_instruction("Test 7", 4'b1001, 0, 0,  0, 1, 1, 0, 0, 0); // OR
        run_instruction("Test 8", 4'b1010, 0, 0,  0, 1, 1, 0, 0, 0); // MUL
        run_instruction("Test 9", 4'b1011, 0, 0,  0, 1, 1, 0, 0, 0); // MAC
        run_instruction("Test 10", 4'b1100, 0, 0, 0, 1, 1, 0, 0, 0); // SHL
        run_instruction("Test 11", 4'b1101, 0, 0, 0, 1, 1, 0, 0, 0); // SHR
        run_instruction("Test 12", 4'b1110, 0, 0, 0, 1, 1, 0, 0, 0); // NOT
        run_instruction("Test 13", 4'b1111, 0, 1, 0, 2, 0, 0, 0, 0); // SKO (overflow=1 -> inc_pc 2)
        run_instruction("Test 14", 4'b0000, 0, 0, 1, 0, 0, 0, 0, 0); // HLT
        
        $finish;
    end

endmodule