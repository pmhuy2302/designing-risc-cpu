`timescale 1ns / 1ps

module tb_program_counter();

    parameter OPCODE_WIDTH = 4;
    parameter OPERAND_WIDTH = 12;

    reg clk;
    reg rst;
    reg inc_pc;
    reg ld_pc;
    reg [OPERAND_WIDTH-1:0] data_in;
    wire [OPERAND_WIDTH-1:0] pc_out;

    program_counter #(.WIDTH(OPERAND_WIDTH)) dut (
        .clk(clk),
        .rst(rst),
        .inc_pc(inc_pc),
        .ld_pc(ld_pc),
        .data_in(data_in),
        .pc_out(pc_out)
    );

    always #5 clk = ~clk;

    task print_result;
        input [64:0] test_name;
        input expected_rst;
        input expected_inc_pc;
        input expected_ld_pc;
        input [OPERAND_WIDTH-1:0] expected_pc_in;
        input [OPERAND_WIDTH-1:0] expected_pc_out;
        begin
            $display("");
            $display("--- %s ---", test_name);
            $display("--- EXPECTED VALUE ---");
            $display("rst = %b \t inc_pc = %b \t ld_pc = %b \t pc_in = 12'h%03h \t pc_out = 12'h%03h",
                     expected_rst, expected_inc_pc, expected_ld_pc, expected_pc_in, expected_pc_out);
            $display("--- RECEIVED VALUE ---");
            $display("rst = %b \t inc_pc = %b \t ld_pc = %b \t pc_in = 12'h%03h \t pc_out = 12'h%03h",
                     rst, inc_pc, ld_pc, data_in, pc_out);

            if (pc_out !== expected_pc_out) begin
                $display("RESULT: FAIL\n");
            end else begin
                $display("RESULT: PASS\n");
            end
        end
    endtask

    task apply_and_check;
        input [64:0] test_name;
        input next_rst;
        input next_inc_pc;
        input next_ld_pc;
        input [OPERAND_WIDTH-1:0] next_pc_in;
        input [OPERAND_WIDTH-1:0] expected_pc_out;
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
        data_in = 12'h000;

        #20;

        // Test 1: System Reset
        apply_and_check("Test 1", 1'b1, 1'b0, 1'b0, 12'h000, 12'h000);

        // Test 2: Increment PC
        apply_and_check("Test 2.1", 1'b0, 1'b1, 1'b0, 12'h000, 12'h001);
        apply_and_check("Test 2.2", 1'b0, 1'b1, 1'b0, 12'h000, 12'h002);

        // Test 3: Load PC
        apply_and_check("Test 3", 1'b0, 1'b0, 1'b1, 12'h014, 12'h014);

        // Test 4: Control Priority (Reset overrides load and increment)
        apply_and_check("Test 4", 1'b1, 1'b1, 1'b1, 12'h007, 12'h000);

        // Test 5: IDLE State
        apply_and_check("Test 5.1", 1'b0, 1'b0, 1'b1, 12'h00C, 12'h00C);
        apply_and_check("Test 5.2", 1'b0, 1'b0, 1'b0, 12'h01A, 12'h00C);

        // Test 6: Wrap-around (12-bit max FFF to 000)
        apply_and_check("Test 6.1", 1'b0, 1'b0, 1'b1, 12'hFFF, 12'hFFF);
        apply_and_check("Test 6.2", 1'b0, 1'b1, 1'b0, 12'h000, 12'h000);

        // Test 7: Jump Behavior
        apply_and_check("Test 7.1", 1'b0, 1'b0, 1'b1, 12'h012, 12'h012);
        apply_and_check("Test 7.2", 1'b0, 1'b1, 1'b0, 12'h000, 12'h013);

        // Test 8: Reset During Operation
        apply_and_check("Test 8", 1'b1, 1'b1, 1'b0, 12'h005, 12'h000);

        // Test 9: PC Input Ignored During Increment
        apply_and_check("Test 9.1", 1'b0, 1'b0, 1'b1, 12'h008, 12'h008);
        apply_and_check("Test 9.2", 1'b0, 1'b1, 1'b0, 12'h017, 12'h009);

        $finish;
    end

endmodule