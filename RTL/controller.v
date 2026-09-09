`timescale 1ns / 1ps
module controller (
    input clk, rst, [3:0] opcode, zero, overflow,
    output reg sel, rd, ld_ir, halt, inc_pc, ld_ac, ld_pc, wr, data_e
);
    // OPCODE
    localparam HLT = 4'b0000;
    localparam SKZ = 4'b0001;
    localparam ADD = 4'b0010;
    localparam AND = 4'b0011;
    localparam XOR = 4'b0100;
    localparam LDA = 4'b0101;
    localparam STO = 4'b0110;
    localparam JMP = 4'b0111;
    
    localparam SUB = 4'b1000;
    localparam OR  = 4'b1001;
    localparam MUL = 4'b1010;
    localparam MAC = 4'b1011;
    localparam SHL = 4'b1100;
    localparam SHR = 4'b1101;
    localparam NOT = 4'b1110;
    localparam SKO = 4'b1111;

    // STATE
    localparam INST_ADDR  = 3'd0;
    localparam INST_FETCH = 3'd1;
    localparam INST_LOAD  = 3'd2;
    localparam IDLE       = 3'd3;
    localparam OP_ADDR    = 3'd4;
    localparam OP_FETCH   = 3'd5;
    localparam ALU_OP     = 3'd6;
    localparam STORE      = 3'd7;

    reg [2:0] state = INST_ADDR;
    reg [2:0] next_state;

    // STATE REGISTER
    always @(posedge clk) begin
        if(rst)
            state <= INST_ADDR;
        else
            state <= next_state; 
    end
    
    // NEXT STATE LOGIC
    always @(*) begin
        case(state)
            INST_ADDR: next_state = INST_FETCH;
            INST_FETCH: next_state = INST_LOAD;
            INST_LOAD: next_state = IDLE;
            IDLE: next_state = OP_ADDR;
            OP_ADDR: begin
                if (opcode == HLT)
                    next_state = OP_ADDR;
                else
                    next_state = OP_FETCH;
            end
            OP_FETCH: next_state = ALU_OP;
            ALU_OP: next_state = STORE;
            STORE: next_state = INST_ADDR;
            
            default: next_state = INST_ADDR;
        endcase
    end
    // OUTPUT LOGIC
    always @(*) begin
        sel = 0;
        rd = 0;
        ld_ir = 0;
        halt = 0;
        inc_pc = 0;
        ld_ac = 0;
        ld_pc = 0;
        wr = 0;
        data_e = 0;

        case(state)
            INST_ADDR: sel = 1;
            INST_FETCH: 
                begin
                    sel = 1;
                    rd = 1;
                end 
            INST_LOAD:  
                begin
                    sel = 1;
                    rd = 1;
                    ld_ir = 1;
                end
            IDLE:
                begin
                    sel = 1;
                    rd = 1;
                    ld_ir = 1;
                end
            OP_ADDR:
                begin
                    if (opcode == HLT) halt = 1;
                    else inc_pc = 1;
                end
            OP_FETCH:
                begin
                    case(opcode)
                        ADD, AND, XOR, LDA, SUB,
                        OR, MUL, MAC, SHL, SHR: rd = 1;
                        default: ;
                    endcase
                end
            ALU_OP:
                begin
                    case(opcode)
                        ADD, AND, XOR, LDA, SUB,
                        OR, MUL, MAC, SHL, SHR: rd = 1;
                        SKZ: if (zero) inc_pc = 1;
                        SKO: if (overflow) inc_pc = 1;
                        JMP: ld_pc = 1;
                        STO: data_e = 1;
                    endcase
                end
            STORE:
                begin
                    case(opcode)
                        ADD, AND, XOR, LDA, SUB,
                        OR, MUL, MAC, SHL, SHR, NOT: 
                            begin
                                rd = 1;
                                ld_ac = 1;
                            end
                        JMP:ld_pc = 1;
                        STO:
                            begin
                                wr = 1;
                                data_e = 1;
                            end
                    endcase
                end
        endcase
    end
endmodule