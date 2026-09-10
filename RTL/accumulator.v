`timescale 1ns / 1ps

module accumulator #(parameter OPCODE_WIDTH = 4, OPERAND_WIDTH = 12) (
    input clk, rst, ld_ac, overflow_in,
    input [OPCODE_WIDTH + OPERAND_WIDTH - 1:0] data_in,
    output reg [OPCODE_WIDTH + OPERAND_WIDTH - 1:0] ac_out = {OPCODE_WIDTH + OPERAND_WIDTH{1'b0}},
    output reg overflow_out = 1'b0
    );
    
    always @(posedge clk) begin
        if (rst) begin
            ac_out <= {OPCODE_WIDTH + OPERAND_WIDTH{1'b0}};
            overflow_out <= 1'b0;
        end
        else if (ld_ac) begin
                ac_out <= data_in;
                overflow_out <= overflow_in;
            end
        else ac_out <= ac_out;
    end
endmodule