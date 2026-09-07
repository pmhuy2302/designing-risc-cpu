`timescale 1ns / 1ps

module memory #(parameter WIDTH = 9) (
    input wire clk,
    input wire [WIDTH - 5:0] addr,
    input wire rd,
    input wire wr,
    inout wire [WIDTH - 1:0] data
);

    reg [WIDTH - 1:0] ram [0: 31];
    reg [WIDTH - 1:0] data_out;
    
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

    assign data = (rd) ? data_out : {WIDTH{1'bz}};

endmodule