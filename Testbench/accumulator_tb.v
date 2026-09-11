`timescale 1ns / 1ps

module accumulator_tb;
    
    parameter OPCODE_WIDTH = 4;
    parameter OPERAND_WIDTH = 12;

    reg clk, rst, ld_ac, overflow_in;
    reg [OPCODE_WIDTH + OPERAND_WIDTH - 1:0] data_in; 
    wire [OPCODE_WIDTH + OPERAND_WIDTH - 1:0] ac_out;
    wire overflow_out;
    
    accumulator #(.OPCODE_WIDTH(OPCODE_WIDTH), .OPERAND_WIDTH(OPERAND_WIDTH)) uut (
        .clk(clk),
        .rst(rst),
        .ld_ac(ld_ac),
        .overflow_in(overflow_in),
        .data_in(data_in),
        .ac_out(ac_out),
        .overflow_out(overflow_out)
    );
                      
    task print_result;
        input [64:0] test_name;
        input expected_rst;
        input expected_ld_ac;
        input [OPCODE_WIDTH + OPERAND_WIDTH - 1:0] expected_data_in;
        input [OPCODE_WIDTH + OPERAND_WIDTH - 1:0] expected_ac_out;
        input expected_overflow_out;
        begin
            $display("");
            $display("--- %s ---", test_name);
            $display("--- EXPECTED VALUE ---");
            $display("rst = %b \t ld_ac = %b \t data_in = 16'h%04h \t ac_out = 16'h%04h \t overflow_out = %b",
                     expected_rst, expected_ld_ac, expected_data_in, expected_ac_out, expected_overflow_out);
            $display("--- RECEIVED VALUE ---");
            $display("rst = %b \t ld_ac = %b \t data_in = 16'h%04h \t ac_out = 16'h%04h \t overflow_out = %b",
                     rst, ld_ac, data_in, ac_out, overflow_out);

            if (ac_out !== expected_ac_out || overflow_out !== expected_overflow_out) begin
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
        ld_ac = 0;
        overflow_in = 0;
        data_in = {OPCODE_WIDTH + OPERAND_WIDTH{1'b0}}; 
        #20;
        
        // Test 1: reset
        rst = 1; ld_ac = 0; overflow_in = 0;
        data_in = 16'h0055; 
        #10;
        print_result("Test 1", 1'b1, 1'b0, 16'h0055, 16'h0000, 1'b0); 
        
        // Test 2: load data
        ld_ac = 1; rst = 0; overflow_in = 1;
        data_in = 16'h0F00; 
        #10;
        print_result("Test 2", 1'b0, 1'b1, 16'h0F00, 16'h0F00, 1'b1);
        
        // Test 3: hold data
        ld_ac = 0; overflow_in = 0;
        data_in = 16'h0AC0; 
        #10;
        print_result("Test 3", 1'b0, 1'b0, 16'h0AC0, 16'h0F00, 1'b1);
        
        // Test 4: reset priority
        ld_ac = 1; rst = 1; 
        #10;
        print_result("Test 4", 1'b1, 1'b1, 16'h0AC0, 16'h0000, 1'b0);

        $finish;
    end

endmodule