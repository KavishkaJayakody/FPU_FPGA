`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2025 09:47:28 PM
// Design Name: 
// Module Name: fpu_tb
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


module fpu_tb;

  parameter WORD_WIDTH = 32;
  parameter EXP_WIDTH = 8;
  parameter MANT_WIDTH = 23;

  logic [WORD_WIDTH-1:0] num_a, num_b;
  logic op; // 0 for add, 1 for sub
  logic [WORD_WIDTH-1:0] result;

  // Instantiate the FPU module
  fpu #(WORD_WIDTH, EXP_WIDTH, MANT_WIDTH) uut (
    .num_a(num_a),
    .num_b(num_b),
    .op(op),
    .result(result)
  );

  initial begin
    $display("Time(ns)  Operation                 num_a       num_b       Result");

    // Test 1: Add 1.0 + 2.0
    num_a = 32'h3F800000; // 1.0
    num_b = 32'h40000000; // 2.0
    op = 0;
    #5;
    $display("%0t ns  Add 1.0 + 2.0       = 0x%h + 0x%h = 0x%h", $time, num_a, num_b, result);

    // Test 2: Subtract 5.5 - 3.0
    num_a = 32'h40B00000; // 5.5
    num_b = 32'h40400000; // 3.0
    op = 1;
    #5;
    $display("%0t ns  Sub 5.5 - 3.0       = 0x%h - 0x%h = 0x%h", $time, num_a, num_b, result);

    // Test 3: Add 10.0 + 0.25
    num_a = 32'h41200000; // 10.0
    num_b = 32'h3E800000; // 0.25
    op = 0;
    #5;
    $display("%0t ns  Add 10.0 + 0.25     = 0x%h + 0x%h = 0x%h", $time, num_a, num_b, result);

    // Test 4: Subtract 7.75 - 2.25
    num_a = 32'h40F80000; // 7.75
    num_b = 32'h40100000; // 2.25
    op = 1;
    #5;
    $display("%0t ns  Sub 7.75 - 2.25     = 0x%h - 0x%h = 0x%h", $time, num_a, num_b, result);

    // Test 5: Add 0.5 + 0.5
    num_a = 32'h3F000000; // 0.5
    num_b = 32'h3F000000; // 0.5
    op = 0;
    #5;
    $display("%0t ns  Add 0.5 + 0.5       = 0x%h + 0x%h = 0x%h", $time, num_a, num_b, result);

    // Test 6: Add 3.14159 + 2.71828 (approximate pi + e)
    num_a = 32'h40490FDB; // approx 3.14159
    num_b = 32'h402DF854; // approx 2.71828
    op = 0;
    #5;
    $display("%0t ns  Add Pi + e          = 0x%h + 0x%h = 0x%h", $time, num_a, num_b, result);

    // Test 7: Subtract 123.456 - 78.9
    num_a = 32'h42F6E979; // approx 123.456
    num_b = 32'h42F115C3; // approx 78.9
    op = 1;
    #5;
    $display("%0t ns  Sub 123.456 - 78.9  = 0x%h - 0x%h = 0x%h", $time, num_a, num_b, result);

    // Test 8: Add 0.125 + 0.875
    num_a = 32'h3E000000; // 0.125
    num_b = 32'h3F600000; // 0.875
    op = 0;
    #5;
    $display("%0t ns  Add 0.125 + 0.875   = 0x%h + 0x%h = 0x%h", $time, num_a, num_b, result);

    $finish;
  end

endmodule
