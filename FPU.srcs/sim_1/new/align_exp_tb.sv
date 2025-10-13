`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UoM
// Engineer: Kavishka Jayakody
// 
// Create Date: 10/10/2025 11:56:12 PM
// Design Name: 
// Module Name: align_exp_tb
// Project Name: FPU
// Target Devices: Zybo
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
/////////////////////////////////////////////////////////////////////////////////
module tb_align_exp;

    // Inputs
    logic [7:0] exp_a;
    logic [7:0] exp_b;
    logic [23:0] mant_a;
    logic [23:0] mant_b;

    // Outputs
    logic [7:0] exp_a_aligned;
    logic [7:0] exp_b_aligned;
    logic [23:0] mant_a_aligned;
    logic [23:0] mant_b_aligned;

    // Instantiate the module
    
    
    align_exp uut (
        .exp_a(exp_a),
        .exp_b(exp_b),
        .mant_a(mant_a),
        .mant_b(mant_b),
        .exp_a_aligned(exp_a_aligned),
        .exp_b_aligned(exp_b_aligned),
        .mant_a_aligned(mant_a_aligned),
        .mant_b_aligned(mant_b_aligned)
    );

    initial begin
        // Test case 1: exp_a > exp_b
        exp_a = 8'd130;
        exp_b = 8'd120;
        mant_a = 24'hFFFFFF;
        mant_b = 24'hAAAAAA;
        #10;
        $display("Test case 1: exp_a > exp_b");
        $display("exp_a_aligned = %d, exp_b_aligned = %d", exp_a_aligned, exp_b_aligned);
        $display("mant_a = %b, mant_b = %b", mant_a, mant_b);
        $display("mant_a = %b, mant_b = %b", mant_a_aligned, mant_b_aligned);

        // Test case 2: exp_b > exp_a
        exp_a = 8'd100;
        exp_b = 8'd110;
        mant_a = 24'h123456;
        mant_b = 24'h654321;
        #10;
        $display("Test case 2: exp_b > exp_a");
        $display("exp_a_aligned = %d, exp_b_aligned = %d", exp_a_aligned, exp_b_aligned);
        $display("mant_a = %b, mant_b = %b", mant_a, mant_b);
        $display("mant_a = %b, mant_b = %b", mant_a_aligned, mant_b_aligned);

        // Test case 3: exp_a == exp_b
        exp_a = 8'd50;
        exp_b = 8'd50;
        mant_a = 24'h0F0F0F;
        mant_b = 24'hF0F0F0;
        #10;
        $display("Test case 3: exp_a == exp_b");
        $display("exp_a_aligned = %d, exp_b_aligned = %d", exp_a_aligned, exp_b_aligned);
        $display("mant_a = %b, mant_b = %b", mant_a, mant_b);
        $display("mant_a = %b, mant_b = %b", mant_a_aligned, mant_b_aligned);
        $stop;
    end

endmodule
