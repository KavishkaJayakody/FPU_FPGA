`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kavishka Jayakody
// Synchronous FSM-based Floating Point ADD/SUB Unit (fixed drivers)
//////////////////////////////////////////////////////////////////////////////////

module fpu_addsub #(
    parameter EXP_WIDTH  = 8,
    parameter MANT_WIDTH = 23,
    parameter NUM_WIDTH  = 32
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  start,     // start signal (pulse)
    input  logic [NUM_WIDTH-1:0]  A,
    input  logic [NUM_WIDTH-1:0]  B,
    input  logic                  ADD,       // 1 = ADD, 0 = SUB
    output logic [NUM_WIDTH-1:0]  C,
    output logic                  done       // goes high for 1 cycle when result is ready
);

    // ----------------------------
    // FSM States
    // ----------------------------
    typedef enum logic [2:0] {
        S_IDLE,
        S_UNPACK,
        S_ALIGN,
        S_ADD_SUB,
        S_NORMALIZE,
        S_PACK,
        S_DONE
    } state_t;

    state_t state, next_state;

    // ----------------------------
    // Internal signals (registered datapath)
    // ----------------------------
    // inputs unpacked (registered)
    logic sign_a_r, sign_b_r;
    logic [EXP_WIDTH-1:0] exp_a_r, exp_b_r;
    logic [MANT_WIDTH-1:0] mant_a_r, mant_b_r;

    // aligned (from align_exp combinational outputs captured into regs)
    logic [EXP_WIDTH-1:0] exp_a_aligned_w, exp_b_aligned_w; // wires from aligner
    logic [MANT_WIDTH:0]  mant_a_aligned_w, mant_b_aligned_w; // wires from aligner (hidden bit present)

    logic [EXP_WIDTH-1:0] exp_a_aligned_r, exp_b_aligned_r; // registered aligned exponents
    logic [MANT_WIDTH:0]  mant_a_aligned_r, mant_b_aligned_r; // registered aligned mantissas

    // intermediate/result registers
    logic [MANT_WIDTH+1:0] temp_mant_r; // for add/sub result including possible carry
    logic [MANT_WIDTH:0]   mant_c_pre_norm_r;
    logic [EXP_WIDTH-1:0]  exp_c_pre_norm_r;
    logic sign_c_r;
    logic [MANT_WIDTH-1:0] mant_c_normalized_r;
    logic [EXP_WIDTH-1:0]  exp_c_normalized_r;

    // helpers
    logic mant_a_gt_b_r;
    logic op_sign_b_r;
    logic [ MANT_WIDTH+1:0] temp_check;

    // ----------------------------
    // Combinational aligner instance (produces wires)
    // ----------------------------
    align_exp #(.EXP_WIDTH(EXP_WIDTH), .MANT_WIDTH(MANT_WIDTH)) exp_alligner (
        .exp_a(exp_a_r),
        .exp_b(exp_b_r),
        .mant_a(mant_a_r),
        .mant_b(mant_b_r),
        .exp_a_aligned(exp_a_aligned_w),
        .exp_b_aligned(exp_b_aligned_w),
        .mant_a_aligned(mant_a_aligned_w),
        .mant_b_aligned(mant_b_aligned_w)
    );

    // ----------------------------
    // FSM sequential: state register
    // ----------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    // ----------------------------
    // FSM combinational: next state + done pulse
    // ----------------------------
    always_comb begin
        next_state = state;
        //done = 1'b0;
        case (state)
            S_IDLE:      if (start) next_state = S_UNPACK;
            S_UNPACK:    next_state = S_ALIGN;
            S_ALIGN:     next_state = S_ADD_SUB;
            S_ADD_SUB:   next_state = S_NORMALIZE;
            S_NORMALIZE: next_state = S_PACK;
            S_PACK:      next_state = S_DONE;
            S_DONE:      next_state = S_IDLE;
            default:     next_state = S_IDLE;
        endcase
    end

    // ----------------------------
    // FSM sequential datapath: one always_ff drives each register
    // ----------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset all registers
            sign_a_r <= 1'b0;
            sign_b_r <= 1'b0;
            exp_a_r <= '0;
            exp_b_r <= '0;
            mant_a_r <= '0;
            mant_b_r <= '0;

            exp_a_aligned_r <= '0;
            exp_b_aligned_r <= '0;
            mant_a_aligned_r <= '0;
            mant_b_aligned_r <= '0;

            temp_mant_r <= '0;
            mant_c_pre_norm_r <= '0;
            exp_c_pre_norm_r <= '0;
            sign_c_r <= 1'b0;
            mant_c_normalized_r <= '0;
            exp_c_normalized_r <= '0;
            mant_a_gt_b_r <= 1'b0;
            op_sign_b_r <= 1'b0;

            C <= '0;
            //done <= 1'b0;
        end else begin
            // default keep values (only update in specific states)
            case (state)
                // IDLE: nothing to do
                S_IDLE: begin
                    // stay idle until start asserted
                end

                // UNPACK: sample inputs into registers
                S_UNPACK: begin
                    sign_a_r <= A[NUM_WIDTH-1];
                    sign_b_r <= B[NUM_WIDTH-1];
                    exp_a_r  <= A[NUM_WIDTH-2 -: EXP_WIDTH];
                    exp_b_r  <= B[NUM_WIDTH-2 -: EXP_WIDTH];
                    mant_a_r <= A[MANT_WIDTH-1:0];
                    mant_b_r <= B[MANT_WIDTH-1:0];
                end

                // ALIGN: capture aligner outputs (wires) into registers
                S_ALIGN: begin
                    exp_a_aligned_r <= exp_a_aligned_w;
                    exp_b_aligned_r <= exp_b_aligned_w;
                    mant_a_aligned_r <= mant_a_aligned_w; // width MANT_WIDTH:0 (hidden bit included)
                    mant_b_aligned_r <= mant_b_aligned_w;
                end

                // ADD_SUB: perform add/sub on registered aligned mantissas
                S_ADD_SUB: begin
                    op_sign_b_r <= sign_b_r ^ (~ADD); // invert sign of B if SUB (ADD==0 -> subtract)
                    mant_a_gt_b_r <= (mant_a_aligned_r > mant_b_aligned_r);
                    // set default exp base (larger exponent captured during align)
                    // use exp_a_aligned_r (both aligned exps equal after align)
                    if ((sign_a_r) == op_sign_b_r) begin
                        // same sign => addition
                        temp_mant_r <= {1'b0, mant_a_aligned_r} + {1'b0, mant_b_aligned_r};
                        sign_c_r <= sign_a_r;
                    end else begin
                        // different sign => subtraction
                        if (mant_a_aligned_r >= mant_b_aligned_r) begin
                            temp_mant_r <= {1'b0, mant_a_aligned_r} - {1'b0, mant_b_aligned_r};
                            sign_c_r <= sign_a_r;
                        end else begin
                            temp_mant_r <= {1'b0, mant_b_aligned_r} - {1'b0, mant_a_aligned_r};
                            sign_c_r <= op_sign_b_r;
                        end
                    end

                    // set pre-normalization mantissa & exponent (handle carry)
                    // Temporary signal to hold addition/subtraction result
                    //logic [ MANT_WIDTH+1:0] temp_check;
                    
                    // Step 1: Compute addition/subtraction
                    temp_check = (sign_a_r == op_sign_b_r) ? 
                                 ({1'b0, mant_a_aligned_r} + {1'b0, mant_b_aligned_r}) :
                                 temp_mant_r;
                    
                    // Step 2: Check carry (highest bit)
                    if (({1'b0, mant_a_aligned_r} + {1'b0, mant_b_aligned_r}) != 0 &&
                        temp_check[MANT_WIDTH+1]) begin
                        // Addition produced a carry
                        mant_c_pre_norm_r <= temp_check[MANT_WIDTH+1:1];  // shift right 1 to normalize
                        exp_c_pre_norm_r  <= exp_a_aligned_r + 1;
                    end else begin
                        mant_c_pre_norm_r <= temp_check[MANT_WIDTH:0];
                        exp_c_pre_norm_r  <= exp_a_aligned_r;
                    end
                    

                    // set pre-norm values using temp_mant_r just computed
                    if (temp_mant_r[MANT_WIDTH+1]) begin
                        mant_c_pre_norm_r <= temp_mant_r[MANT_WIDTH+1:1];
                        exp_c_pre_norm_r  <= exp_a_aligned_r + 1'b1;
                    end else begin
                        mant_c_pre_norm_r <= temp_mant_r[MANT_WIDTH:0];
                        exp_c_pre_norm_r  <= exp_a_aligned_r;
                    end
                end

                // NORMALIZE: count leading zeros and shift left, adjust exponent
                S_NORMALIZE: begin
                    // Leading zero count for mant_c_pre_norm_r (width MANT_WIDTH+1 down to 0)
                    integer i;
                    integer lzc_int;
                    lzc_int = 0;
                    // find highest '1' bit index
                    for (i = MANT_WIDTH; i >= 0; i = i - 1) begin
                        if (mant_c_pre_norm_r[i]) begin
                            lzc_int = MANT_WIDTH - i;
                            i = -1; // break
                        end
                    end
                    if (mant_c_pre_norm_r != 0) begin
                        // shift left by lzc_int
                        logic [MANT_WIDTH+1:0] tmp_shift;
                        tmp_shift = mant_c_pre_norm_r << lzc_int;
                        // Take top MANT_WIDTH bits as normalized mantissa (drop hidden bit)
                        mant_c_normalized_r <= tmp_shift[MANT_WIDTH-1:0];
                        exp_c_normalized_r <= exp_c_pre_norm_r - lzc_int;
                    end else begin
                        // result zero
                        mant_c_normalized_r <= '0;
                        exp_c_normalized_r <= '0;
                        sign_c_r <= 1'b0;
                    end
                end

                // PACK: combine sign, exponent, mantissa
                S_PACK: begin
                    C <= {sign_c_r, exp_c_normalized_r, mant_c_normalized_r};
                end

                // DONE: assert done for one cycle (handled below by next_state/fsm)
                S_DONE: begin
                    // keep C as is; done will be asserted combinationally by next_state logic
                end

                default: begin
                    // nothing
                end
            endcase
        end
    end

    // done pulse: assert when in S_DONE (1-cycle)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) done <= 1'b0;
        else done <= (state == S_DONE);
    end

endmodule


