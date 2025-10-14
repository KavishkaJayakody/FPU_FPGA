// ----------------------- ALIGN_EXP (combinational) -----------------------
// Takes raw exponent and mantissa (with hidden bit) and outputs aligned exponents
// and aligned mantissas with hidden bit included (width MANT_WIDTH:0).
module align_exp #(
    parameter EXP_WIDTH     = 8,
    parameter MANT_WIDTH    = 23
)(
    input   logic [EXP_WIDTH-1:0]   exp_a,
    input   logic [EXP_WIDTH-1:0]   exp_b,
    input   logic [MANT_WIDTH:0]    mant_a, // raw fraction bits (with hidden bit)
    input   logic [MANT_WIDTH:0]    mant_b,
    input   logic                   clk,
    input   logic                   rst_n,
    input   logic                   en,
    output  logic                   ready,
    output  logic [EXP_WIDTH-1:0]   exp_a_aligned,
    output  logic [EXP_WIDTH-1:0]   exp_b_aligned,
    output  logic [MANT_WIDTH:0]    mant_a_aligned, // includes hidden bit
    output  logic [MANT_WIDTH:0]    mant_b_aligned
);
    logic [EXP_WIDTH-1:0] exp_diff;
    logic [MANT_WIDTH:0] temp_mant_a;
    logic [MANT_WIDTH:0] temp_mant_b;

    // build hidden-bit representation
    always_comb begin
        temp_mant_a[MANT_WIDTH:0] = mant_a;
        temp_mant_b[MANT_WIDTH:0] = mant_b;
    end

    always_ff @(posedge clk, negedge rst_n) begin

        if (!rst_n) begin
            exp_a_aligned   <= 0; 
            exp_b_aligned   <= 0;
            mant_a_aligned  <= 0;
            mant_b_aligned  <= 0;
            ready <= 0;
        end else if (en) begin

            if (exp_a > exp_b) begin
                exp_diff        = exp_a - exp_b;
                exp_a_aligned   <= exp_a;
                exp_b_aligned   <= exp_a;
                mant_a_aligned  <= temp_mant_a;
                ready <= 1;
                // shift right mant_b by exp_diff; if exp_diff >= width, result becomes zero
                if (exp_diff >= (MANT_WIDTH+1))
                    mant_b_aligned <= '0;
                else
                    mant_b_aligned <= temp_mant_b >> exp_diff;
            end else begin
                exp_diff        = exp_b - exp_a;
                exp_a_aligned   <= exp_b;
                exp_b_aligned   <= exp_b;
                mant_b_aligned  <= temp_mant_b;
                ready <= 1;
                // shift right mant_a by exp_diff; if exp_diff >= width, result becomes zero
                if (exp_diff >= (MANT_WIDTH+1))
                    mant_a_aligned <= '0;
                else begin
                    mant_a_aligned <= temp_mant_a >> exp_diff;
                    end
                end
            end else begin
                ready <= 0;
            end 
         end

endmodule
