`timescale 1ns / 1ps

module alu_tb;
    parameter WIDTH = 16;

    reg [WIDTH - 1:0] inA;
    reg [WIDTH - 1:0] inB;
    reg [3:0]         opcode;
    wire [WIDTH - 1:0] alu_out;
    wire              zero, overflow;

    integer errors = 0;

    alu #(.WIDTH(WIDTH)) dut (
        .inA(inA),
        .inB(inB),
        .opcode(opcode),
        .alu_out(alu_out), 
        .zero(zero),
        .overflow(overflow)
    );

    task display_result;
        input [8*16:1]    inst_name;
        input [WIDTH-1:0] exp_out;
        input             exp_zero;
        input             exp_overflow;
        begin
            $display("--- TEST: %s ---", inst_name);
            $display("--- EXPECTED: opcode=%b | inA=16'h%04h | inB=16'h%04h | zero=%b | overflow=%b | alu_out=16'h%04h", 
                     opcode, inA, inB, exp_zero, exp_overflow, exp_out);
            $display("--- RECEIVED: opcode=%b | inA=16'h%04h | inB=16'h%04h | zero=%b | overflow=%b | alu_out=16'h%04h", 
                     opcode, inA, inB, zero, overflow, alu_out);

            if (alu_out === exp_out && zero === exp_zero && overflow === exp_overflow) begin
                $display("RESULT: PASS\n");
            end else begin
                $display("RESULT: FAIL <--- ERROR DETECTED!\n");
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        inA = 16'h0000; 
        inB = 16'h0000; 
        opcode = 4'b0000; 
        #10;

        $display("=================================================");
        $display("----- PART 1: TESTING ORIGINAL CORE OPS ---------");
        $display("=================================================");

        // Test Zero Flag & SKZ
        inA = 16'h0000; inB = 16'hFFFF; opcode = 4'b0001; #5;
        display_result("SKZ (Zero)", 16'h0000, 1'b1, 1'b0); #5;

        inA = 16'h1234; inB = 16'hFFFF; opcode = 4'b0001; #5;
        display_result("SKZ (Non-Zero)", 16'h1234, 1'b0, 1'b0); #5;
        
        // Test ADD
        opcode = 4'b0010; inA = 16'h00F0; inB = 16'h0010; #5;
        display_result("ADD Normal", 16'h0100, 1'b0, 1'b0); #5;

        opcode = 4'b0010; inA = 16'h7FFF; inB = 16'h0001; #5; // overflow
        display_result("ADD Overflow", 16'h8000, 1'b0, 1'b1); #5;

        // Test AND
        opcode = 4'b0011; inA = 16'hF0F0; inB = 16'hAAAA; #5;
        display_result("AND", 16'hA0A0, 1'b0, 1'b0); #5;

        // Test XOR
        opcode = 4'b0100; inA = 16'hF0F0; inB = 16'hAAAA; #5;
        display_result("XOR", 16'h5A50, 1'b0, 1'b0); #5;

        // Test LDA
        opcode = 4'b0101; inA = 16'h1234; inB = 16'hABCD; #5;
        display_result("LDA", 16'hABCD, 1'b0, 1'b0); #5;

        // Test HLT, STO, JMP
        opcode = 4'b0000; inA = 16'h1234; inB = 16'hABCD; #5;
        display_result("HLT", 16'h1234, 1'b0, 1'b0); #5;

        opcode = 4'b0110; inA = 16'h1234; inB = 16'hABCD; #5;
        display_result("STO", 16'h1234, 1'b0, 1'b0); #5;

        opcode = 4'b0111; inA = 16'h1234; inB = 16'hABCD; #5;
        display_result("JMP", 16'h1234, 1'b0, 1'b0); #5;

        $display("=================================================");
        $display("----- PART 2: TESTING EXTENDED OPS -------------");
        $display("=================================================");

        // Test SUB
        opcode = 4'b1000; inA = 16'd150; inB = 16'd50; #5; // 150 - 50 = 100
        display_result("SUB Normal", 16'd100, 1'b0, 1'b0); #5;

        opcode = 4'b1000; inA = 16'h8000; inB = 16'h0001; #5; // overflow
        display_result("SUB Overflow", 16'h7FFF, 1'b0, 1'b1); #5;

        // Test OR
        opcode = 4'b1001; inA = 16'hAA00; inB = 16'h0055; #5;
        display_result("OR", 16'hAA55, 1'b0, 1'b0); #5;

        // Test MUL 
        opcode = 4'b1010; inA = 16'd25; inB = 16'd10; #5; // 25 * 10 = 250
        display_result("MUL", 16'd250, 1'b0, 1'b0); #5;

        // // Test FPU / MULS (Opcode 1011)
        // opcode = 4'b1011; inA = 16'd5; inB = -16'd4; #5; // 5 * (-4) = -20 (16'hFFEC)
        // display_result("MULS/FPU", 16'hFFEC, 1'b0, 1'b0); #5;

        // Test Shift Left (SHL) & Shift Right (SHR)
        opcode = 4'b1100; inA = 16'h800F; inB = 16'd0; #5; 
        display_result("SHL", 16'h001E, 1'b0, 1'b1); #5;

        opcode = 4'b1101; inA = 16'h000F; inB = 16'd0; #5;
        display_result("SHR", 16'h0007, 1'b0, 1'b0); #5;

        // Test NOT
        opcode = 4'b1110; inA = 16'h5555; inB = 16'h0000; #5;
        display_result("NOT", 16'hAAAA, 1'b0, 1'b0); #5;

        // Test SKO
        opcode = 4'b1111; inA = 16'h00FF; inB = 16'h0000; #5;
        display_result("SKO", 16'h00FF, 1'b0, 1'b0); #5;

        $display("=================================================");
        if (errors == 0) begin
            $display("ALU TEST SUMMARY: ALL TESTS PASSED SUCCESSFULLY!");
        end else begin
            $display("ALU TEST SUMMARY: %0d TEST(S) FAILED!", errors);
        end
        $display("=================================================");
        $finish;
    end
endmodule