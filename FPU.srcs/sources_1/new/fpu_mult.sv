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


module fpu_mult #(parameter WORD_WIDTH = 32, parameter EXP_WIDTH = 8, MANT_WIDTH = 23)(

    input logic [WORD_WIDTH-1:0] num_a,
    input logic [WORD_WIDTH-1:0] num_b,
    input logic clk,
    input logic en,
    input logic rstn,
    //input logic op, // 0 for add, 1 for sub
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
    logic [MANT_WIDTH+1:0] mant_mult;
    logic [EXP_WIDTH-1:0] exp_mult;
    logic sign_mult;
    mult #(WORD_WIDTH, EXP_WIDTH, MANT_WIDTH) mult (
        .exp_a(exp_a),
        .exp_b(exp_b),
        .mant_a(mant_a),
        .mant_b(mant_b),
        .sign_a(sign_a),
        .sign_b(sign_b),
        .mant_out(mant_mult),
        .exp_out(exp_mult),
        .sign_out(sign_mult),
        .clk(clk),
        .rst_n(rstn),
        .en(addsub_en),
        .ready(addsub_ready)
    );
    // normalize result
    logic [MANT_WIDTH:0] mant_normalized;
    logic [EXP_WIDTH-1:0] exp_normalized;
    normalize #(EXP_WIDTH, MANT_WIDTH) normalize (
        .mant_in(mant_mult),
        .exp_in(exp_mult),
        .mant_out(mant_normalized),
        .exp_out(exp_normalized),
        .clk(clk),
        .rst_n(rstn),
        .en(normalize_en),
        .ready(normalize_ready)
    );
    // pack result
    pack #(WORD_WIDTH, EXP_WIDTH, MANT_WIDTH) pack (
        .sign(sign_mult),
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
        .align_ready(1'b1), // bypass alignment for multiplication
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
