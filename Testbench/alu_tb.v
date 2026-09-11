`timescale 1ns / 1ps

module alu_tb;

    parameter OPCODE_WIDTH = 4;
    parameter OPERAND_WIDTH = 12;

    reg [OPCODE_WIDTH + OPERAND_WIDTH - 1:0] inA;
    reg [OPCODE_WIDTH + OPERAND_WIDTH - 1:0] inB;
    reg [OPCODE_WIDTH - 1:0]                 opcode;
    wire [OPCODE_WIDTH + OPERAND_WIDTH - 1:0] alu_out;
    wire                                     zero, overflow;

    alu #(.WIDTH(OPCODE_WIDTH + OPERAND_WIDTH)) dut (
        .inA(inA),
        .inB(inB),
        .opcode(opcode),
        .alu_out(alu_out), 
        .zero(zero),
        .overflow(overflow)
    );

    task print_result;
        input [64:0] test_name;
        input [OPCODE_WIDTH + OPERAND_WIDTH - 1:0] expected_alu_out;
        input expected_zero;
        input expected_overflow;
        begin
            $display("");
            $display("--- %s ---", test_name);
            $display("--- EXPECTED VALUE ---");
            $display("opcode = %b \t inA = 16'h%04h \t inB = 16'h%04h \t zero = %b \t overflow = %b \t alu_out = 16'h%04h", 
                     opcode, inA, inB, expected_zero, expected_overflow, expected_alu_out);
            $display("--- RECEIVED VALUE ---");
            $display("opcode = %b \t inA = 16'h%04h \t inB = 16'h%04h \t zero = %b \t overflow = %b \t alu_out = 16'h%04h", 
                     opcode, inA, inB, zero, overflow, alu_out);

            if (alu_out !== expected_alu_out || zero !== expected_zero || overflow !== expected_overflow) begin
                $display("RESULT: FAIL\n");
            end else begin
                $display("RESULT: PASS\n");
            end
        end
    endtask

    initial begin
        inA = {OPCODE_WIDTH + OPERAND_WIDTH{1'b0}}; 
        inB = {OPCODE_WIDTH + OPERAND_WIDTH{1'b0}}; 
        opcode = {OPCODE_WIDTH{1'b0}}; 
        #10;

        // Test 1: SKZ (Zero Flag check - Input Zero)
        inA = 16'h0000; inB = 16'hFFFF; opcode = 4'b0001; 
        #5;
        print_result("Test 1", 16'h0000, 1'b1, 1'b0); 

        // Test 2: SKZ (Zero Flag check - Input Non-Zero)
        inA = 16'h1234; inB = 16'hFFFF; opcode = 4'b0001; 
        #5;
        print_result("Test 2", 16'h1234, 1'b0, 1'b0); 
        
        // Test 3: ADD (Normal Operation)
        opcode = 4'b0010; inA = 16'h00F0; inB = 16'h0010; 
        #5;
        print_result("Test 3", 16'h0100, 1'b0, 1'b0); 

        // Test 4: ADD (Overflow Condition)
        opcode = 4'b0010; inA = 16'h7FFF; inB = 16'h0001; 
        #5;
        print_result("Test 4", 16'h8000, 1'b0, 1'b1); 

        // Test 5: AND (Bitwise)
        opcode = 4'b0011; inA = 16'hF0F0; inB = 16'hAAAA; 
        #5;
        print_result("Test 5", 16'hA0A0, 1'b0, 1'b0); 

        // Test 6: XOR (Bitwise)
        opcode = 4'b0100; inA = 16'hF0F0; inB = 16'hAAAA; 
        #5;
        print_result("Test 6", 16'h5A50, 1'b0, 1'b0); 

        // Test 7: LDA (Load A)
        opcode = 4'b0101; inA = 16'h1234; inB = 16'hABCD; 
        #5;
        print_result("Test 7", 16'hABCD, 1'b0, 1'b0); 

        // Test 8: HLT (Halt)
        opcode = 4'b0000; inA = 16'h1234; inB = 16'hABCD; 
        #5;
        print_result("Test 8", 16'h1234, 1'b0, 1'b0); 

        // Test 9: STO (Store)
        opcode = 4'b0110; inA = 16'h1234; inB = 16'hABCD; 
        #5;
        print_result("Test 9", 16'h1234, 1'b0, 1'b0); 

        // Test 10: JMP (Jump)
        opcode = 4'b0111; inA = 16'h1234; inB = 16'hABCD; 
        #5;
        print_result("Test 10", 16'h1234, 1'b0, 1'b0); 

        // Test 11: SUB (Normal Operation)
        opcode = 4'b1000; inA = 16'd150; inB = 16'd50; 
        #5;
        print_result("Test 11", 16'd100, 1'b0, 1'b0); 

        // Test 12: SUB (Overflow Condition)
        opcode = 4'b1000; inA = 16'h8000; inB = 16'h0001; 
        #5;
        print_result("Test 12", 16'h7FFF, 1'b0, 1'b1); 

        // Test 13: OR (Bitwise)
        opcode = 4'b1001; inA = 16'hAA00; inB = 16'h0055; 
        #5;
        print_result("Test 13", 16'hAA55, 1'b0, 1'b0); 

        // Test 14: MUL (Multiply)
        opcode = 4'b1010; inA = 16'd25; inB = 16'd10; 
        #5;
        print_result("Test 14", 16'd250, 1'b0, 1'b0); 

        // Test 15: SHL (Shift Left & check Overflow)
        opcode = 4'b1100; inA = 16'h800F; inB = 16'd0; 
        #5;
        print_result("Test 15", 16'h001E, 1'b0, 1'b1); 

        // Test 16: SHR (Shift Right)
        opcode = 4'b1101; inA = 16'h000F; inB = 16'd0; 
        #5;
        print_result("Test 16", 16'h0007, 1'b0, 1'b0); 

        // Test 17: NOT (Bitwise)
        opcode = 4'b1110; inA = 16'h5555; inB = 16'h0000; 
        #5;
        print_result("Test 17", 16'hAAAA, 1'b0, 1'b0); 

        // Test 18: SKO (Skip on Overflow Check)
        opcode = 4'b1111; inA = 16'h00FF; inB = 16'h0000; 
        #5;
        print_result("Test 18", 16'h00FF, 1'b0, 1'b0); 

        $finish;
    end

endmodule