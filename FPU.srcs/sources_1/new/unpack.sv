module unpack #(
    parameter WORD_WIDTH        = 32,
    parameter EXP_WIDTH         = 8,
    parameter MANT_WIDTH        = 23
)(
    input   logic [WORD_WIDTH-1:0] num_a,
    input   logic [WORD_WIDTH-1:0] num_b,
    input   logic clk,
    input   logic rst_n,
    input   logic en,
    output  logic ready,
    output  logic sign_a,
    output  logic sign_b,
    output  logic [EXP_WIDTH-1:0] exp_a,
    output  logic [EXP_WIDTH-1:0] exp_b,
    output  logic [MANT_WIDTH:0]  mant_a, // includes hidden bit
    output  logic [MANT_WIDTH:0]  mant_b
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sign_a <= 0;
            sign_b <= 0;    
            exp_a  <= 0;
            exp_b  <= 0;
            mant_a <= 0;
            mant_b <= 0;
            ready <= 0;
        end else if (en) begin
            ready <= 1;
            sign_a <= num_a[WORD_WIDTH-1];
            sign_b <= num_b[WORD_WIDTH-1];        
            exp_a  <= num_a[WORD_WIDTH-2 -: EXP_WIDTH];
            exp_b  <= num_b[WORD_WIDTH-2 -: EXP_WIDTH];
            mant_a <= {num_a[WORD_WIDTH-2 -: EXP_WIDTH]!=8'b0, num_a[MANT_WIDTH-1:0]}; // add hidden bit
            mant_b <= {num_b[WORD_WIDTH-2 -: EXP_WIDTH]!=8'b0, num_b[MANT_WIDTH-1:0]}; // add hidden bit
        end else begin
            ready <= 0;     
        end
    end 

endmodule
