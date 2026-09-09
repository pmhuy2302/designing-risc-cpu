`timescale 1ns / 1ps

module address_mux #(parameter WIDTH = 16)(
    input sel,
    input [WIDTH-5:0] pc_addr, // -5 because of 4-bit opcode
    input [WIDTH-5:0] op_addr,
    output [WIDTH-5:0] addr_out
    );

    assign addr_out = (sel) ? pc_addr : op_addr;

endmodule