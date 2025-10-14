`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2025 12:59:38 AM
// Design Name: 
// Module Name: control_unit
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


module add_sub_control_unit(
    input logic en,
    input logic unpack_ready,
    input logic align_ready,
    input logic addsub_ready,
    input logic normalize_ready,
    input logic pack_ready,
    input logic clk,
    input logic rst_n,
    output logic unpack_en,
    output logic align_en,
    output logic addsub_en,    
    output logic normalize_en,
    output logic pack_en,
    output logic done

    );
    typedef enum logic [2:0] {
        IDLE        = 3'b000,
        UNPACK      = 3'b001,
        ALIGN       = 3'b010,
        ADD_SUB     = 3'b011,
        NORMALIZE   = 3'b100,
        PACK        = 3'b101,
        DONE        = 3'b110
    } state_t;

    state_t current_state, next_state;

    // State transition
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end 

    // Next state logic
    always_comb begin
        case (current_state)
            IDLE: begin
                if (en)
                    next_state = UNPACK;
                else
                    next_state = IDLE;
            end     
            UNPACK: begin
                if (unpack_ready)
                    next_state = ALIGN;
                else
                    next_state = UNPACK;
            end
            ALIGN: begin
                if (align_ready)
                    next_state = ADD_SUB;
                else
                    next_state = ALIGN;
            end
            ADD_SUB: begin
                if (addsub_ready)
                    next_state = NORMALIZE;
                else
                    next_state = ADD_SUB;           
            end
            NORMALIZE: begin
                if (normalize_ready)
                    next_state = PACK;
                else
                    next_state = NORMALIZE;          
            end 
            PACK: begin
                if (pack_ready)
                    next_state = DONE;
                else
                    next_state = PACK;          
            end 
            DONE: begin
                next_state = IDLE;          
            end
            default: next_state = IDLE;
        endcase
    end
    // Output logic
    always_comb begin
        // Default values
        unpack_en       = 0;
        align_en        = 0;
        addsub_en      = 0;
        normalize_en    = 0;        
        pack_en         = 0;
        done            = 0;

        case (current_state)
            IDLE: begin
                // All enables are already 0
                done = 0;
            end
            UNPACK: begin
                unpack_en = 1;
            end
            ALIGN: begin
                align_en = 1;
            end
            ADD_SUB: begin
                addsub_en = 1;
            end
            NORMALIZE: begin
                normalize_en = 1;                
            end
            PACK: begin
                pack_en = 1;
            end
            DONE: begin
                done = 1;
            end
            default: begin
                // All enables are already 0
                done = 0;
            end
        endcase
    end

endmodule
