`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2025 10:52:03 PM
// Design Name: 
// Module Name: fpu_control_unit
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
import types_pkg::*;

module fpu_control_unit(
    input logic en,
    input op_state_t op, // 0 for add, 1 for sub, 2 for mult
    input logic unpack_ready,
    input logic align_ready,
    input logic addsub_ready,
    input logic mult_ready,
    input logic normalize_ready,
    input logic pack_ready,
    input logic clk,
    input logic rst_n,
    output op_state_t data_path,
    output logic add_sub_op,
    output logic unpack_en,
    output logic align_en,
    output logic addsub_en,
    output logic mult_en,    
    output logic normalize_en,
    output logic pack_en,
    output logic done

    );
    op_state_t operation;

    state_t current_state, next_state;

    // State transition
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end 
    
    always_ff @(posedge clk) begin
        if ((current_state == IDLE)&& en)
                operation <= op;
                data_path <= op;
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
                    next_state = (operation==OP_MULT)?MULT:(operation==OP_ADD||operation==OP_SUB)?ALIGN:IDLE;
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
            MULT: begin
                if (mult_ready)
                    next_state = NORMALIZE;
                else
                    next_state = MULT;           
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
    

   // assign data_path      = OP_MULT;
    always_comb begin
        // Default values
        unpack_en       = 0;
        align_en        = 0;
        addsub_en      = 0;
        add_sub_op     = 0;
        mult_en        = 0;
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
                add_sub_op = (operation==OP_SUB)?1:0;
            end
            MULT: begin
                mult_en = 1;
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
