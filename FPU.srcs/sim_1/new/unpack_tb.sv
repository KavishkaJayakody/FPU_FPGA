`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2025 04:55:00 PM
// Design Name: 
// Module Name: unpack_tb
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


module unpack_tb;

  parameter WORD_WIDTH = 32;
  parameter EXP_WIDTH = 8;
  parameter MANT_WIDTH = 23;

  logic [WORD_WIDTH-1:0] num_a, num_b;
  logic sign_a, sign_b;
  logic [EXP_WIDTH-1:0] exp_a, exp_b;
  logic [MANT_WIDTH:0] mant_a, mant_b;

  // Instantiate the unpack module
  unpack #(
    .WORD_WIDTH(WORD_WIDTH),
    .EXP_WIDTH(EXP_WIDTH),
    .MANT_WIDTH(MANT_WIDTH)
  ) uut (
    .num_a(num_a),
    .num_b(num_b),
    .sign_a(sign_a),
    .sign_b(sign_b),
    .exp_a(exp_a),
    .exp_b(exp_b),
    .mant_a(mant_a),
    .mant_b(mant_b)
  );

  initial begin
    // Test vector 1
    // Example: 1.0 in single-precision floating point 0x3F800000
    num_a = 32'h3F800000; 
    // Example: -2.0 in single-precision floating point 0xC0000000
    num_b = 32'hC0000000; 
    
    #10;
    $display("Test 1:");
    $display("num_a = 0x%h, sign_a = %b, exp_a = 0x%h, mant_a = 0x%h", num_a, sign_a, exp_a, mant_a);
    $display("num_b = 0x%h, sign_b = %b, exp_b = 0x%h, mant_b = 0x%h", num_b, sign_b, exp_b, mant_b);

    // Test vector 2
    // Example: 0.0 (all zero)
    num_a = 32'h00000000; 
    // Example: -0.5 (0xBF000000)
    num_b = 32'hBF000000;

    #10;
    $display("Test 2:");
    $display("num_a = 0x%h, sign_a = %b, exp_a = 0x%h, mant_a = 0x%h", num_a, sign_a, exp_a, mant_a);
    $display("num_b = 0x%h, sign_b = %b, exp_b = 0x%h, mant_b = 0x%h", num_b, sign_b, exp_b, mant_b);
// Test vector 3: Largest normalized positive number
    // Exponent all ones except last bit zero, mantissa all ones (0x7F7FFFFF)
    num_a = 32'h7F7FFFFF; 
    // Smallest normalized negative number (exponent = 1, mantissa all zeros, sign=1)
    num_b = 32'h80800000; 

    #10;
    $display("Test 3:");
    $display("num_a = 0x%h, sign_a = %b, exp_a = 0x%h, mant_a = 0x%h", num_a, sign_a, exp_a, mant_a);
    $display("num_b = 0x%h, sign_b = %b, exp_b = 0x%h, mant_b = 0x%h", num_b, sign_b, exp_b, mant_b);

    // Test vector 4: Positive infinity (exponent all ones, mantissa all zeros)
    num_a = 32'h7F800000; 
    // Negative infinity
    num_b = 32'hFF800000; 

    #10;
    $display("Test 4:");
    $display("num_a = 0x%h, sign_a = %b, exp_a = 0x%h, mant_a = 0x%h", num_a, sign_a, exp_a, mant_a);
    $display("num_b = 0x%h, sign_b = %b, exp_b = 0x%h, mant_b = 0x%h", num_b, sign_b, exp_b, mant_b);

    // Test vector 5: NaN (exponent all ones, non-zero mantissa)
    num_a = 32'h7FC00001; 
    num_b = 32'hFFC00002; 

    #10;
    $display("Test 5:");
    $display("num_a = 0x%h, sign_a = %b, exp_a = 0x%h, mant_a = 0x%h", num_a, sign_a, exp_a, mant_a);
    $display("num_b = 0x%h, sign_b = %b, exp_b = 0x%h, mant_b = 0x%h", num_b, sign_b, exp_b, mant_b);

    // Test vector 6: Denormalized number (exponent zero, mantissa non-zero)
    num_a = 32'h00000001; // Smallest positive denormalized number
    num_b = 32'h80000001; // Smallest negative denormalized number

    #10;
    $display("Test 6:");
    $display("num_a = 0x%h, sign_a = %b, exp_a = 0x%h, mant_a = 0x%h", num_a, sign_a, exp_a, mant_a);
    $display("num_b = 0x%h, sign_b = %b, exp_b = 0x%h, mant_b = 0x%h", num_b, sign_b, exp_b, mant_b);

    $finish;
  end

endmodule

