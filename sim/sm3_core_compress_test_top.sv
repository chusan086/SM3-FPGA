`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/31 11:49:21
// Design Name: 
// Module Name: sm3_core_compress_test_top
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


module sm3_core_compress_test_top(
    input       sys_clk,
    input       sys_rst_n,
    
    output      fan_ctrl
    );
    logic       aclk_200m,aclk_locked;
    assign fan_ctrl = 1'b0;
    clk_wiz_0 m_clk_wiz_0
   (
    // Clock out ports
    .clk_out1(aclk_200m),     // output clk_out1
    // Status and control signals
    .resetn(sys_rst_n), // input resetn
    .locked(aclk_locked),       // output locked
   // Clock in ports
    .clk_in1(sys_clk)      // input clk_in1
    );
    
    sm3_core_compress_test m_sm3_core_compress_test(
    .aclk(aclk_200m),
    .rst_n(aclk_locked)
    );
    
endmodule
