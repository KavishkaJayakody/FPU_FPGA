`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2025 01:14:41 AM
// Design Name: 
// Module Name: synchronus_addsub_tb
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


module synchronus_mult_tb();
    parameter WORD_WIDTH = 32;
    parameter EXP_WIDTH = 8;
    parameter MANT_WIDTH = 23;

    logic clk;
    logic rstn;
    logic en;
    //logic op; // 0 for add, 1 for sub
    logic [WORD_WIDTH-1:0] num_a, num_b;
    logic [WORD_WIDTH-1:0] result;

    // Instantiate the FPU
    fpu_mult #(
        .WORD_WIDTH(WORD_WIDTH),
        .EXP_WIDTH(EXP_WIDTH),
        .MANT_WIDTH(MANT_WIDTH)
    ) dut (
        .num_a(num_a),
        .num_b(num_b),
        .clk(clk),
        .en(en),
        .rstn(rstn),
        //.op(op),
        .result(result)
    );

    // Clock generation: 100 MHz
    initial clk = 0;
    always #5 clk = ~clk;

    // Reset task
    task reset_dut();
    begin
        rstn = 0;
        repeat (5) @(posedge clk);
        rstn = 1;
        @(posedge clk);
    end
    endtask

    // Generate floating-point number with long fractional bits
    function logic [WORD_WIDTH-1:0] gen_long_fraction(input integer seed);
        logic [WORD_WIDTH-1:0] val;
        begin
            // sign=0, exponent=127 (bias), random mantissa bits
            val[31] = 0; 
            val[30:23] = 127;
            val[22:0] = $urandom(seed) & ((1 << MANT_WIDTH) - 1);
            gen_long_fraction = val;
        end
    endfunction

    initial begin
        reset_dut();


        num_a = gen_long_fraction(101);
        num_b = gen_long_fraction(202);
        en = 1;
        @(posedge clk);

        // Wait for pipeline latency
        repeat (25) @(posedge clk);

        num_a = gen_long_fraction(303);
        num_b = gen_long_fraction(404);
        en = 1;
        @(posedge clk);

        repeat (25) @(posedge clk);

        $finish;
    end

    // Monitor outputs
    always @(posedge clk) begin
        if (rstn) begin
            $display("Time %t |  | result=%h", $time, result);
        end
    end

endmodule
