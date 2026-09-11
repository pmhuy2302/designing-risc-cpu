`timescale 1ns / 1ps

module instruction_register #(parameter OPCODE_WIDTH = 4, OPERAND_WIDTH = 12) (
    input wire clk,
    input wire rst,
    input wire ld_ir,
    input wire [OPCODE_WIDTH + OPERAND_WIDTH - 1:0] data,
    output reg [OPCODE_WIDTH - 1:0] opcode,
    output reg [OPERAND_WIDTH - 1:0] addr
);

    reg [OPCODE_WIDTH + OPERAND_WIDTH - 1:0] ir_reg;

    always @(posedge clk) begin
        if (rst) begin
            ir_reg <= {OPCODE_WIDTH + OPERAND_WIDTH{1'b0}}; 
        end else if (ld_ir) begin
            ir_reg <= data;        
        end
    end

    always @(*) begin
        opcode = ir_reg[OPCODE_WIDTH + OPERAND_WIDTH - 1:OPERAND_WIDTH]; 
        addr   = ir_reg[OPERAND_WIDTH - 1:0]; 
    end

endmodule