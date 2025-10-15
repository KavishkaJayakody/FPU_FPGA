`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2025 07:43:03 PM
// Design Name: 
// Module Name: types_pkg
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


package types_pkg;
    typedef enum logic [1:0] {
        OP_ADD      = 2'b00,
        OP_SUB      = 2'b01,
        OP_MULT     = 2'b10,
        OP_DIV      = 2'b11
    } op_state_t;
    typedef enum logic [2:0] {
        IDLE        = 3'b000,
        UNPACK      = 3'b001,
        ALIGN       = 3'b010,
        ADD_SUB     = 3'b011,
        MULT        = 3'b100,
        NORMALIZE   = 3'b101,
        PACK        = 3'b110,
        DONE        = 3'b111
    } state_t;
endpackage