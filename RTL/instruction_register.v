`timescale 1ns / 1ps

module instruction_register #(parameter INSTRUCTION_WIDTH = 16, OPCODE_WIDTH = 4) (
    input wire clk,
    input wire rst,
    input wire ld_ir,
    input wire [INSTRUCTION_WIDTH - 1:0] data,
    output reg [OPCODE_WIDTH - 1:0] opcode,
    output reg [INSTRUCTION_WIDTH - OPCODE_WIDTH - 1:0] addr
);

    reg [INSTRUCTION_WIDTH - 1:0] ir_reg;

    always @(posedge clk) begin
        if (rst) begin
            ir_reg <= 0; 
        end else if (ld_ir) begin
            ir_reg <= data;        
        end
    end

    always @(*) begin
        opcode = ir_reg[INSTRUCTION_WIDTH - 1:INSTRUCTION_WIDTH - OPCODE_WIDTH]; 
        addr   = ir_reg[INSTRUCTION_WIDTH - OPCODE_WIDTH - 1:0]; 
    end

endmodule