`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2025 01:20:52 PM
// Design Name: 
// Module Name: mult
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


module mult #(parameter WORD_WIDTH=32,parameter EXP_WIDTH=8, parameter MANT_WIDTH=23)(
    input logic [EXP_WIDTH-1:0]exp_a,
    input logic [EXP_WIDTH-1:0]exp_b,
    input logic [MANT_WIDTH:0]mant_a,
    input logic [MANT_WIDTH:0]mant_b,
    input logic sign_a,
    input logic sign_b,
    input logic clk,
    input logic rst_n,
    input logic en,
    output logic ready,
    output logic [MANT_WIDTH+1:0]mant_out,
    output logic [EXP_WIDTH-1:0]exp_out,
    output logic sign_out
    //output logic overflow,
    );
    
    logic [2*MANT_WIDTH+1:0] temp_mant;
    logic [EXP_WIDTH:0]temp_exp;
    logic temp_sign;

    //logic temp_overflow;      
    //assign overflow = temp_overflow;
    //assign temp_overflow = (temp_exp > 8'b11111111) ? 1'b1 : 1'b0;
   assign temp_exp = exp_a + exp_b - {1'b0, {(EXP_WIDTH-1){1'b1}}}; // subtract bias
    assign temp_sign = sign_a ^ sign_b;
    assign temp_mant = mant_a * mant_b; // 24*24 = 48 bits  
    //assign mant_out = (temp_mant[47]) ? temp_mant[46:24] : temp_mant[45:23];
    //assign exp_out = (temp_mant[47]) ? temp_exp + 1 : temp_exp;
    //assign sign_out = temp_sign;          


    
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            mant_out <= 0;
            sign_out <= 0;
            exp_out <= 0;
            ready <= 0;
        end else if (en) begin
            
            mant_out <= temp_mant[2*MANT_WIDTH+1 -:MANT_WIDTH+2];
            sign_out <= temp_sign;
            exp_out <= temp_exp;
            ready <= 1;
        end else begin
            ready <= 0;
        end
        
    end

endmodule
