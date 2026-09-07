`timescale 1ns / 1ps

module tb_address_mux();

parameter WIDTH = 9;

reg sel;
reg [WIDTH-5:0] pc_addr;
reg [WIDTH-5:0] op_addr;
wire [WIDTH-5:0] addr_out;

integer errors;

address_mux #(.WIDTH(WIDTH)) dut (
    .sel(sel),
    .pc_addr(pc_addr),
    .op_addr(op_addr),
    .addr_out(addr_out)
);

task print_result_5;
    input [639:0] test_name;
    input expected_sel;
    input [WIDTH-5:0] expected_pc_addr;
    input [WIDTH-5:0] expected_op_addr;
    input [WIDTH-5:0] expected_addr_out;
    begin
        $display("");
        $display("--- %s ---", test_name);
        $display("--- EXPECTED VALUE ---");
        $display("sel = %b \t pc_addr = %0d \t op_addr = %0d \t addr_out = %0d",
                 expected_sel, expected_pc_addr, expected_op_addr, expected_addr_out);
        $display("--- RECEIVED VALUE ---");
        $display("sel = %b \t pc_addr = %0d \t op_addr = %0d \t addr_out = %0d",
                 sel, pc_addr, op_addr, addr_out);

        if (addr_out !== expected_addr_out) begin
            errors = errors + 1;
            $display("RESULT: FAIL");
        end else begin
            $display("RESULT: PASS");
        end
    end
endtask

initial begin
    errors = 0;

    sel = 0;
    pc_addr = 9'b000000000;
    op_addr = 9'b000000000;

    // Test sel = 1: choose program counter address.
    pc_addr = 9'b000001010;
    op_addr = 9'b000011001;
    sel = 1'b1;
    #1;
    print_result_5("Test 1: sel = 1 selects pc_addr", 1'b1, 9'b000001010, 9'b000011001, 9'b000001010);

    // Test sel = 0: choose operand address.
    sel = 1'b0;
    #1;
    print_result_5("Test 2: sel = 0 selects op_addr", 1'b0, 9'b000001010, 9'b000011001, 9'b000011001);

    // Test sel toggles continuously.
    pc_addr = 9'b000000011;
    op_addr = 9'b000010001;

    sel = 1'b1;
    #1;
    print_result_5("Test 3.1: toggle sel to 1", 1'b1, 9'b000000011, 9'b000010001, 9'b000000011);

    sel = 1'b0;
    #1;
    print_result_5("Test 3.2: toggle sel to 0", 1'b0, 9'b000000011, 9'b000010001, 9'b000010001);

    sel = 1'b1;
    #1;
    print_result_5("Test 3.3: toggle sel back to 1", 1'b1, 9'b000000011, 9'b000010001, 9'b000000011);

    sel = 1'b0;
    #1;
    print_result_5("Test 3.4: toggle sel back to 0", 1'b0, 9'b000000011, 9'b000010001, 9'b000010001);

    // Test sel = 1 while pc_addr changes continuously.
    sel = 1'b1;
    op_addr = 9'b000001001;

    pc_addr = 9'b000000001;
    #1;
    print_result_5("Test 5.1: sel = 1, pc_addr changes", 1'b1, 9'b000000001, 9'b000001001, 9'b000000001);

    pc_addr = 9'b000001100;
    #1;
    print_result_5("Test 5.2: sel = 1, pc_addr changes", 1'b1, 9'b000001100, 9'b000001001, 9'b000001100);

    pc_addr = 9'b000011111;
    #1;
    print_result_5("Test 5.3: sel = 1, pc_addr changes", 1'b1, 9'b000011111, 9'b000001001, 9'b000011111);

    // Test sel = 0 while op_addr changes continuously.
    sel = 1'b0;
    pc_addr = 9'b000000110;

    op_addr = 9'b000000010;
    #1;
    print_result_5("Test 6.1: sel = 0, op_addr changes", 1'b0, 9'b000000110, 9'b000000010, 9'b000000010);

    op_addr = 9'b000001110;
    #1;
    print_result_5("Test 6.2: sel = 0, op_addr changes", 1'b0, 9'b000000110, 9'b000001110, 9'b000001110);

    op_addr = 9'b000011110;
    #1;
    print_result_5("Test 6.3: sel = 0, op_addr changes", 1'b0, 9'b000000110, 9'b000011110, 9'b000011110);

    $display("");
    if (errors == 0) begin
        $display("ADDRESS MUX TEST SUMMARY: ALL TESTS PASSED");
    end else begin
        $display("ADDRESS MUX TEST SUMMARY: %0d TEST(S) FAILED", errors);
    end

    $finish;
end

endmodule