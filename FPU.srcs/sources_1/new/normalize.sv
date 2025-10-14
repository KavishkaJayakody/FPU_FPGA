`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2025 06:29:26 PM
// Design Name: 
// Module Name: normalize
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


module normalize #(parameter EXP_WIDTH = 8, parameter MANT_WIDTH=23)(
    input logic [MANT_WIDTH+1:0] mant_in,
    input logic [EXP_WIDTH-1:0] exp_in,
    input logic clk,
    input logic rst_n,
    input logic en,
    output logic ready,
    output logic [MANT_WIDTH:0] mant_out,
    output logic [EXP_WIDTH-1:0] exp_out

    );
    logic [MANT_WIDTH-1:0] shift_amount;
    logic [MANT_WIDTH:0] mant_shifted;
    shift_counter #(MANT_WIDTH) sc (.in(mant_in[MANT_WIDTH:0]), .out(shift_amount));
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mant_out    <= 0;
            exp_out     <= 0;
            ready       <= 0;
            end else if (en) begin
                ready <= 1;
                if (mant_in[MANT_WIDTH+1]) begin // overflow case
                    mant_out    <= mant_in[MANT_WIDTH+1:1]; // shift right by 1
                    exp_out     <= exp_in + 1;
                end else if (mant_in == 0) begin // zero case
                    mant_out    <= 0;
                    exp_out     <= 0;
                end else begin // normal case
                    mant_shifted <= mant_in << shift_amount;
                    mant_out    <= mant_shifted[MANT_WIDTH:0];
                    exp_out     <= exp_in - shift_amount;
                end
            end else begin
                ready <= 0;
            end

    end   
    

endmodule

module shift_counter #(
    parameter MANT_WIDTH = 23
)(
    input  logic [MANT_WIDTH:0] in,
    output logic [$clog2(MANT_WIDTH)-1:0] out
);

    always_comb begin
        out = '0; // default output
        for (int i = 0; i <= MANT_WIDTH; i++) begin
            if (in[MANT_WIDTH-i]) begin
                out = i;
                break; 
            end
        end
    end

endmodule