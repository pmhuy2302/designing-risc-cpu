`timescale 1ns / 1ps

module accumulator_tb;
    parameter WIDTH = 16;

    reg clk, rst, ld_ac, overflow_in;
    reg [WIDTH - 1:0] data_in; 
    wire [WIDTH - 1:0] ac_out;
    wire overflow_out;
    
    accumulator #(.WIDTH(WIDTH)) uut (
        .clk(clk),
        .rst(rst),
        .ld_ac(ld_ac),
        .overflow_in(overflow_in),
        .data_in(data_in),
        .ac_out(ac_out),
        .overflow_out(overflow_out)
    );
                     
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin 
        rst = 0; 
        ld_ac = 0;
        overflow_in = 0;
        data_in = {WIDTH{1'b0}}; 
        #15;
        
        $display("----- SYSTEM RESET TEST -----");
        rst = 1; ld_ac = 0; overflow_in = 0;
        data_in = 16'h0055; #20;
        $display("---EXPECTED VALUE---");
        $display("rst = 1 | ld_ac = 0 | data_in = 16'h0055 | ac_out = 16'h0000 | overflow = 0");
        $display("---RECEIVED VALUE---");
        $display("rst = %b | ld_ac = %b | data_in = 16'h%04h | ac_out = 16'h%04h | overflow = %b", 
                  rst, ld_ac, data_in, ac_out, overflow_out);
        $display(""); #5; 
        
        $display("----- LOAD DATA TEST -----");
        ld_ac = 1; rst = 0; overflow_in = 1;
        data_in = 16'h0F00; #10;
        $display("---EXPECTED VALUE---");
        $display("rst = 0 | ld_ac = 1 | data_in = 16'h0F00 | ac_out = 16'h0F00 | overflow = 1"); 
        $display("---RECEIVED VALUE---");
        $display("rst = %b | ld_ac = %b | data_in = 16'h%04h | ac_out = 16'h%04h | overflow = %b", 
                  rst, ld_ac, data_in, ac_out, overflow_out);
        $display(""); #5;
        
        $display("----- HOLD DATA TEST (ld_ac = 0) -----");
        ld_ac = 0; overflow_in = 0;
        data_in = 16'h0AC0; #10;
        $display("---EXPECTED VALUE---");
        $display("rst = 0 | ld_ac = 0 | data_in = 16'h0AC0 | ac_out = 16'h0F00 (UNCHANGED)");
        $display("---RECEIVED VALUE---");
        $display("rst = %b | ld_ac = %b | data_in = 16'h%04h | ac_out = 16'h%04h | overflow = %b", 
                  rst, ld_ac, data_in, ac_out, overflow_out);
        $display(""); #5;
        
        $display("----- RESET PRIORITY CHECK -----");
        ld_ac = 1; rst = 1; #10;
        $display("---EXPECTED VALUE---");
        $display("rst = 1 | ld_ac = 1 | data_in = 16'h0AC0 | ac_out = 16'h0000 | overflow = 0");
        $display("---RECEIVED VALUE---");
        $display("rst = %b | ld_ac = %b | data_in = 16'h%04h | ac_out = 16'h%04h | overflow = %b", 
                  rst, ld_ac, data_in, ac_out, overflow_out);
        $display(""); #5;
        
        $display("--- TEST COMPLETE ---");
        $finish;
    end

endmodule