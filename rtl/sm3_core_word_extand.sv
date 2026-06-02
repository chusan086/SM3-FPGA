`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/25 20:41:13
// Design Name: 
// Module Name: sm3_word_extand
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: SM3消息扩展模块。
//              接收一个512位的已填充消息块(word_in)，通过64轮迭代，
//              每轮生成一个扩展字Wj和Wj'。
//              采用多级流水线实现，以优化时序。
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sm3_core_word_extand(
    input logic                 aclk,
    input logic                 rst_n,

    input logic                 in_valid,       // 输入有效信号，表示一个新的消息块准备好了                        
    input logic [0:15][31:0]    word_in,        // 填充后未拓展的512位数据 (16个32位字)                     
    
    output logic [0:1][31:0]    word_extand     // 扩展后的输出: [0]为Wj, [1]为Wj'                                         
);
    // 中间变量
    logic [31:0]                p1_func = 'b0;  // 用于P1函数计算的流水线寄存器
    logic [0:15][31:0]          word_reg = '{default : 'b0};// 移位寄存器，存储计算Wj所需的W[j-16]到W[j-1]

    // 计数器
    logic [6:0] j_count = 'b0;      // 主迭代计数器 (0-
    logic [3:0] extand_cnt = 'b0;   // 内部流水线阶段计数器       
    
    // 拓展状态
    typedef enum logic {
        IDLE      = 'd0,    // 空闲状态，等待输入   
        EXTAND    = 'd1     // 扩展状态，执行64轮扩展
    } sta_t;
    
    sta_t cur_sta, nex_sta;

    // 状态机同步逻辑：在时钟边沿更新状态
    always @(posedge aclk)begin
        if(!rst_n) cur_sta <= IDLE;
        else cur_sta <= nex_sta;
    end

    // 下一状态逻辑
    always @(*) begin
        case (cur_sta)
            IDLE: if (in_valid) nex_sta = EXTAND;
            EXTAND: if (j_count >= 7'd64) nex_sta = IDLE;
            default: nex_sta = IDLE;
        endcase
    end

    // 拓展函数实现
    always @(posedge aclk) begin
        case (cur_sta)
            IDLE: begin
                // 在IDLE状态，复位所有计数器
                j_count <= 7'd0;
                extand_cnt <= 4'd0;
                // 当输入有效时，加载初始的16个字到移位寄存器中
                if (in_valid) begin
                    word_reg <= word_in;
                end
                
            end
            
            EXTAND: begin
                // 在EXTAND状态，执行64轮迭代
                if(j_count < 7'd64) begin
                    // 阶段计数器，每轮迭代包含多个时钟周期
                    if(extand_cnt < 4'd5)
                        extand_cnt <= extand_cnt + 4'd1;
                    else begin
                        extand_cnt <= 4'd0;   
                        j_count <= j_count + 7'd1;
                    end
                        
                    case(extand_cnt)
                        // 阶段0: 计算P1置换函数的输入值。公式为 W[j-16] xor W[j-9] xor (W[j-3] <<< 15)。
                        'd0:p1_func <= word_reg[0] ^ word_reg[7] ^ {word_reg[13][16:0],word_reg[13][31:17]};
                        // 阶段1: 执行P1置换。公式为 P1(X) = X xor (X <<< 15) xor (X <<< 23)。
                        'd1:p1_func <= p1_func ^ {p1_func[16:0],p1_func[31:17]} ^ {p1_func[8:0],p1_func[31:9]};
                        // 阶段2: 完成W[j]的最终计算。公式为 W[j] = P1(...) xor (W[j-13] <<< 7) xor W[j-6]。
                        'd2:p1_func <= p1_func ^ {word_reg[3][24:0],word_reg[3][31:25]} ^ word_reg[10];
                        
                        // 阶段 3: 输出结果并更新移位寄存器
                        'd3:begin
                            // 更新输出: Wj 和 Wj' = Wj xor W[j+4]
                            word_extand[0] <= word_reg[0];// 当前的Wj是16个周期前的计算结果
                            word_extand[1] <= word_reg[0] ^ word_reg[4];
                            // 移位寄存器组整体左移，为下一次计算做准备
                            word_reg[0:14] <= word_reg[1:15];
                            // 将最新计算出的W[j]存入移位寄存器的末尾
                            word_reg[15] <= p1_func;
                        end
                    endcase
                end
            end    
        endcase    
    end
    
    
endmodule

