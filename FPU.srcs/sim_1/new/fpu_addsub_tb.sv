`timescale 1ns / 1ps

module fpu_addsub_tb;

    // ----------------------------
    // Parameters (match DUT)
    // ----------------------------
    localparam EXP_WIDTH  = 8;
    localparam MANT_WIDTH = 23;
    localparam NUM_WIDTH  = 32;

    // ----------------------------
    // DUT signals
    // ----------------------------
    logic clk;
    logic rst_n;
    logic start;
    logic [NUM_WIDTH-1:0] A, B;
    logic ADD;                // 1 = add, 0 = sub
    logic [NUM_WIDTH-1:0] C;
    logic done;

    // ----------------------------
    // Instantiate DUT
    // ----------------------------
    fpu_addsub #(
        .EXP_WIDTH(EXP_WIDTH),
        .MANT_WIDTH(MANT_WIDTH),
        .NUM_WIDTH(NUM_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .A(A),
        .B(B),
        .ADD(ADD),
        .C(C),
        .done(done)
    );

    // ----------------------------
    // Clock generation (100 MHz)
    // ----------------------------
    initial clk = 0;
    always #5 clk = ~clk;  // 10 ns period

    // ----------------------------
    // Reset task
    // ----------------------------
    task reset_dut;
        begin
            rst_n = 0;
            start = 0;
            A = 0;
            B = 0;
            ADD = 1;
            #50;
            rst_n = 1;
            #20;
        end
    endtask

    // ----------------------------
    // Apply one test case
    // ----------------------------
    task run_case(input real a_val, input real b_val, input bit add_op);
        real expected;
        begin
            // convert real -> IEEE 754 (32-bit)
            A = $realtobits(a_val);
            B = $realtobits(b_val);
            ADD = add_op;

            start = 1;
            @(posedge clk);
            start = 0;

            // wait for done pulse
            wait(done);
            @(posedge clk);

            // display results
            $display("\n--------------------------------------");
            $display("A      = %f (0x%h)", a_val, A);
            $display("B      = %f (0x%h)", b_val, B);
            $display("Op     = %s", add_op ? "ADD" : "SUB");
            $display("Result = %f (0x%h)", $bitstoreal(C), C);
            if (add_op)
                expected = a_val + b_val;
            else
                expected = a_val - b_val;
            $display("Expected (float) = %f", expected);
            $display("--------------------------------------\n");
        end
    endtask

    // ----------------------------
    // Test sequence
    // ----------------------------
    initial begin
        $display("Starting FPU ADD/SUB Testbench...");
        reset_dut();

        // Test 1: simple addition
        run_case(3.5, 2.25, 1);   // 3.5 + 2.25

        // Test 2: subtraction
        run_case(5.75, 2.5, 0);   // 5.75 - 2.5

        // Test 3: addition of negatives
        run_case(-4.0, 2.0, 1);   // -4.0 + 2.0

        // Test 4: subtraction with negative B
        run_case(1.5, -2.5, 0);   // 1.5 - (-2.5) = 4.0

        // Test 5: small numbers
        run_case(0.001, 0.002, 1);

        // Done
        #100;
        $display("Simulation completed.");
        $finish;
    end

endmodule
