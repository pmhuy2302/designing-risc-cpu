`timescale 1ns / 1ps

module tb_instruction_register;
    parameter WIDTH = 9;
    parameter ADDR_WIDTH = 5;

    reg clk;
    reg rst;
    reg ld_ir;
    reg [WIDTH-1:0] data;
    wire [3:0] opcode;
    wire [ADDR_WIDTH-1:0] addr;

    instruction_register #(.WIDTH(WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) uut (
        .clk(clk), .rst(rst), .ld_ir(ld_ir),
        .data(data), .opcode(opcode), .addr(addr)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1; ld_ir = 0; data = 9'b0; #25; 
        
        $display("--- Test 1: System Reset ---");
        rst = 0; #15;
        $display("--- EXPECTED VALUE ---\nopcode = 0000 \t addr = 00000\n");
        $display("--- RECEIVED VALUE ---\nopcode = %b \t addr = %b\n", opcode, addr);

        $display("--- Test 2: Load ADD Instruction ---");
        data = 9'b0010_11011; ld_ir = 1; #20;
        $display("--- EXPECTED VALUE ---\nopcode = 0010 \t addr = 11011\n");
        $display("--- RECEIVED VALUE ---\nopcode = %b \t addr = %b\n", opcode, addr);

        $display("--- Test 3: Hold Instruction ---");
        ld_ir = 0; data = 9'b1111_00001; #20;
        $display("--- EXPECTED VALUE ---\nopcode = 0010 \t addr = 11011\n");
        $display("--- RECEIVED VALUE ---\nopcode = %b \t addr = %b\n", opcode, addr);

        $display("--- Test 4: Load LDA Instruction ---");
        ld_ir = 1; data = 9'b1010_00100; #20;
        $display("--- EXPECTED VALUE ---\nopcode = 1010 \t addr = 00100\n");
        $display("--- RECEIVED VALUE ---\nopcode = %b \t addr = %b\n", opcode, addr);

        #20; $display("Mo phong khoi Instruction Register hoan tat."); $finish;
    end
endmodule