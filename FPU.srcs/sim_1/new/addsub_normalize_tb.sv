`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/11/2025 03:22:44 PM
// Design Name: 
// Module Name: addsub_normalize_tb
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


module addsub_normalize_tb();

    localparam EXP_WIDTH = 8;
    localparam MANT_WIDTH = 23;

    logic [EXP_WIDTH-1:0] exp_a_aligned, exp_b_aligned,exp_c;
    logic sign_a, sign_b, ADD;
    logic [MANT_WIDTH-1:0] mant_a_aligned, mant_b_aligned;
    logic sign_c;
    logic [MANT_WIDTH-1:0] mant_c;

    addsub_normalize #(
        .EXP_WIDTH(EXP_WIDTH),
        .MANT_WIDTH(MANT_WIDTH)
    ) dut (
        .exp_a_aligned  (exp_a_aligned),
        .exp_b_aligned  (exp_b_aligned),
        .sign_a         (sign_a),
        .sign_b         (sign_b),
        .mant_a_aligned (mant_a_aligned),
        .mant_b_aligned (mant_b_aligned),
        .ADD            (ADD),
        .sign_c         (sign_c),
        .exp_c_normalized          (exp_c),
        .mant_c_normalized         (mant_c)
    );

    initial begin
        // Simple addition: same sign
        exp_a_aligned = 8'd100;
        exp_b_aligned = 8'd100;
        sign_a = 1'b0;
        sign_b = 1'b0;
        mant_a_aligned = 23'h700000;
        mant_b_aligned = 23'h100000;
        ADD = 1'b1;
        #10;
        $display("Add ++: sign_c=%b exp_c=%d mant_c=%d", sign_c,exp_c, mant_c);

        // Addition: both negative
        sign_a = 1'b1;
        sign_b = 1'b1;
        #10;
        $display("Add --: sign_c=%b exp_c=%d mant_c=%d", sign_c,exp_c, mant_c);

        // Subtraction: a > b
        sign_a = 1'b0;
        sign_b = 1'b0;
        mant_a_aligned = 23'h500000;
        mant_b_aligned = 23'h200000;
        ADD = 1'b0;
        #10;
        $display("Sub ++ (a>b): sign_c=%b exp_c=%d mant_c=%d", sign_c,exp_c, mant_c);

        // Subtraction: b > a
        mant_a_aligned = 23'h200000;
        mant_b_aligned = 23'h500000;
        #10;
        $display("Sub ++ (b>a): sign_c=%b exp_c=%d mant_c=%d", sign_c,exp_c, mant_c);

        // Addition: opposite signs (equivalent to subtraction)
        sign_a = 1'b0;
        sign_b = 1'b1;
        mant_a_aligned = 23'h600000;
        mant_b_aligned = 23'h100000;
        ADD = 1'b1;
        #10;
        $display("Add +-: sign_c=%b exp_c=%d mant_c=%d", sign_c,exp_c, mant_c);

        // Subtraction: opposite signs (equivalent to addition)
        sign_a = 1'b1;
        sign_b = 1'b0;
        mant_a_aligned = 23'h400000;
        mant_b_aligned = 23'h200000;
        ADD = 1'b0;
        #10;
        $display("Sub -+: sign_c=%b exp_c=%d mant_c=%d", sign_c,exp_c, mant_c);

        $stop;
    end

endmodule

