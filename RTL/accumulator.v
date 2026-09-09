`timescale 1ns / 1ps

module accumulator #(parameter WIDTH = 16) (
    input clk, rst, ld_ac, overflow_in,
    input [WIDTH - 1:0] data_in,
    output reg [WIDTH - 1:0] ac_out = 0,
    output reg overflow_out = 0
    );
    
    always @(posedge clk) begin
        if (rst) begin
            ac_out <= 0;
            overflow_out <= 0;
        end
        else if (ld_ac) begin
                ac_out <= data_in;
                overflow_out <= overflow_in;
            end
        else ac_out <= ac_out;
    end
endmodule