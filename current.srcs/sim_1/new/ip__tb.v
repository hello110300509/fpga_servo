
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/24 20:40:14
// Design Name: 
// Module Name: ip__tb
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


`timescale 1ns / 1ps

module ip__tb;

    // 输入信号
    reg         clk_in1;   // 50MHz 输入时钟
    reg         reset;     // 复位信号（高电平有效，注意与设计中的 rstn 极性匹配）

    // 输出信号（连接到 DUT 的输出）
    wire        clk;       // 由 clk_wiz 生成的输出时钟

    // 实例化待测试的 clk_wiz_0 模块（DUT）
    clk_wiz_0 uut (
        .clk_out1   (clk),      // 输出时钟（注意：原代码中端口名可能为 clk_out1，需与 IP 核实际端口匹配）
        .reset      (reset),    // 复位（IP 核通常为高电平复位）
        .clk_in1    (clk_in1)   // 输入时钟（50MHz）
    );

    // 生成 50MHz 输入时钟（周期 20ns）
    initial begin
        clk_in1 = 1'b0;
        forever #10 clk_in1 = ~clk_in1;  // 50MHz = 1/(20ns)
    end

    // 复位序列与仿真控制
    initial begin
        // 初始化信号
        reset = 1'b1;  // 初始复位（高电平有效）

        // 复位保持 100ns
        #100;
        reset = 1'b0;  // 释放复位

        // 仿真持续足够长时间，观察时钟稳定输出
        #1000;         // 持续 1000ns

        // 仿真结束
        $finish;
    end

   

endmodule
