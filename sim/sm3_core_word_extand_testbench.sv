`timescale 1ns / 1ps

module sm3_core_word_extand_testbench();
    // sm3_core_word_extand Inputs
    reg                    aclk;
    reg                    rst_n;
    reg                    in_valid;
    reg    [0:15][31:0]    word_in;

    // sm3_core_word_extand Outputs
    wire   [0:1][31:0]    word_extand;

    sm3_core_word_extand  u_sm3_core_word_extand (
    .                 aclk        (                 aclk         ),
    .                 rst_n       (                 rst_n        ),
    .                 in_valid    (                 in_valid     ),
    .word_in     (word_in      ),

    .word_extand  (word_extand   )
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
        // 密文681EDF34D206965E86B3E94F536E4246 002A8A4EFA863CCAD024AC0300BB40D2
        @(posedge aclk)begin
            in_valid  <= 1;
            word_in <= '{default : 'b0};
            word_in[0]  <= 32'h61626380;
            // word_in[1] to [13] are already 0
            word_in[14] <= 32'h00000000;
            word_in[15] <= 32'h00000018;
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
