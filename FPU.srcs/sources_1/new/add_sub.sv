`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2025 10:03:38 PM
// Design Name: 
// Module Name: fpu_add_sub
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


module add_sub #(parameter WORD_WIDTH=32,parameter EXP_WIDTH=8, parameter MANT_WIDTH=23)(
    input logic [EXP_WIDTH-1:0]exp,
    input logic [MANT_WIDTH:0]mant_a,
    input logic [MANT_WIDTH:0]mant_b,
    input logic sign_a,
    input logic sign_b,
    input logic op, // 0 for add, 1 for sub
    output logic [MANT_WIDTH+1:0]mant_out,
    output logic [EXP_WIDTH-1:0]exp_out,
    output logic sign_out
    //output logic overflow,
    );
    assign exp_out = exp;
    
    always_comb begin
        if (sign_a == sign_b^op) begin
            mant_out = mant_a + mant_b;
            sign_out = sign_a;
        end else begin
            if (mant_a > mant_b) begin
                mant_out = mant_a - mant_b;
                sign_out = sign_a;
            end else if (mant_b > mant_a) begin
                mant_out = mant_b - mant_a;
                sign_out = sign_b;
            end else begin
                mant_out = 0;
                sign_out = 0; // result is zero, sign can be either
            end
        end
    end

endmodule


