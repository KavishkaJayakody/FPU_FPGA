module unpack #(
    parameter WORD_WIDTH = 32,
    parameter EXP_WIDTH = 8,
    parameter MANT_WIDTH = 23
)(
    input  logic [WORD_WIDTH-1:0] num_a,
    input  logic [WORD_WIDTH-1:0] num_b,
    output logic sign_a,
    output logic sign_b,
    output logic [EXP_WIDTH-1:0] exp_a,
    output logic [EXP_WIDTH-1:0] exp_b,
    output logic [MANT_WIDTH:0]  mant_a, // includes hidden bit
    output logic [MANT_WIDTH:0]  mant_b
);
    assign sign_a = num_a[WORD_WIDTH-1];
    assign sign_b = num_b[WORD_WIDTH-1];        
    assign exp_a  = num_a[WORD_WIDTH-2 -: EXP_WIDTH];
    assign exp_b  = num_b[WORD_WIDTH-2 -: EXP_WIDTH];
    assign mant_a = {num_a[WORD_WIDTH-2 -: EXP_WIDTH]!=8'b0, num_a[MANT_WIDTH-1:0]}; // add hidden bit
    assign mant_b = {num_b[WORD_WIDTH-2 -: EXP_WIDTH]!=8'b0, num_b[MANT_WIDTH-1:0]}; // add hidden bit

endmodule
