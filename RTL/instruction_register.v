`timescale 1ns / 1ps

module instruction_register #(parameter WIDTH = 9) (
    input wire clk,
    input wire rst,
    input wire ld_ir,
    input wire [WIDTH - 1:0] data,
    output reg [3:0] opcode,
    output reg [WIDTH - 5:0] addr
);

    reg [WIDTH - 1:0] ir_reg;

    always @(posedge clk) begin
        if (rst) begin
            ir_reg <= 0; 
        end else if (ld_ir) begin
            ir_reg <= data;        
        end
    end

    always @(*) begin
        opcode = ir_reg[WIDTH - 1:WIDTH - 4]; 
        addr   = ir_reg[WIDTH - 5:0]; 
    end

endmodule