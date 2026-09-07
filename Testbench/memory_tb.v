`timescale 1ns / 1ps

module tb_memory;
    parameter WIDTH = 9;
    reg clk;
    reg [WIDTH-5:0] addr;
    reg rd;
    reg wr;
    wire [7:0] data;
    reg [7:0] tb_data_reg;

    assign data = (wr) ? tb_data_reg : 8'bz;

    memory #(.WIDTH(WIDTH)) uut (
        .clk(clk),
        .addr(addr),
        .rd(rd),
        .wr(wr),
        .data(data)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; addr = 4'b0; rd = 0; wr = 0; tb_data_reg = 8'b0;
        #25; 

        $display("--- Test 1: Write Data to Memory ---");
        addr = 4'd7; tb_data_reg = 8'hA5; wr = 1; rd = 0; #20; wr = 0;
        $display("--- EXPECTED VALUE ---\nStatus = Writing complete to addr 7\n");
        $display("--- RECEIVED VALUE ---\naddr = %d \t data_input = %h \t wr = %b\n", addr, tb_data_reg, wr);

        $display("--- Test 2: Read Data from Memory ---");
        addr = 4'd7; rd = 1; wr = 0; #20; 
        $display("--- EXPECTED VALUE ---\naddr = 7 \t data_bus = A5\n");
        $display("--- RECEIVED VALUE ---\naddr = %d \t data_bus = %h\n", addr, data);

        #20; $finish;
    end
endmodule