`timescale 1ns / 1ps

module alu #(parameter WIDTH = 9)(
    input [WIDTH - 1:0] inA, inB,
    input [3:0] opcode,
    output reg [WIDTH - 1:0] alu_out,
    output zero,
    output reg overflow = 0
    );
    
    assign zero = (inA == {WIDTH{1'b0}})?1:0;
        
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
    localparam MULS = 4'b1011;
    localparam SHL = 4'b1100;
    localparam SHR = 4'b1101;
    localparam NOT = 4'b1110;
    localparam SKO = 4'b1111;
    
    wire [WIDTH:0] extSum = {1'b0, inA} + {1'b0, inB};
    wire [WIDTH:0] extSub = {1'b0, inA} - {1'b0, inB};

    
    always @(*) begin
        overflow = 0;
        alu_out = {WIDTH{1'b0}};
        case(opcode)
            HLT: alu_out = inA;
            SKZ: alu_out = inA;
            ADD: begin
                alu_out = inA + inB;
                overflow = (inA[WIDTH - 1] == inB[WIDTH - 1]) && (alu_out[WIDTH - 1] != inA[WIDTH - 1]);
            end
            AND: alu_out = inA & inB;
            XOR: alu_out = inA ^ inB;
            LDA: alu_out = inB;
            STO: alu_out = inA;
            JMP: alu_out = inA;
            SUB: begin
                alu_out = inA - inB;
                overflow = (inA[WIDTH - 1] != inB[WIDTH - 1]) && (alu_out[WIDTH - 1] != inA[WIDTH - 1]);
            end
            OR: alu_out = inA | inB;
            MUL: alu_out = inA * inB;
            MULS: alu_out = $signed (inA) * $signed (inB);
            
            SHL: begin
                alu_out   = inA << 1;
                overflow = inA[WIDTH - 1];
            end
            SHR: begin
                alu_out   = inA >> 1;        
            end
            NOT: alu_out = ~inA;
            SKO: alu_out = inA;
            default: alu_out = 0;
        endcase
    end
      
endmodule