`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2025 09:32:31 PM
// Design Name: 
// Module Name: pack
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pack #(parameter WORD_WIDTH = 32,parameter EXP_WIDTH = 8, parameter MANT_WIDTH = 23)(
    input logic sign,
    input logic [EXP_WIDTH-1:0] exp,
    input logic [MANT_WIDTH:0] mant,
    input logic clk,
    input logic rst_n,
    input logic en,
    output logic ready,
    output logic [WORD_WIDTH-1:0] result    
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            result  <= WORD_WIDTH==32?32'h7F800001:WORD_WIDTH==16?16'h7C01:WORD_WIDTH==64?64'h7FF0000000000001:0; // default NaN
        else if (en) begin
            ready   <= 1;
            result  <= {sign, exp, mant[MANT_WIDTH-1:0]};
        end else begin
            ready   <= 0; 
        end
    end
 
endmodule
