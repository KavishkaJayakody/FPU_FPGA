`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2025 06:53:51 PM
// Design Name: 
// Module Name: normalize_tb
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

module normalize_tb;

  parameter EXP_WIDTH = 8;
  parameter MANT_WIDTH = 23;

  logic [MANT_WIDTH+1:0] mant_in;
  logic [EXP_WIDTH-1:0] exp_in;
  logic [MANT_WIDTH:0] mant_out;
  logic [EXP_WIDTH-1:0] exp_out;

  // Instantiate normalize module
  normalize #(
    .EXP_WIDTH(EXP_WIDTH),
    .MANT_WIDTH(MANT_WIDTH)
  ) uut (
    .mant_in(mant_in),
    .exp_in(exp_in),
    .mant_out(mant_out),
    .exp_out(exp_out)
  );

  initial begin
    // Test 1: Overflow case - MSB set, should shift right, increment exponent
    mant_in = {1'b1, {(MANT_WIDTH+1){1'b0}}};  // Only MSB of mant_in set
    exp_in = 8'd100;
    #10;
    $display("Test 1 Overflow case: mant_in=0x%h, exp_in=%0d -> mant_out=0x%h, exp_out=%0d", mant_in, exp_in, mant_out, exp_out);

    // Test 2: Zero mantissa
    mant_in = 0;
    exp_in = 8'd50;
    #10;
    $display("Test 2 Zero case: mant_in=0x%h, exp_in=%0d -> mant_out=0x%h, exp_out=%0d", mant_in, exp_in, mant_out, exp_out);

    // Test 3: Normal case, left-shift needed
    mant_in = 24'h001000;  // Example with leading set bits needing shift
    exp_in = 8'd120;
    #10;
    $display("Test 3 Normal case (shift): mant_in=0x%h, exp_in=%0d -> mant_out=0x%h, exp_out=%0d", mant_in, exp_in, mant_out, exp_out);

    // Test 4: Normal case no shift
    mant_in = 24'h800000;  // Highest bit of mantissa set
    exp_in = 8'd127;
    #10;
    $display("Test 4 Normal case (no shift): mant_in=0x%h, exp_in=%0d -> mant_out=0x%h, exp_out=%0d", mant_in, exp_in, mant_out, exp_out);

    $finish;
  end

endmodule

