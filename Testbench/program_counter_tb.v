`timescale 1ns / 1ps

module tb_program_counter();

parameter WIDTH = 9;

reg clk;
reg rst;
reg inc_pc;
reg ld_pc;
reg [WIDTH-5:0] data_in;
wire [WIDTH-5:0] pc_out;

integer errors;

program_counter #(.WIDTH(WIDTH)) dut (
    .clk(clk),
    .rst(rst),
    .inc_pc(inc_pc),
    .ld_pc(ld_pc),
    .data_in(data_in),
    .pc_out(pc_out)
);

// Clock period = 10 ns.
always #5 clk = ~clk;

task print_result;
    input [639:0] test_name;
    input expected_rst;
    input expected_inc_pc;
    input expected_ld_pc;
    input [WIDTH-5:0] expected_pc_in;
    input [WIDTH-5:0] expected_pc_out;
    begin
        $display("");
        $display("--- %s ---", test_name);
        $display("--- EXPECTED VALUE ---");
        $display("rst = %b \t inc_pc = %b \t ld_pc = %b \t pc_in = %0d \t pc_out = %0d",
                 expected_rst, expected_inc_pc, expected_ld_pc, expected_pc_in, expected_pc_out);
        $display("--- RECEIVED VALUE ---");
        $display("rst = %b \t inc_pc = %b \t ld_pc = %b \t pc_in = %0d \t pc_out = %0d",
                 rst, inc_pc, ld_pc, data_in, pc_out);

        if (pc_out !== expected_pc_out) begin
            errors = errors + 1;
            $display("RESULT: FAIL");
        end else begin
            $display("RESULT: PASS");
        end
    end
endtask

task apply_and_check;
    input [639:0] test_name;
    input next_rst;
    input next_inc_pc;
    input next_ld_pc;
    input [WIDTH-5:0] next_pc_in;
    input [WIDTH-5:0] expected_pc_out;
    begin
        rst = next_rst;
        inc_pc = next_inc_pc;
        ld_pc = next_ld_pc;
        data_in = next_pc_in;
        @(posedge clk); #1;
        print_result(test_name, next_rst, next_inc_pc, next_ld_pc,
                     next_pc_in, expected_pc_out);
    end
endtask

initial begin
    clk = 1'b0;
    rst = 1'b0;
    inc_pc = 1'b0;
    ld_pc = 1'b0;
    data_in = 9'b000000000;
    errors = 0;

    // Test reset.
    apply_and_check("Test 1: System Reset", 1'b1, 1'b0, 1'b0, 9'b000000000, 9'b000000000);

    // Test inc_pc = 1.
    apply_and_check("Test 2.1: inc_pc = 1 increments PC", 1'b0, 1'b1, 1'b0, 9'b000000000, 9'b000000001);
    apply_and_check("Test 2.2: inc_pc = 1 continues counting", 1'b0, 1'b1, 1'b0, 9'b000000000, 9'b000000010);

    // Test ld_pc = 1.
    apply_and_check("Test 3: ld_pc = 1 loads pc_in", 1'b0, 1'b0, 1'b1, 9'b000010100, 9'b000010100);

    // Test control priority.
    apply_and_check("Test 4: rst has priority over ld_pc and inc_pc", 1'b1, 1'b1, 1'b1, 9'b000000111, 9'b000000000);

    // Test IDLE state.
    apply_and_check("Test 5.1: load PC before IDLE", 1'b0, 1'b0, 1'b1, 9'b000001100, 9'b000001100);
    apply_and_check("Test 5.2: IDLE keeps current PC", 1'b0, 1'b0, 1'b0, 9'b000011010, 9'b000001100);

    // Test wrap-around.
    apply_and_check("Test 6.1: load pc_out = 11111", 1'b0, 1'b0, 1'b1, 9'b000011111, 9'b000011111);
    apply_and_check("Test 6.2: inc_pc wraps 11111 to 00000", 1'b0, 1'b1, 1'b0, 9'b000000000, 9'b000000000);

    // Test jump behavior.
    apply_and_check("Test 7.1: JUMP loads target address", 1'b0, 1'b0, 1'b1, 9'b000010010, 9'b000010010);
    apply_and_check("Test 7.2: PC increments after JUMP", 1'b0, 1'b1, 1'b0, 9'b000000000, 9'b000010011);

    // Test reset during operation.
    apply_and_check("Test 8: reset during counting clears PC", 1'b1, 1'b1, 1'b0, 9'b000000101, 9'b000000000);

    // Test pc_in ignored during increment.
    apply_and_check("Test 9.1: load PC before pc_in ignored test", 1'b0, 1'b0, 1'b1, 9'b000001000, 9'b000001000);
    apply_and_check("Test 9.2: inc_pc counts normally with random pc_in", 1'b0, 1'b1, 1'b0, 9'b000010111, 9'b000001001);

    $display("");
    if (errors == 0) begin
        $display("PROGRAM COUNTER TEST SUMMARY: ALL TESTS PASSED");
    end else begin
        $display("PROGRAM COUNTER TEST SUMMARY: %0d TEST(S) FAILED", errors);
    end

    $finish;
end

endmodule
