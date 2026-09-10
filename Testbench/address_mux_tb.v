`timescale 1ns / 1ps

module tb_address_mux();

parameter OPCODE_WIDTH = 4;
parameter OPERAND_WIDTH = 12;

reg sel;
reg [OPERAND_WIDTH - 1:0] pc_addr;
reg [OPERAND_WIDTH - 1:0] op_addr;
wire [OPERAND_WIDTH - 1:0] addr_out;

address_mux #(.OPCODE_WIDTH(OPCODE_WIDTH), .OPERAND_WIDTH(OPERAND_WIDTH)) uut (
    .sel(sel),
    .pc_addr(pc_addr),
    .op_addr(op_addr),
    .addr_out(addr_out)
);

task print_result;
    input [63:0] test_name;
    input expected_sel;
    input [OPERAND_WIDTH - 1:0] expected_pc_addr;
    input [OPERAND_WIDTH - 1:0] expected_op_addr;
    input [OPERAND_WIDTH - 1:0] expected_addr_out;
    begin
        $display("");
            $display("--- %s ---", test_name);
            $display("--- EXPECTED VALUE ---");
            $display("sel = %b \t pc_addr = 12'h%03h \t op_addr = 12'h%03h \t addr_out = 12'h%03h",
                     expected_sel, expected_pc_addr, expected_op_addr, expected_addr_out);
            $display("--- RECEIVED VALUE ---");
            $display("sel = %b \t pc_addr = 12'h%03h \t op_addr = 12'h%03h \t addr_out = 12'h%03h",
                     sel, pc_addr, op_addr, addr_out);

            if (addr_out !== expected_addr_out) begin
                $display("RESULT: FAIL\n");
            end else begin
                $display("RESULT: PASS\n");
            end
        end
    endtask

    initial begin
        sel     = 0;
        pc_addr = 12'h000;
        op_addr = 12'h000;

        // Test 1: sel = 1
        pc_addr = 12'h00A;
        op_addr = 12'h019;
        sel     = 1'b1;
        #1;
        print_result("Test 1", 1'b1, 12'h00A, 12'h019, 12'h00A);

        // Test 2: sel = 0
        sel = 1'b0;
        #1;
        print_result("Test 2", 1'b0, 12'h00A, 12'h019, 12'h019);

        // Test 3
        pc_addr = 12'h003;
        op_addr = 12'h011;

        sel = 1'b1; #1;
        print_result("Test 3.1", 1'b1, 12'h003, 12'h011, 12'h003);

        sel = 1'b0; #1;
        print_result("Test 3.2", 1'b0, 12'h003, 12'h011, 12'h011);

        sel = 1'b1; #1;
        print_result("Test 3.3", 1'b1, 12'h003, 12'h011, 12'h003);

        sel = 1'b0; #1;
        print_result("Test 3.4", 1'b0, 12'h003, 12'h011, 12'h011);

        // Test 4
        sel     = 1'b1;
        op_addr = 12'h009;

        pc_addr = 12'h001; #1;
        print_result("Test 4.1", 1'b1, 12'h001, 12'h009, 12'h001);

        pc_addr = 12'h00C; #1;
        print_result("Test 4.2", 1'b1, 12'h00C, 12'h009, 12'h00C);

        pc_addr = 12'h01F; #1;
        print_result("Test 4.3", 1'b1, 12'h01F, 12'h009, 12'h01F);

        // Test 5
        sel     = 1'b0;
        pc_addr = 12'h006;

        op_addr = 12'h002; #1;
        print_result("Test 5.1", 1'b0, 12'h006, 12'h002, 12'h002);

        op_addr = 12'h00E; #1;
        print_result("Test 5.2", 1'b0, 12'h006, 12'h00E, 12'h00E);

        op_addr = 12'h01E; #1;
        print_result("Test 5.3", 1'b0, 12'h006, 12'h01E, 12'h01E);

        $finish;
    end

endmodule