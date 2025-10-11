`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/11/2025 03:43:22 AM
// Design Name: 
// Module Name: fpu_addsub_tb
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

module fpu_addsub_tb;

    // Parameters (IEEE 754 single precision)
    localparam NUM_WIDTH  = 32;
    localparam EXP_WIDTH  = 8;
    localparam MANT_WIDTH = 23;

    // DUT inputs/outputs
    logic [NUM_WIDTH-1:0] A, B;
    logic ADD;
    logic [NUM_WIDTH-1:0] C;

    // Instantiate the DUT
    fpu_addsub #(
        .EXP_WIDTH(EXP_WIDTH),
        .MANT_WIDTH(MANT_WIDTH),
        .NUM_WIDTH(NUM_WIDTH)
    ) dut (
        .A(A),
        .B(B),
        .ADD(ADD),
        .C(C)
    );

    // Function to print binary and real forms
    function real bits_to_float(input logic [31:0] bits);
        shortreal tmp;
        tmp = $bitstoshortreal(bits);
        return tmp;
    endfunction

    // Task to apply one test vector
    task run_test(input logic [31:0] a_bits, b_bits, input bit add);
        logic [31:0] c_bits;
        begin
            A = a_bits;
            B = b_bits;
            ADD = add;
            #10;
            c_bits = C;
            $display("------------------------------------------------------------");
            $display("A = %b  (%f)", A, bits_to_float(A));
            $display("B = %b  (%f)", B, bits_to_float(B));
            $display("Operation: %s", (ADD ? "ADD" : "SUB"));
            $display("C = %b  (%f)", C, bits_to_float(C));
            $display("------------------------------------------------------------\n");
        end
    endtask

    initial begin
        $display("Starting FPU ADD/SUB Testbench...\n");

        // Wait for initialization
        #5;

        // ===============================
        // Test Cases
        // ===============================

        // 1. 1.0 + 1.0 = 2.0
        run_test(32'h3F800000, 32'h3F800000, 1);

        // 2. 3.0 - 1.0 = 2.0
        run_test(32'h40400000, 32'h3F800000, 0);

        // 3. 2.5 + (-1.25) = 1.25
        run_test(32'h40200000, 32'hBFA00000, 1);

        // 4. -4.0 + 1.5 = -2.5
        run_test(32'hC0800000, 32'h3FC00000, 1);

        // 5. -2.0 - (-2.0) = 0.0
        run_test(32'hC0000000, 32'hC0000000, 0);

        // ===============================
        // End Simulation
        // ===============================
        #10;
        $display("All tests complete.\n");
        $finish;
    end

endmodule

