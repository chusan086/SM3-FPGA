module sm3_core_compress_test(
    input logic                     aclk,
    input logic                     rst_n
           
);
    (* mark_debug = "true" *)logic                    out_valid;      // 压缩完成信号                    
    (* mark_debug = "true" *)logic [0:7][31:0]        v_out;           // 压缩输出 (256位哈希值)     
    (* mark_debug = "true" *)logic                     in_valid;       // 开始压缩信号                    
    (* mark_debug = "true" *)logic [0:7][31:0]         iv;             // 初始向量(IV)或上一轮的哈希值          
    (* mark_debug = "true" *)logic [0:15][31:0]        word_in;        // 每一次压缩所用的512位字（未拓展）        

    // 延迟和暂存寄存器
    logic [1:0][0:7][31:0]      iv_d;       // IV的流水线延迟寄存器，用于与数据路径对齐     
    logic [1:0]                 valid_d;    // in_valid的流水线延迟寄存器         
    logic [0:7][31:0]           iv_r;       // 暂存IV，用于FINISH状态下的最终异或操作   
    
    // SM3常量Tj   j=0-15, j=16-63
    localparam logic [0:1][31:0] Tj = '{32'h79cc4519, 32'h7a879d8a};
    
    // 压缩状态
    typedef enum logic [1:0] {
        IDLE      = 2'b00,  // 空闲状态 
        COMPRESS  = 2'b01,  // 压缩状态 
        FINISH    = 2'b10   // 完成状态 
    } sta_t;
    
    sta_t cur_sta, nex_sta;
    
    
    // 压缩函数寄存器
    logic [31:0] a, b, c, d, e, f, g, h;
    
    // 压缩函数计算的中间步骤变量
    logic [31:0] ss1, ss1_t, ss2;
    logic [31:0] gg,ff; 
    logic [31:0] tt1, tt2 , tt1_t , tt2_t;
    logic [31:0] tj_rotl;
    
    // 计数器
    logic [6:0] j_count;        // 主迭代计数器 (0-63)  
    logic [3:0] compress_cnt;   // 内部阶段计数器     

    // word_extand接口:0为Wj,1为Wj'
    logic [0:1][31:0] wj;
    
    // 输入信号打拍，用于与word_extand模块时序对齐
    always @(posedge aclk) begin
        iv_d[0] <= iv;
        iv_d[1] <= iv_d[0];
        valid_d[0] <= in_valid;
        valid_d[1] <= valid_d[0];
    end
    
    // 状态转换
    always @(posedge aclk) begin
        if (!rst_n) 
            cur_sta <= IDLE;
        else 
            cur_sta <= nex_sta;
    end
    
    // 下一状态逻辑
    always @(*) begin
        case (cur_sta)
            IDLE: if (valid_d[1]) nex_sta = COMPRESS;
            COMPRESS: if (j_count >= 7'd64) nex_sta = FINISH;
            FINISH: nex_sta = IDLE;
            default: nex_sta = IDLE;
        endcase
    end
    
    // 压缩函数实现
    always @(posedge aclk) begin
        case (cur_sta)
            IDLE: begin
                out_valid <= 1'b1;  // 默认输出有效，表示空闲
                j_count <= 7'd0;
                compress_cnt <= 4'd0;
                if (valid_d[1]) begin
                    // 加载初始IV到工作寄存器
                    a <= iv_d[1][0]; b <= iv_d[1][1]; 
                    c <= iv_d[1][2]; d <= iv_d[1][3];
                    e <= iv_d[1][4]; f <= iv_d[1][5]; 
                    g <= iv_d[1][6]; h <= iv_d[1][7];
                    iv_r <= iv_d[1];    // 保存初始IV                  
                    out_valid <= 1'b0;  // 开始工作，输出无效               
                end
            end
            
            COMPRESS: begin
                if(j_count < 7'd64) begin
                    // 阶段计数器
                    if(compress_cnt < 4'd5)
                        compress_cnt <= compress_cnt + 4'd1;
                    else begin
                        compress_cnt <= 4'd0;  
                        j_count <= j_count + 7'd1;
                    end 
                    
                    // 压缩函数单轮迭代的实现
                    case(compress_cnt)
                        // 阶段0: 计算Tj循环移位, FF, GG, 以及SS1的第一部分
                        'd0:begin
                            // Tj <<< j
                            if(j_count < 16)
                                tj_rotl <= (Tj[0] << j_count) | (Tj[0] >> (32-j_count));
                            else if(j_count < 32)
                                tj_rotl <= (Tj[1] << j_count) | (Tj[1] >> (32-j_count));
                            else 
                                tj_rotl <= (Tj[1] << (j_count-32)) | (Tj[1] >> (64-j_count));
                            
                            // ff(a,b,c)
                            if(j_count < 16)
                                ff <= a ^ b ^ c;
                            else 
                                ff <= ((a & b) | (a & c) | (b & c));
                            // gg(e,f,g)
                            if(j_count < 16)
                                gg <= e ^ f ^ g;
                            else 
                                gg <= ((e & f) | ((~e) & g));

                            // ss1_t = (a <<< 12) + e
                            ss1_t <= {a[19:0], a[31:20]} + e;
                        end 
                        'd1:
                            // 阶段 1: 完成SS1的计算（未左移）
                            ss1 <= ss1_t + tj_rotl;
                        'd2:begin
                            // 阶段 2: 计算SS2, 并对SS1进行循环移位
                            ss2 <= {ss1[24:0], ss1[31:25]} ^ {a[19:0], a[31:20]};
                            ss1 <= {ss1[24:0], ss1[31:25]};
                        end
                        'd3:begin
                            // 阶段 3: 计算TT1和TT2的第一部分
                            tt1 <= ff + d;
                            tt1_t <= ss2 + wj[1];
                            tt2 <= gg + h;
                            tt2_t <= ss1 + wj[0];
                        end
                        'd4:begin
                            // 阶段 4: 完成TT1和TT2的计算
                            tt1 <= tt1 + tt1_t;
                            tt2 <= tt2 + tt2_t;
                        end
                        'd5:begin
                        // 阶段 5: 更新工作寄存器a-h
                            a <= tt1;
                            b <= a;
                            c <= {b[22:0], b[31:23]};
                            d <= c;
                            e <= tt2 ^ {tt2[22:0], tt2[31:23]} ^ {tt2[14:0], tt2[31:15]};
                            f <= e;
                            g <= {f[12:0], f[31:13]};
                            h <= g;
                        end
                    endcase
                end
            end
            
            FINISH: begin
                // 计算输出向量V
                v_out[0] <= a ^ iv_r[0];
                v_out[1] <= b ^ iv_r[1];
                v_out[2] <= c ^ iv_r[2];
                v_out[3] <= d ^ iv_r[3];
                v_out[4] <= e ^ iv_r[4];
                v_out[5] <= f ^ iv_r[5];
                v_out[6] <= g ^ iv_r[6];
                v_out[7] <= h ^ iv_r[7];
            end
        endcase
    end
    
    sm3_core_word_extand  m_sm3_core_word_extand (
    .aclk(aclk),
    .rst_n(rst_n),
    .in_valid(in_valid),
    .word_in (word_in),

    .word_extand(wj)
    );

endmodule
