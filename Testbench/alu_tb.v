`timescale 1ns / 1ps

module alu_tb;
    parameter WIDTH = 9;

    reg [WIDTH - 1:0] inA;
    reg [WIDTH - 1:0] inB;
    reg [3:0] opcode;
    wire [WIDTH - 1:0] alu_out;
    wire zero, overflow;

    alu #(.WIDTH(WIDTH)) dut (
        .inA(inA), .inB(inB), .opcode(opcode), .alu_out(alu_out), 
        .zero(zero), .overflow(overflow)
    );

    task display_result;
        input [8*5:1] inst_name;
        input [WIDTH - 1:0] exp_out;
        input exp_zero, exp_overflow;
        begin
            $display("--- EXPECTED VALUE ---");
            $display("opcode = %b | inA = %b | inB = %b | zero = %b | overflow = %b | alu_out = %b --- %s", 
                     opcode, inA, inB, exp_zero, exp_overflow, exp_out, inst_name);
            $display("--- RECEIVED VALUE ---");
            $display("opcode = %b | inA = %b | inB = %b | zero = %b | overflow = %b | alu_out = %b", 
                     opcode, inA, inB, zero, overflow, alu_out);
            $display("");
        end
    endtask

    initial begin
        inA = 9'd0; inB = 9'd0; opcode = 4'b0000; #10;

        $display("=================================================");
        $display("----- PART 1: TESTING ORIGINAL 8 OPERATIONS -----");
        $display("=================================================");

        // Test Zero Flag & SKZ
        inA = 9'b00000_0000; inB = 9'b11111_1111; opcode = 4'b0001; #5;
        display_result("SKZ", 9'b0_0000_0000, 1'b1, 1'b0); #5;

        inA = 9'b11000_0111; inB = 9'b11111_1111; opcode = 4'b0001; #5;
        display_result("SKZ", 9'b1_1000_0111, 1'b0, 1'b0); #5;
        
        // Test ADD
        opcode = 4'b0010; inA = 9'b11111_0000; inB = 9'b00010_0000; #5;
        display_result("ADD", 9'b0_0001_0000, 1'b0, 1'b0); #5;

        // Test AND
        opcode = 4'b0011; inA = 9'b11100_1100; inB = 9'b11010_1010; #5;
        display_result("AND", 9'b1_1000_1000, 1'b0, 1'b0); #5;

        // Test XOR
        opcode = 4'b0100; inA = 9'b11100_1100; inB = 9'b11010_1010; #5;
        display_result("XOR", 9'b0_0110_0110, 1'b0, 1'b0); #5;

        // Test LDA
        opcode = 4'b0101; inA = 9'b11100_1100; inB = 9'b11010_1010; #5;
        display_result("LDA", 9'b1_1010_1010, 1'b0, 1'b0); #5;

        // Test HLT
        opcode = 4'b0000; inA = 9'b11100_1100; inB = 9'b11010_1010; #5;
        display_result("HLT", 9'b1_1100_1100, 1'b0, 1'b0); #5;

        // Test STO
        opcode = 4'b0110; inA = 9'b11100_1100; inB = 9'b11010_1010; #5;
        display_result("STO", 9'b1_1100_1100, 1'b0, 1'b0); #5;

        // Test JMP
        opcode = 4'b0111; inA = 9'b11100_1100; inB = 9'b11010_1010; #5;
        display_result("JMP", 9'b1_1100_1100, 1'b0, 1'b0); #5;

        $display("=================================================");
        $display("----- PART 2: TESTING NEW LATCHED 8 OPS ---------");
        $display("=================================================");

        // 1. Test SUB
        opcode = 4'b1000; inA = 9'd150; inB = 9'd50; #5; // 150 - 50 = 100
        display_result("SUB", 9'd100, 1'b0, 1'b0); #5;

        opcode = 4'b1000; inA = 9'd200; inB = 9'b11001_1100; #5; 
        display_result("SUBOV", 9'b1_0010_1100, 1'b0, 1'b1); #5;

        // 3. Test OR (Logic OR)
        opcode = 4'b1001; inA = 9'b10101_0101; inB = 9'b01010_1010; #5;
        display_result("OR", 9'b1_1111_1111, 1'b0, 1'b0); #5;

        // 4. Test MUL
        opcode = 4'b1010; inA = 9'd25; inB = 9'd10; #5; // 25 * 10 = 250
        display_result("MUL", 9'd250, 1'b0, 1'b0); #5;

        // 5. Test MULS
        opcode = 4'b1011; inA = 9'd5; inB = 9'b11111_1100; #5;
        display_result("MULS", 9'b11110_1100, 1'b0, 1'b0); #5;

        opcode = 4'b1100; inA = 9'b10000_1111; inB = 9'd0; #5;
        display_result("SHL", 9'b00001_1110, 1'b0, 1'b1); #5;

        opcode = 4'b1101; inA = 9'b11111_0001; inB = 9'd0; #5;
        display_result("SHR", 9'b01111_1000, 1'b0, 1'b0); #5;

        opcode = 4'b1110; inA = 9'b10101_0101; inB = 9'b01111_1111; #5;
        display_result("NOT", 9'b01010_1010, 1'b0, 1'b0); #5;

        opcode = 4'b1111; inA = 9'b01111_0000; inB = 9'b10000_1111; #5;
        display_result("SKO", 9'b01111_0000, 1'b0, 1'b0); #5;

        $display("----- Testing Immediate Logic Change -----");
        opcode = 4'b0010; inA = 9'd10; inB = 9'd10; #10; 
        
        inA = 9'd20; #3;          
        inA = 9'd40; #2;          
        inB = 9'd60; #5;

        $display("=================================================");
        $display("--- SIMULATION DONE SUCCESSFUL ---");
        $display("=================================================");
        $finish;
    end
endmodule