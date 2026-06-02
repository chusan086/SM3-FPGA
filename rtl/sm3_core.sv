`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/29 14:37:53
// Design Name: 
// Module Name: sm3_core
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


module sm3_core(
    input logic     aclk,
    
    input logic              in_valid,
    input logic[255:0]       msg_in,         // 256-bit Ã÷ÎÄ¿é
    
    output logic             out_valid,
    output logic[255:0]      hash_out   
    );

    
endmodule
