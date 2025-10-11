`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2025 07:20:05 PM
// Design Name: 
// Module Name: four_bit_adder
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


// 4-bit Adder RTL Module
module four_bit_adder (
    input  [3:0] a,    // 4-bit input A
    input  [3:0] b,    // 4-bit input B
    output [4:0] sum   // 5-bit output SUM (to handle carry)
);
    assign sum = a + b;
endmodule

