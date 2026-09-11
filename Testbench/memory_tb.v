`timescale 1ns / 1ps

module tb_memory;
    
    parameter OPCODE_WIDTH = 4;
    parameter OPERAND_WIDTH = 12;

    reg clk;
    reg [OPERAND_WIDTH - 1:0] addr;
    reg rd;
    reg wr;
    wire [OPCODE_WIDTH + OPERAND_WIDTH - 1:0] data;
    reg [OPCODE_WIDTH + OPERAND_WIDTH - 1:0] tb_data_reg;

    assign data = (wr) ? tb_data_reg : {OPCODE_WIDTH + OPERAND_WIDTH{1'bz}};

    memory #(
        .OPCODE_WIDTH(OPCODE_WIDTH),
        .OPERAND_WIDTH(OPERAND_WIDTH)
    ) uut (
        .clk(clk),
        .addr(addr),
        .rd(rd),
        .wr(wr),
        .data(data)
    );

    always #5 clk = ~clk;

    task print_result;
        input [64:0] test_name;
        input expected_rd;
        input expected_wr;
        input [OPERAND_WIDTH - 1:0] expected_addr;
        input [OPCODE_WIDTH + OPERAND_WIDTH - 1:0] expected_data;
        begin
            $display("");
            $display("--- %s ---", test_name);
            $display("--- EXPECTED VALUE ---");
            $display("rd = %b \t wr = %b \t addr = 12'h%03h \t data = 16'h%04h",
                     expected_rd, expected_wr, expected_addr, expected_data);
            $display("--- RECEIVED VALUE ---");
            $display("rd = %b \t wr = %b \t addr = 12'h%03h \t data = 16'h%04h",
                     rd, wr, addr, data);

            if (data !== expected_data) begin
                $display("RESULT: FAIL\n");
            end else begin
                $display("RESULT: PASS\n");
            end
        end
    endtask

    initial begin
        clk = 0; 
        addr = {OPERAND_WIDTH{1'b0}}; 
        rd = 0; 
        wr = 0; 
        tb_data_reg = {OPCODE_WIDTH + OPERAND_WIDTH{1'b0}};
        #25; 

        // Test 1: Write Data
        addr = 12'h007; 
        tb_data_reg = 16'h1234; 
        wr = 1; 
        rd = 0; 
        #20; 
        wr = 0;
        print_result("Test 1", 1'b0, 1'b1, 12'h007, 16'h1234);

        // Test 2: Read Data
        addr = 12'h007; 
        rd = 1; 
        wr = 0; 
        #20; 
        print_result("Test 2", 1'b1, 1'b0, 12'h007, 16'h1234);

        #20; 
        $finish;
    end

endmodule