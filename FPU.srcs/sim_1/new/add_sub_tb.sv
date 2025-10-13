`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2025 06:07:44 PM
// Design Name: 
// Module Name: add_sub_tb
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


module add_sub_tb;

  parameter WORD_WIDTH = 32;
  parameter EXP_WIDTH = 8;
  parameter MANT_WIDTH = 23;

  logic [EXP_WIDTH-1:0] exp;
  logic [MANT_WIDTH:0] mant_a, mant_b;
  logic sign_a, sign_b;
  logic op; // 0 for add, 1 for sub
  logic [MANT_WIDTH+1:0] mant_out;
  logic sign_out;

  // Instantiate the add_sub module
  add_sub #(
    .WORD_WIDTH(WORD_WIDTH),
    .EXP_WIDTH(EXP_WIDTH),
    .MANT_WIDTH(MANT_WIDTH)
  ) uut (
    .exp(exp),
    .mant_a(mant_a),
    .mant_b(mant_b),
    .sign_a(sign_a),
    .sign_b(sign_b),
    .op(op),
    .mant_out(mant_out),
    .sign_out(sign_out)
  );

  initial begin
    // Test 1: Add same sign mantissas
    exp = 8'h7F; // example exponent
    mant_a = 24'h400000; // 0x400000 (binary 0100 0000 0000 0000 0000 0000) - arbitrary mantissa
    mant_b = 24'h400000;
    sign_a = 0;
    sign_b = 0;
    op = 0; // add
    #10;
    $display("Test 1 - Add same signs: mant_out = 0x%h, sign_out = %b", mant_out, sign_out);

    // Test 2: Add different sign mantissas with mant_a > mant_b
    mant_a = 24'h500000;
    mant_b = 24'h400000;
    sign_a = 0;
    sign_b = 1;
    op = 0; // add but signs differ effectively subtract
    #10;
    $display("Test 2 - Add different signs mant_a > mant_b: mant_out = 0x%h, sign_out = %b", mant_out, sign_out);

    // Test 3: Add different sign mantissas with mant_b > mant_a
    mant_a = 24'h300000;
    mant_b = 24'h400000;
    sign_a = 0;
    sign_b = 1;
    op = 0;
    #10;
    $display("Test 3 - Add different signs mant_b > mant_a: mant_out = 0x%h, sign_out = %b", mant_out, sign_out);

    // Test 4: Add different sign mantissas but equal mantissas (result zero)
    mant_a = 24'h400000;
    mant_b = 24'h400000;
    sign_a = 0;
    sign_b = 1;
    op = 0;
    #10;
    $display("Test 4 - Add different signs equal mantissas: mant_out = 0x%h, sign_out = %b", mant_out, sign_out);

    // Test 5: Subtraction (op = 1) with same signs should behave like addition
    mant_a = 24'h400000;
    mant_b = 24'h100000;
    sign_a = 0;
    sign_b = 0;
    op = 1; 
    #10;
    $display("Test 5 - Subtraction op=1 same signs: mant_out = 0x%h, sign_out = %b", mant_out, sign_out);

    // Test 6: Subtraction with different signs
    mant_a = 24'h400000;
    mant_b = 24'h100000;
    sign_a = 0;
    sign_b = 1;
    op = 1;
    #10;
    $display("Test 6 - Subtraction op=1 different signs: mant_out = 0x%h, sign_out = %b", mant_out, sign_out);

    $finish;
  end

endmodule

