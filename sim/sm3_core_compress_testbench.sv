`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/30 22:22:25
// Design Name: 
// Module Name: sm3_core_compress_testbench
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


module sm3_core_compress_testbench();
// sm3_core_compress Inputs
logic                     aclk;
logic                     rst_n;
logic                     in_valid;
logic [0:7][31:0]         iv;
logic [0:15][31:0]        word_in;

// sm3_core_compress Outputs
logic                    out_valid;
logic [0:7][31:0]        v_out;

sm3_core_compress  u_sm3_core_compress (
    .aclk      ( aclk       ),
    .rst_n     ( rst_n      ),
    .in_valid  ( in_valid   ),
    .iv        ( iv         ),
    .word_in   ( word_in    ),

    .out_valid  ( out_valid   ),
    .v_out      ( v_out       )
);  

    // ------------------------
    // 时钟生成
    // ------------------------
    initial aclk = 0;
    always #5 aclk = ~aclk;   // 100MHz

    // ------------------------
    // 测试激励
    // ------------------------
    initial begin
        // 初始值
        rst_n     <= 0;
        in_valid  <= 0;

        // 复位一段时间
        #20;
        rst_n <= 1;
        #40;
        
        // 等待几个周期后输入数据
        // 第一帧的第一字
        @(posedge aclk)begin
            in_valid  <= 1;
            iv = '{
            32'h7380166f, 32'h4914b2b9, 32'h172442d7, 32'hda8a0600, 
            32'ha96f30bc, 32'h163138aa, 32'he38dee4d, 32'hb0fb0e4e
            };

            word_in <= '{default : 'b0};
            word_in[0]  <= 32'h61626380;
            // word_in[1] to [13] are already 0
            word_in[14] <= 32'h00000000;
            word_in[15] <= 32'h00000018;
        end
        
        @(posedge aclk);
            in_valid  <= 0;
        
        // 第二帧的第一字
        #4000;
        @(posedge aclk)begin
            in_valid  <= 1;
            iv = '{
            32'h7380166f, 32'h4914b2b9, 32'h172442d7, 32'hda8a0600, 
            32'ha96f30bc, 32'h163138aa, 32'he38dee4d, 32'hb0fb0e4e
            };

            word_in <= '{
            32'h61626380, 32'h61626380, 32'h61626380, 32'h61626380,
            32'h61626380, 32'h61626380, 32'h61626380, 32'h61626380,
            32'h61626380, 32'h61626380, 32'h61626380, 32'h61626380,
            32'h61626380, 32'h61626380, 32'h61626380, 32'h61626380
            };
        end
        @(posedge aclk);
            in_valid  <= 0;
        
        // 第二帧的第一字
        #4000;
        @(posedge aclk)begin
            in_valid  <= 1;
            iv = v_out;

            word_in <= '{default : 'b0};
            word_in[0] <= 32'h80000000;
            word_in[15] <= 32'h00000200;
        end
        @(posedge aclk);
            in_valid  <= 0;
        
/*        
        // 密文B2B39A1B91A4E24FA89155E82CF4776D A82679F39B30EF738000B5421E005672
        @(posedge aclk);
        in_valid  <= 1;
        
        @(posedge aclk)
        
        @(posedge aclk);
        plaintext <= 128'hFFEEDDCCBBAA99887766554433221100;  // 测试明文
        key       <= 128'hFFEEDDCCBBAA99887766554433221100;  // 测试密钥
        in_valid  <= 1;

        @(posedge aclk);
        in_valid  <= 0;*/
    end
    
endmodule
