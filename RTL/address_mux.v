`timescale 1ns / 1ps

module address_mux #(parameter OPCODE_WIDTH = 4, OPERAND_WIDTH = 12)(
    input sel,
    input [OPERAND_WIDTH - 1:0] pc_addr,
    input [OPERAND_WIDTH - 1:0] op_addr,
    output [OPERAND_WIDTH - 1:0] addr_out
    );

    assign addr_out = (sel) ? pc_addr : op_addr;

endmodule