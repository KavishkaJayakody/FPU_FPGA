`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2025 10:22:46 AM
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

module fpu_tb();
    localparam WORD_WIDTH = 32;
    localparam EXP_WIDTH  = 8;
    localparam MANT_WIDTH = 23;

    logic clk;
    logic rstn;
    logic en;
    logic [1:0] op;
    logic [WORD_WIDTH-1:0] num_a, num_b, result;
    logic done;

    // Device Under Test
    fpu #(
        .WORD_WIDTH(WORD_WIDTH),
        .EXP_WIDTH(EXP_WIDTH),
        .MANT_WIDTH(MANT_WIDTH)
    ) dut (
        .num_a(num_a),
        .num_b(num_b),
        .clk(clk),
        //.en(en),  //removed due to IO constrains
        //s.rstn(rstn),
        .op(op),
        .result(result),
        .done(done)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Reset logic
    initial begin
        rstn = 0;
        repeat (4) @(posedge clk);
        rstn = 1;
    end

    // Construct normalized IEEE754 numbers
    function [WORD_WIDTH-1:0] gen_fp(input logic sign, input logic [EXP_WIDTH-1:0] exp, input logic [MANT_WIDTH-1:0] frac);
        gen_fp = {sign, exp, frac};
    endfunction

    logic [WORD_WIDTH-1:0] numbers [0:7];
    initial begin
        // Compose a mix of positive and negative, normalized numbers with long fractional parts
        // Example: sign, exponent, mantissa
        numbers[0] = gen_fp(1'b0,  8'd127, 23'h400_000); // +1.5
        numbers[1] = gen_fp(1'b1,  8'd127, 23'h600_000); // -1.75
        numbers[2] = gen_fp(1'b0,  8'd128, 23'h200_000); // +2.5
        numbers[3] = gen_fp(1'b1,  8'd128, 23'h3C0_000); // -2.94...
        numbers[4] = gen_fp(1'b0,  8'd129, 23'h150_000); // +4.3125
        numbers[5] = gen_fp(1'b1,  8'd129, 23'h500_000); // -5.25
        numbers[6] = gen_fp(1'b0,  8'd130, 23'h380_000); // +12.75
        numbers[7] = gen_fp(1'b1,  8'd130, 23'h420_000); // -16.25
    end

    // Test sequence: ADD, SUB, MUL (positive and negative pairs)
    initial begin
        en   = 0;   
        //@(posedge rstn);

        // SUB +1.5 + -1.75 = -0.25
        op    = 2'b01; en = 1;
        num_a = numbers[0]; // +1.5
        num_b = numbers[1]; // -1.75
        @(negedge done);

        // SUB +2.5 - -2.94 = 5.44...
        op    = 2'b01;
        num_a = numbers[2]; // +2.5
        num_b = numbers[3]; // -2.94
        @(negedge done);

        // MUL -5.25 * +4.3125 = -22.64...
        op    = 2'b10;
        num_a = numbers[5]; // -5.25
        num_b = numbers[4]; // +4.3125
        @(negedge done);

        // ADD -16.25 + +12.75 = -3.5
        op    = 2'b00;
        num_a = numbers[7]; // -16.25
        num_b = numbers[6]; // +12.75
        @(negedge done);

        // SUB -2.94 - +1.5 = -4.44...
        op    = 2'b01;
        num_a = numbers[3]; // -2.94
        num_b = numbers[0]; // +1.5
        @(negedge done);

        // MUL -1.75 * -1.75 = +3.0625 (negative*negative=positive)
        op    = 2'b10;
        num_a = numbers[1]; // -1.75
        num_b = numbers[1]; // -1.75
        @(negedge done);

        en = 0;
        repeat (25) @(posedge clk);

        $finish;
    end

    // Print result after each op
    always @(posedge clk) begin
        if (rstn && en) begin
            case (op)
                2'b00: $display("[%0t] ADD : %h + %h = %h", $time, num_a, num_b, result);
                2'b01: $display("[%0t] SUB : %h - %h = %h", $time, num_a, num_b, result);
                2'b10: $display("[%0t] MUL : %h * %h = %h", $time, num_a, num_b, result);
                default: ;
            endcase
        end
    end
endmodule
