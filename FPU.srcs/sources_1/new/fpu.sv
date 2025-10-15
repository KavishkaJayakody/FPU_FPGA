`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2025 10:52:52 PM
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
import types_pkg::*;

module fpu #(parameter WORD_WIDTH = 32, parameter EXP_WIDTH = 8, MANT_WIDTH = 23)(

    input logic [WORD_WIDTH-1:0] num_a,
    input logic [WORD_WIDTH-1:0] num_b,
    input logic clk,
    //input logic en,   due to IO pin constrains removed for implementation. en signal is manually fiven as always high below
    //input logic rstn,
    input op_state_t op, // 00 for add, 01 for sub, 10 for mult
    output logic [WORD_WIDTH-1:0] result,
    output logic done  

    );
    
    logic en = 1'b1;//due to IO pin constrains en signal is manually given as always high
    logic rstn = 1'b1;
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
        .op(add_sub_op),
        .mant_out(mant_sum),
        .exp_out(exp_sum),
        .sign_out(sign_sum),
        .clk(clk),
        .rst_n(rstn),
        .en(addsub_en),
        .ready(addsub_ready)
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
        .en(mult_en),
        .ready(mult_ready)
    );
    // normalize result selecting addsub or mult
    logic [MANT_WIDTH:0] mant_normalized;
    logic [EXP_WIDTH-1:0] exp_normalized;
    logic [MANT_WIDTH+1:0] mant_to_normalize;
    logic [EXP_WIDTH-1:0] exp_to_normalize;
    logic sign_out;
    op_state_t data_path;
    
    always_comb begin
        if ((data_path == 2'b00) || (data_path == 2'b01)) begin
            mant_to_normalize = mant_sum;
            exp_to_normalize    = exp_sum;
            sign_out = sign_sum;
            end
        else if (data_path == 2'b10) begin
            mant_to_normalize = mant_mult;
            exp_to_normalize = exp_mult;
            sign_out = sign_mult;
            end
        else begin
            mant_to_normalize = {(MANT_WIDTH+1){1'b0}};
            exp_to_normalize = {EXP_WIDTH{1'b0}};
            end
    end
    normalize #(EXP_WIDTH, MANT_WIDTH) normalize (
        .mant_in(mant_to_normalize), // 0 for div (not implemented)
        .exp_in(exp_to_normalize),   // 0 for div (not implemented)
        .mant_out(mant_normalized),
        .exp_out(exp_normalized),
        .clk(clk),
        .rst_n(rstn),
        .en(normalize_en),
        .ready(normalize_ready)
    );
    // pack result
    pack #(WORD_WIDTH, EXP_WIDTH, MANT_WIDTH) pack (
        .sign(sign_out),
        .exp(exp_normalized),
        .mant(mant_normalized),
        .result(result),
        .clk(clk),
        .rst_n(rstn),
        .en(pack_en),
        .ready(pack_ready )
    );      
    // control logic
    //op_state_t data_path;
    fpu_control_unit fpu_control_unit (
        .clk(clk),
        .en(en),
        .op(op),
        .rst_n(rstn),
        .unpack_ready(unpack_ready),
        .align_ready(align_ready),
        .addsub_ready(addsub_ready),
        .add_sub_op(add_sub_op),
        .mult_ready(mult_ready),
        .data_path(data_path),
        .normalize_ready(normalize_ready),
        .pack_ready(pack_ready),
        .unpack_en(unpack_en),
        .align_en(align_en),
        .addsub_en(addsub_en),
        .mult_en(mult_en),
        .normalize_en(normalize_en),
        .pack_en(pack_en),
        .done(done)
    );
endmodule
