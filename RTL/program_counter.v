`timescale 1ns / 1ps

module program_counter #(parameter WIDTH = 9) (
    input clk,
    input rst,
    input inc_pc,
    input ld_pc,
    input [WIDTH - 5:0] data_in,
    output reg [WIDTH - 5:0] pc_out
);

    always @(posedge clk)
    begin

        if(rst)
            pc_out <= 0;

        else if(ld_pc)
            pc_out <= data_in;

        else if(inc_pc)
            pc_out <= pc_out + 1;
    end

endmodule