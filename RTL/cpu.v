`timescale 1ns / 1ps
module cpu #(parameter OPCODE_WIDTH = 4, OPERAND_WIDTH = 12) (
    input clk, rst,  
    output halt 
    );
    
    wire rd, wr, ld_ir, ld_pc, inc_pc, sel, zero, ld_ac, data_e, old_overflow, new_overflow;
    wire [OPERAND_WIDTH - 1:0] addr, operand, pc_addr;
    wire [OPCODE_WIDTH - 1:0] opcode;
    wire [OPCODE_WIDTH + OPERAND_WIDTH - 1:0] ac_out, alu_out, data_bus;
    
    // Instantiate submodules
    memory mem(
        .clk(clk), .rd(rd), .wr(wr), .addr(addr), 
        .data(data_bus)
    );

    instruction_register ir (
        .clk(clk), .rst(rst), .ld_ir(ld_ir), .data(data_bus), 
        .opcode(opcode), .addr(operand)
    );

    program_counter pc(
        .clk(clk), .rst(rst), .ld_pc(ld_pc), .inc_pc(inc_pc), .data_in(operand), 
        .pc_out(pc_addr)
    );

    address_mux mux(
        .pc_addr(pc_addr), .op_addr(operand), .sel(sel), 
        .addr_out(addr)
    );

    alu ALU(
        .inA(ac_out), .inB(data_bus), .opcode(opcode), 
        .alu_out(alu_out), .zero(zero), .overflow(new_overflow)
    );

    accumulator ac(
        .clk(clk), .rst(rst), .ld_ac(ld_ac), .data_in(alu_out), .overflow_in(new_overflow),
        .ac_out(ac_out), .overflow_out(old_overflow)
    );
    
    controller Controller (
        .clk(clk), .rst(rst), .opcode(opcode), .zero(zero), .overflow(old_overflow),
        .sel(sel), .rd(rd), .ld_ir(ld_ir), .halt(halt), .inc_pc(inc_pc), .ld_ac(ld_ac), .ld_pc(ld_pc), .wr(wr), .data_e(data_e)
    );
    
    // Declare tri-state buffer 
    assign data_bus = (data_e)?ac_out:{OPCODE_WIDTH + OPERAND_WIDTH{1'bz}};
    
endmodule
