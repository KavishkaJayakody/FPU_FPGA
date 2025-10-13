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
    output logic [WORD_WIDTH-1:0] result    
    );
    assign result = {sign, exp, mant[MANT_WIDTH-1:0]};
endmodule
