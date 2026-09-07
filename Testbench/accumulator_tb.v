`timescale 1ns / 1ps

module accumulator_tb;
    parameter WIDTH = 9;

    reg clk, rst, ld_ac;
    reg [WIDTH - 1:0] data_in; 
    wire [WIDTH - 1:0] ac_out;
    
    accumulator #(.WIDTH(WIDTH)) uut (
        .clk(clk), .rst(rst), .ld_ac(ld_ac),
        .ac_out(ac_out), .data_in(data_in)
    );
                     
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin 
        rst = 0; ld_ac = 0;
        data_in = {WIDTH{1'b0}}; #15;
        
        // test sync reset
        $display("----- SYSTEM RESET -----");
        rst = 1; ld_ac = 0; #20;
        data_in = 9'b0_0101_0101;
        $display("---EXPECTED VALUE---");
        $display("rst = 1 | ld_ac = 0 | data_in = 001010101 | ac_out = 000000000");
        
        $display("---RECEIVED VALUE---");
        $display("rst = %b | ld_ac = %b | data_in = %b | ac_out = %b", 
                  rst, ld_ac, data_in, ac_out);
        $display(""); #5; 
        
        ld_ac = 0; rst = 0; #3;
        
        // test ld_ac
        $display("----- Load Data -----");
        data_in = 9'b01111_0000; #3;
        ld_ac = 1; #10;
        $display("---EXPECTED VALUE---");
        $display("rst = 0 | ld_ac = 1 | data_in = 011110000 | ac_out = 011110000 --- LOAD SUCCESSFULLY"); 
        
        $display("---RECEIVED VALUE---");
        $display("rst = %b | ld_ac = %b | data_in = %b | ac_out = %b", 
                  rst, ld_ac, data_in, ac_out);
        $display(""); #5;
        
        ld_ac = 0; #3; 
        
        data_in = 9'b01010_1100; #10;
        $display("---EXPECTED VALUE---");
        $display("rst = 0 | ld_ac = 0 | data_in = 010101100 | ac_out = 011110000 --- LOAD UNSUCCESSFULLY");
        
        $display("---RECEIVED VALUE---");
        $display("rst = %b | ld_ac = %b | data_in = %b | ac_out = %b", 
                  rst, ld_ac, data_in, ac_out);
        $display(""); #3;
        
        $display("----- RESET PRIORITY CHECK -----");
        ld_ac = 1;
        
        rst = 1; #15;
        $display("---EXPECTED VALUE---");
        $display("rst = 1 | ld_ac = 1 | data_in = 010101100 | ac_out = 000000000 --- RESET DURING LOAD");
        
        $display("---RECEIVED VALUE---");
        $display("rst = %b | ld_ac = %b | data_in = %b | ac_out = %b", 
                  rst, ld_ac, data_in, ac_out);
        $display(""); #5;
        
        $display("--- DONE ---");
        $finish;
        
    end
endmodule