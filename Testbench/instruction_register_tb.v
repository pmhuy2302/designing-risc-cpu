`timescale 1ns / 1ps

module tb_instruction_register;
    
    parameter OPCODE_WIDTH = 4;
    parameter OPERAND_WIDTH = 12;

    reg clk, rst, ld_ir;
    reg [OPCODE_WIDTH + OPERAND_WIDTH - 1:0] data;
    wire [OPCODE_WIDTH - 1:0] opcode;
    wire [OPERAND_WIDTH - 1:0] addr;

    instruction_register #(
        .OPCODE_WIDTH(OPCODE_WIDTH), 
        .OPERAND_WIDTH(OPERAND_WIDTH)
    ) uut (
        .clk(clk), 
        .rst(rst), 
        .ld_ir(ld_ir),
        .data(data), 
        .opcode(opcode), 
        .addr(addr)
    );

    task print_result;
        input [64:0] test_name;
        input expected_rst;
        input expected_ld_ir;
        input [OPCODE_WIDTH + OPERAND_WIDTH - 1:0] expected_data;
        input [OPCODE_WIDTH - 1:0] expected_opcode;
        input [OPERAND_WIDTH - 1:0] expected_addr;
        begin
            $display("");
            $display("--- %s ---", test_name);
            $display("--- EXPECTED VALUE ---");
            $display("rst = %b \t ld_ir = %b \t data = 16'h%04h \t opcode = 4'b%04b \t addr = 12'h%03h",
                     expected_rst, expected_ld_ir, expected_data, expected_opcode, expected_addr);
            $display("--- RECEIVED VALUE ---");
            $display("rst = %b \t ld_ir = %b \t data = 16'h%04h \t opcode = 4'b%04b \t addr = 12'h%03h",
                     rst, ld_ir, data, opcode, addr);

            if (opcode !== expected_opcode || addr !== expected_addr) begin
                $display("RESULT: FAIL\n");
            end else begin
                $display("RESULT: PASS\n");
            end
        end
    endtask

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 0; 
        ld_ir = 0; 
        data = {OPCODE_WIDTH + OPERAND_WIDTH{1'b0}}; 
        #20;
        
        // Test 1: System Reset
        rst = 1; ld_ir = 0; data = 16'h201B; 
        #10;
        print_result("Test 1", 1'b1, 1'b0, 16'h201B, 4'b0000, 12'h000);
        
        // Test 2: Load ADD Instruction (Opcode 0010, Addr 01B)
        rst = 0; ld_ir = 1; data = 16'h201B; 
        #10;
        print_result("Test 2", 1'b0, 1'b1, 16'h201B, 4'b0010, 12'h01B);

        // Test 3: Hold Instruction (ld_ir = 0)
        rst = 0; ld_ir = 0; data = 16'hF001; 
        #10;
        print_result("Test 3", 1'b0, 1'b0, 16'hF001, 4'b0010, 12'h01B);

        // Test 4: Load New LDA Instruction (Opcode 1010, Addr 004)
        rst = 0; ld_ir = 1; data = 16'hA004; 
        #10;
        print_result("Test 4", 1'b0, 1'b1, 16'hA004, 4'b1010, 12'h004);
        
        // Test 5: Reset Priority Check (Reset overrides Load)
        rst = 1; ld_ir = 1; data = 16'hB005; 
        #10;
        print_result("Test 5", 1'b1, 1'b1, 16'hB005, 4'b0000, 12'h000);

        $finish;
    end

endmodule