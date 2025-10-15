`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2025 09:36:09 PM
// Design Name: 
// Module Name: fpu
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


module fpu_add_sub #(parameter WORD_WIDTH = 32, parameter EXP_WIDTH = 8, MANT_WIDTH = 23)(

    input logic [WORD_WIDTH-1:0] num_a,
    input logic [WORD_WIDTH-1:0] num_b,
    input logic clk,
    input logic en,
    input logic rstn,
    input logic op, // 0 for add, 1 for sub
    output logic [WORD_WIDTH-1:0] result    

    );
    // unpack
    logic sign_a, sign_b;
    logic [EXP_WIDTH-1:0] exp_a, exp_b;
    logic [MANT_WIDTH:0] mant_a, mant_b; // includes hidden bit
    unpack #(WORD_WIDTH, EXP_WIDTH, MANT_WIDTH) unpack (
        .num_a(num_a),
        .num_b(num_b),
        .sign_a(sign_a),
        .sign_b(sign_b),
        .exp_a(exp_a),
        .exp_b(exp_b),
        .mant_a(mant_a),
        .mant_b(mant_b),
        .clk(clk),
        .rst_n(rstn),
        .en(unpack_en),   
        .ready(unpack_ready)
    );
    
    logic [MANT_WIDTH:0] mant_a_aligned, mant_b_aligned;
    logic [EXP_WIDTH-1:0] exp_a_aligned, exp_b_aligned;
    // align exponents
    align_exp #(EXP_WIDTH, MANT_WIDTH) align_exp (
        .exp_a(exp_a),
        .exp_b(exp_b),
        .mant_a(mant_a),
        .mant_b(mant_b),
        .exp_a_aligned(exp_a_aligned),
        .exp_b_aligned(exp_b_aligned),
        .mant_a_aligned(mant_a_aligned),
        .mant_b_aligned(mant_b_aligned),
        .clk(clk),
        .rst_n(rstn),
        .en(align_en),
        .ready(align_ready)
    );
    // add or subtract mantissas
    logic [MANT_WIDTH+1:0] mant_sum; // extra bit for overflow
    logic [EXP_WIDTH-1:0] exp_sum;
    logic sign_sum;
    add_sub #(WORD_WIDTH, EXP_WIDTH, MANT_WIDTH) add_sub (
        .exp(exp_a_aligned),
        .mant_a(mant_a_aligned),
        .mant_b(mant_b_aligned),
        .sign_a(sign_a),
        .sign_b(sign_b),
        .op(op),
        .mant_out(mant_sum),
        .exp_out(exp_sum),
        .sign_out(sign_sum),
        .clk(clk),
        .rst_n(rstn),
        .en(addsub_en),
        .ready(addsub_ready)
    );
    // normalize result
    logic [MANT_WIDTH:0] mant_normalized;
    logic [EXP_WIDTH-1:0] exp_normalized;
    normalize #(EXP_WIDTH, MANT_WIDTH) normalize (
        .mant_in(mant_sum),
        .exp_in(exp_sum),
        .mant_out(mant_normalized),
        .exp_out(exp_normalized),
        .clk(clk),
        .rst_n(rstn),
        .en(normalize_en),
        .ready(normalize_ready)
    );
    // pack result
    pack #(WORD_WIDTH, EXP_WIDTH, MANT_WIDTH) pack (
        .sign(sign_sum),
        .exp(exp_normalized),
        .mant(mant_normalized),
        .result(result),
        .clk(clk),
        .rst_n(rstn),
        .en(pack_en),
        .ready(pack_ready )
    );      
    // control logic

    add_sub_control_unit control_unit (
        .clk(clk),
        .en(en),
        .rst_n(rstn),
        .unpack_ready(unpack_ready),
        .align_ready(align_ready),
        .addsub_ready(addsub_ready),
        .normalize_ready(normalize_ready),
        .pack_ready(pack_ready),
        .unpack_en(unpack_en),
        .align_en(align_en),
        .addsub_en(addsub_en),
        .normalize_en(normalize_en),
        .pack_en(pack_en)
    );
endmodule
