`timescale 1ns / 1ps

module controller_tb();
    reg clk, rst, zero, carry, overflow;
    reg [3:0] opcode;
    wire sel, rd, ld_ir, halt, inc_pc, ld_ac, ld_pc, wr, data_e;

    controller dut(
        .clk(clk), .rst(rst), .opcode(opcode), 
        .zero(zero), .overflow(overflow),
        .sel(sel), .rd(rd), .ld_ir(ld_ir), .halt(halt),
        .inc_pc(inc_pc), .ld_ac(ld_ac), .ld_pc(ld_pc), .wr(wr), .data_e(data_e)
    );

    always #5 clk = ~clk;
    
    task show_outputs;
        begin
        $display (
        "time = %0t \t opcode = %b \t sel = %b \t rd = %b \t ld_ir = %b \t halt = %b \t inc_pc = %b \t ld_ac = %b \t ld_pc = %b \t wr = %b \t data_e = %b",
        $time,
        opcode, sel, rd, ld_ir, halt, inc_pc, ld_ac, ld_pc, wr,data_e);
        end
    endtask
    
    task run_instruction;
        input [3:0] op;
        input z;
        input c;
        input ov;
        begin
            opcode = op;
            zero = z;
            carry = c;
            overflow = ov;
            repeat(8)
                begin
                    #10;
                    show_outputs();
                end
        end
    endtask
    
    initial begin
        clk = 0;
        rst = 1;
        opcode = 4'b0000;
        zero = 0;
        carry = 0;
        overflow = 0;
        
        $display("TEST 1 : RESET");
        #10;
        show_outputs();
        rst = 0;
        
        $display("TEST 2 : ADD");
        run_instruction(4'b0010,0,0,0);
        
        $display("TEST 3 : SKZ zero=1");
        run_instruction(4'b0001,1,0,0);
        
        $display("TEST 4 : SKZ zero=0");
        run_instruction(4'b0001,0,0,0);
        
        $display("TEST 5 : JMP");
        run_instruction(4'b0111,0,0,0);
        
        $display("TEST 6 : STO");
        run_instruction(4'b0110,0,0,0);
        
        $display("TEST 7 : SUB");
        run_instruction(4'b1000,0,0,0);
        
        $display("TEST 8 : OR");
        run_instruction(4'b1001,0,0,0);
        
        $display("TEST 9 : MUL");
        run_instruction(4'b1010,0,0,0);
        
        $display("TEST 10 : MULS");
        run_instruction(4'b1011,0,0,0);
        
        $display("TEST 11 : SHL");
        run_instruction(4'b1100,0,0,0);
        
        $display("TEST 12 : SHR");
        run_instruction(4'b1101,0,0,0);
        
        $display("TEST 13 : NOT");
        run_instruction(4'b1110,0,0,0);
        
        $display("TEST 14 : SKO overflow=1");
        run_instruction(4'b1111,0,0,1);
        
        $display("TEST 15 : HLT");
        run_instruction(4'b0000,0,0,0);
        
        $display("ALL CONTROLLER TESTS COMPLETED");
        #20; 
        $finish;
    end
endmodule