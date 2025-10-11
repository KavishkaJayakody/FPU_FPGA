`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kavishka Jayakody
// Module: fpu_addsub
// Description: Floating point adder/subtractor (simplified, non-IEEE)
//////////////////////////////////////////////////////////////////////////////////

module fpu_addsub #(
    parameter EXP_WIDTH  = 8,
    parameter MANT_WIDTH = 23,   // for IEEE single precision (1 + 23 = 24 bits incl. hidden bit)
    parameter NUM_WIDTH  = 32
)(
    input  logic [NUM_WIDTH-1:0] A,
    input  logic [NUM_WIDTH-1:0] B,
    input  logic ADD,                     // 1 = ADD, 0 = SUB
    output logic [NUM_WIDTH-1:0] C
);

    // Split fields
    logic sign_a, sign_b;
    logic [EXP_WIDTH-1:0] exp_a, exp_b;
    logic [MANT_WIDTH-1:0] mant_a, mant_b;

    assign sign_a = A[NUM_WIDTH-1];
    assign sign_b = B[NUM_WIDTH-1];
    assign exp_a  = A[NUM_WIDTH-2 -: EXP_WIDTH];
    assign exp_b  = B[NUM_WIDTH-2 -: EXP_WIDTH];
    assign mant_a = A[MANT_WIDTH-1:0];
    assign mant_b = B[MANT_WIDTH-1:0];

    // Aligned signals
    logic [EXP_WIDTH-1:0] exp_a_aligned, exp_b_aligned;
    logic [MANT_WIDTH-1:0] mant_a_aligned, mant_b_aligned;

    // Aligner
    align_exp #(.EXP_WIDTH(EXP_WIDTH), .MANT_WIDTH(MANT_WIDTH)) exp_alligner (
        .exp_a(exp_a),
        .exp_b(exp_b),
        .mant_a(mant_a),
        .mant_b(mant_b),
        .exp_a_aligned(exp_a_aligned),
        .exp_b_aligned(exp_b_aligned),
        .mant_a_aligned(mant_a_aligned),
        .mant_b_aligned(mant_b_aligned)
    );

    // Add/Sub and Normalize
    logic [MANT_WIDTH-1:0] mant_c;
    logic [EXP_WIDTH-1:0] exp_c;
    logic sign_c;

    addsub_normalize #(.EXP_WIDTH(EXP_WIDTH), .MANT_WIDTH(MANT_WIDTH)) addsub_norm (
        .exp_a_aligned(exp_a_aligned),
        .exp_b_aligned(exp_b_aligned),
        .sign_a(sign_a),
        .sign_b(sign_b),
        .mant_a_aligned(mant_a_aligned),
        .mant_b_aligned(mant_b_aligned),
        .ADD(ADD),
        .sign_c(sign_c),
        .exp_c_normalized(exp_c),
        .mant_c_normalized(mant_c)
    );

    // Reconstruct output (not fully normalized)
    assign C = {sign_c, exp_c, mant_c};

endmodule


//----------------------- EXPONENT ALIGNER -----------------------

module align_exp #(
    parameter EXP_WIDTH = 8,
    parameter MANT_WIDTH = 23
)(
    input  logic [EXP_WIDTH-1:0] exp_a,
    input  logic [EXP_WIDTH-1:0] exp_b,
    input  logic [MANT_WIDTH-1:0] mant_a,
    input  logic [MANT_WIDTH-1:0] mant_b,
    output logic [EXP_WIDTH-1:0] exp_a_aligned,
    output logic [EXP_WIDTH-1:0] exp_b_aligned,
    output logic [MANT_WIDTH:0] mant_a_aligned,
    output logic [MANT_WIDTH:0] mant_b_aligned
);
    logic [EXP_WIDTH-1:0] exp_diff;
    logic [MANT_WIDTH:0] temp_mant_a;
    logic [MANT_WIDTH:0] temp_mant_b;
    
    assign temp_mant_a[MANT_WIDTH-1:0] = mant_a;
    assign temp_mant_a[MANT_WIDTH] = 1'b1;
    assign temp_mant_b[MANT_WIDTH-1:0] = mant_b;
    assign temp_mant_b[MANT_WIDTH] = 1'b1;
    
    
    
    always_comb begin
        if (exp_a > exp_b) begin
            exp_diff        = exp_a - exp_b;
            exp_a_aligned   = exp_a;
            exp_b_aligned   = exp_a;
            mant_a_aligned  = temp_mant_a;
            mant_b_aligned  = temp_mant_b >> exp_diff;
        end else begin
            exp_diff        = exp_b - exp_a;
            exp_a_aligned   = exp_b;
            exp_b_aligned   = exp_b;
            mant_a_aligned  = temp_mant_a >> exp_diff;
            mant_b_aligned  = temp_mant_b;
        end
    end
endmodule


//----------------------- ADD/SUB + NORMALIZE -----------------------

module addsub_normalize #(
    parameter EXP_WIDTH = 8,
    parameter MANT_WIDTH = 23
)(
    input  logic [EXP_WIDTH-1:0] exp_a_aligned,
    input  logic [EXP_WIDTH-1:0] exp_b_aligned,
    input  logic sign_a,
    input  logic sign_b,
    input  logic [MANT_WIDTH:0] mant_a_aligned, // One extra bit for carry
    input  logic [MANT_WIDTH:0] mant_b_aligned,
    input  logic ADD,
    output logic sign_c,
    output logic [EXP_WIDTH-1:0] exp_c_normalized,
    output logic [MANT_WIDTH-1:0] mant_c_normalized
);

    logic [EXP_WIDTH-1:0] exp_c;
    logic [MANT_WIDTH+1:0] temp_mant;
    logic [MANT_WIDTH+1:0] temp_mant_a;
    logic [MANT_WIDTH+1:0] temp_mant_b;
    logic mant_a_gt_b;
    logic op_sign_b;
    logic [MANT_WIDTH:0] mant_c_pre_norm;
    logic [EXP_WIDTH-1:0] exp_c_pre_norm;
    logic [$clog2(MANT_WIDTH+1)-1:0] lzc; // leading zero count

    // Priority encoder for counting leading zeros in mantissa
        function automatic [$clog2(MANT_WIDTH+1)-1:0] count_leading_zeros(input logic [MANT_WIDTH:0] v);
            integer i;
            begin
                count_leading_zeros = MANT_WIDTH + 1; // default if all zeros
                for (i = MANT_WIDTH; i >= 0; i = i - 1) begin
                    if (v[i] == 1'b1) begin
                        count_leading_zeros = MANT_WIDTH - i;
                        // Exit the loop early by forcing index i to -1
                        i = -1;
                    end
                end
            end
        endfunction
        

   always_comb begin
            op_sign_b = sign_b ^ (~ADD); // invert sign if subtraction
            mant_a_gt_b = mant_a_aligned > mant_b_aligned;
        
            // Add one extra zero bit for guard
            temp_mant_a = {1'b0, mant_a_aligned};
            temp_mant_b = {1'b0, mant_b_aligned};
        
            exp_c = exp_a_aligned;
            sign_c = 1'b0;
            //temp_mant = '1;
        
            // ADD or SUB
            if (sign_a == op_sign_b) begin
                // same sign -> addition
                temp_mant = temp_mant_a + temp_mant_b;
                sign_c = sign_a;
            end else begin
                // different sign -> subtraction
                if (mant_a_gt_b) begin
                    temp_mant = temp_mant_a - temp_mant_b;
                    sign_c = sign_a;
                end else begin
                    temp_mant = temp_mant_b - temp_mant_a;
                    sign_c = op_sign_b;
                end
            end
        
            // Handle carry/overflow
            if (temp_mant[MANT_WIDTH+1]) begin
                mant_c_pre_norm = temp_mant[MANT_WIDTH+1:1];
                exp_c_pre_norm = exp_c + 1;
            end else begin
                mant_c_pre_norm = temp_mant[MANT_WIDTH:0];
                exp_c_pre_norm = exp_c;
            end
        
            // Normalization stage
            if (mant_c_pre_norm != 0) begin
                lzc = count_leading_zeros(mant_c_pre_norm);
                mant_c_normalized = mant_c_pre_norm << lzc;
                exp_c_normalized = exp_c_pre_norm - lzc;
            end else begin
                // Result is zero
                mant_c_normalized = temp_mant[MANT_WIDTH-1:0];
                exp_c_normalized = '0;
                sign_c = 1'b0;
            end
        end
        
endmodule

