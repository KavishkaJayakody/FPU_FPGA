`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2025 07:22:14 PM
// Design Name: 
// Module Name: four_bit_adder_tb
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


`timescale 1ns/1ps
module four_bit_adder_tb;

    // Testbench signals
    reg [3:0] a;
    reg [3:0] b;
    wire [4:0] sum;

    // Instantiate the DUT (Device Under Test)
    four_bit_adder uut (
        .a(a),
        .b(b),
        .sum(sum)
    );

    initial begin
        // Display header
        $display("Time\tA\tB\tSum");
        $monitor("%0dns\t%b\t%b\t%b", $time, a, b, sum);

        // Test cases
        a = 4'b0000; b = 4'b0000; #10;
        a = 4'b0001; b = 4'b0010; #10;
        a = 4'b0101; b = 4'b0011; #10;
        a = 4'b1111; b = 4'b0001; #10;
        a = 4'b1010; b = 4'b0101; #10;

        // End simulation
        $stop;
    end

endmodule

