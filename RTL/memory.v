`timescale 1ns / 1ps

module memory #(parameter OPCODE_WIDTH = 4, OPERAND_WIDTH = 12) (
    input wire clk,
    input wire [OPERAND_WIDTH - 1:0] addr,
    input wire rd,
    input wire wr,
    inout wire [OPCODE_WIDTH + OPERAND_WIDTH - 1:0] data
);

    reg [OPCODE_WIDTH + OPERAND_WIDTH - 1:0] ram [0: (1 << OPERAND_WIDTH) - 1];
    reg [OPCODE_WIDTH + OPERAND_WIDTH - 1:0] data_out;
    
    always @(posedge clk) begin
        if (wr && !rd) begin
            ram[addr] <= data;
        end
    end

    always @(posedge clk) begin
        if (rd && !wr) begin
            data_out <= ram[addr];
        end
    end

    assign data = (rd) ? data_out : {OPCODE_WIDTH + OPERAND_WIDTH{1'bz}};

endmodule