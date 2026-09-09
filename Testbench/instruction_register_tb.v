`timescale 1ns / 1ps

module tb_instruction_register;
    parameter INSTRUCTION_WIDTH = 16;
    parameter OPCODE_WIDTH = 4;

    reg clk;
    reg rst;
    reg ld_ir;
    reg [INSTRUCTION_WIDTH - 1:0] data;
    wire [OPCODE_WIDTH - 1:0] opcode;
    wire [INSTRUCTION_WIDTH - OPCODE_WIDTH - 1:0] addr;

    instruction_register uut (
        .clk(clk), .rst(rst), .ld_ir(ld_ir),
        .data(data), .opcode(opcode), .addr(addr)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1; ld_ir = 0; data = 16'b0; #25; 
        
        $display("--- Test 1: System Reset ---");
        rst = 0; #10;
        $display("--- EXPECTED VALUE ---\nopcode = 0000 \t addr = 000000000000");
        $display("--- RECEIVED VALUE ---\nopcode = %b \t addr = %b", opcode, addr);
        if (opcode == 4'b0000 && addr == 12'b000000000000) 
            $display("PASS!\n");
        else 
            $display("FAIL!\n");
                   
        $display("--- Test 2: Load ADD Instruction ---");
        data = 16'b0010_0000_0001_1011; ld_ir = 1; #10;
        $display("--- EXPECTED VALUE ---\nopcode = 0010 \t addr = 000000011011");
        $display("--- RECEIVED VALUE ---\nopcode = %b \t addr = %b", opcode, addr);
        if (opcode == 4'b0010 && addr == 12'b000000011011) 
            $display("PASS!\n");
        else 
            $display("FAIL!\n");

        $display("--- Test 3: Hold Instruction ---");
        ld_ir = 0; data = 16'b1111_0000_0000_0001; #10;
        $display("--- EXPECTED VALUE ---\nopcode = 0010 \t addr = 000000011011");
        $display("--- RECEIVED VALUE ---\nopcode = %b \t addr = %b", opcode, addr);
        if (opcode == 4'b0010 && addr == 12'b000000011011) 
            $display("PASS!\n");
        else 
            $display("FAIL!\n");

        $display("--- Test 4: Load LDA Instruction ---");
        ld_ir = 1; data = 16'b1010_0000_0000_0100; #10;
        $display("--- EXPECTED VALUE ---\nopcode = 1010 \t addr = 000000000100");
        $display("--- RECEIVED VALUE ---\nopcode = %b \t addr = %b", opcode, addr);
        if (opcode == 4'b1010 && addr == 12'b000000000100) 
            $display("PASS!\n");
        else 
            $display("FAIL!\n");

        #20; $display("IR TEST DONE!"); $finish;
    end
endmodule