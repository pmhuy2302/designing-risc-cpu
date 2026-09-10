`timescale 1ns / 1ps

module program_counter #(parameter OPCODE_WIDTH = 4, OPERAND_WIDTH = 12) (
    input clk,
    input rst,
    input inc_pc,
    input ld_pc,
    input [OPCODE_WIDTH + OPERAND_WIDTH - 1:0] data_in,
    output reg [OPERAND_WIDTH - 1:0] pc_out
);

    always @(posedge clk)
    begin

        if(rst)
            pc_out <= {OPERAND_WIDTH{1'b0}};

        else if(ld_pc)
            pc_out <= data_in;

        else if(inc_pc)
            pc_out <= pc_out + 1'b1;
    end

endmodule