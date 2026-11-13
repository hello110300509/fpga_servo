//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/07 21:23:39
// Design Name: 
// Module Name: monitor_tb
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


//`timescale 1us/1us

//module uart_monitor_tb;

////--------------------------------------
//// 仿真参数
////--------------------------------------
//parameter CLK_FREQ = 28_800_000;   // 实际模块时钟频率（仅作说明）
//parameter CLK_PERIOD = 1_000_000.0 / 28_800;  // 约 27.1ns
//parameter CLK_DIV = 3000;           // 对应 115200bps

////--------------------------------------
//// 信号定义
////--------------------------------------
//reg         clk;
//reg         rstn;
//reg         i_en;
//reg  [30:0] i_tx_val;
//wire        o_uart_tx;

//wire        i_uart_rx;  // 回环测试
//assign i_uart_rx = o_uart_tx;

//wire [30:0] o_rx_val0;
//wire [30:0] o_rx_val1;
//wire        o_rx_done;

////--------------------------------------
//// DUT 例化
////--------------------------------------
//uart_monitor #(
//    .CLK_DIV(CLK_DIV)
//) u_uart_monitor (
//    .rstn       (rstn),
//    .clk        (clk),
//    .i_en       (i_en),
//    .i_tx_val   (i_tx_val),
//    .o_uart_tx  (o_uart_tx),
//    .i_uart_rx  (i_uart_rx),
//    .o_rx_val0  (o_rx_val0),
//    .o_rx_val1  (o_rx_val1),
//    .o_rx_done  (o_rx_done)
//);

////--------------------------------------
//// 时钟产生
////--------------------------------------
//initial clk = 1'b0;
//always #(CLK_PERIOD/2) clk = ~clk;

////--------------------------------------
//// 复位过程
////--------------------------------------
//initial begin
//    rstn = 0;
//    i_en = 0;
//    i_tx_val = 0;
//    #(10*CLK_PERIOD);
//    rstn = 1;
//end

////--------------------------------------
//// 测试过程
////--------------------------------------
//initial begin
//    $display("==== UART Monitor Test Start ====");
//    @(posedge rstn);
//    #(1000);

//    // 第一次发送
//    i_tx_val = 31'd123456789;
//    pulse_en();
//    #(5000); // 等待发送+接收过程

//    // 第二次发送
//    i_tx_val = 31'd987654321;
//    pulse_en();
//    #(5000);

//    // 第三次发送
//    i_tx_val = 31'd1024;
//    pulse_en();
//    #(5000);

//    $display("==== Simulation Done ====");
//   // $finish;
//end

////--------------------------------------
//// 产生 i_en 的一个周期高脉冲
////--------------------------------------
//task pulse_en;
//begin
//    @(posedge clk);
//    i_en = 1'b1;
//    @(posedge clk);
//    i_en = 1'b0;
//end
//endtask

////--------------------------------------
//// 监视输出
////--------------------------------------
//always @(posedge o_rx_done) begin
//    $display("[%0t us] RX Done: val0=%0d  val1=%0d", $time, o_rx_val0, o_rx_val1);
//end

////--------------------------------------
//// 波形导出（可选）
////--------------------------------------
////initial begin
////    $dumpfile("uart_monitor_tb.vcd");
////    $dumpvars(0, uart_monitor_tb);
////end

//endmodule
`timescale 1us/1us

module uart_monitor_tb;

//--------------------------------------
// 仿真参数
//--------------------------------------
parameter CLK_DIV = 320;  // 36.864MHz / 320 = 115200
parameter CLK_PERIOD = 0.0271;  // 约 27.1ns（对应36.864MHz）

//--------------------------------------
// 信号定义
//--------------------------------------
reg         clk;
reg         rstn;
reg         i_en;
reg  [30:0] i_tx_val;
wire        o_uart_tx;

wire        i_uart_rx;  // 回环测试
assign i_uart_rx = o_uart_tx;

wire [30:0] o_rx_val0;
wire [30:0] o_rx_val1;
wire        o_rx_done;

//--------------------------------------
// DUT 例化
//--------------------------------------
uart_monitor #(
    .CLK_DIV(CLK_DIV)
) u_uart_monitor (
    .rstn       (rstn),
    .clk        (clk),
    .i_en       (i_en),
    .i_tx_val   (i_tx_val),
    .o_uart_tx  (o_uart_tx),
    .i_uart_rx  (i_uart_rx),
    .o_rx_val0  (o_rx_val0),
    .o_rx_val1  (o_rx_val1),
    .o_rx_done  (o_rx_done)
);

//--------------------------------------
// 时钟产生
//--------------------------------------
initial clk = 1'b0;
always #(CLK_PERIOD/2) clk = ~clk;

//--------------------------------------
// 复位
//--------------------------------------
initial begin
    rstn = 0;
    i_en = 0;
    i_tx_val = 0;
    #(10 * CLK_PERIOD);
    rstn = 1;
end

//--------------------------------------
// 仿真主过程
//--------------------------------------
initial begin
    $display("==== UART Monitor Auto Echo Test ====");
    @(posedge rstn);
    #(1000);

    // 初始发送一个值
    i_tx_val = 31'd12345;
    pulse_en();

    // 让仿真持续一段时间
    #(5_000);
    $display("==== Simulation Done ====");
    
end

//--------------------------------------
// 产生 i_en 单周期高脉冲
//--------------------------------------
task pulse_en;
begin
    @(posedge clk);
    i_en = 1'b1;
    @(posedge clk);
    i_en = 1'b0;
end
endtask

//--------------------------------------
// 自动回传：接收完后重新发送
//--------------------------------------
always @(posedge clk) begin
    if (o_rx_done) begin
        $display("[%0t us] RX Done: val0=%0d  val1=%0d → Echo back val1", $time, o_rx_val0, o_rx_val1);
        i_tx_val <= o_rx_val1;  // 把接收到的第二个数再发出去
        pulse_en();              // 触发发送
    end
end

//--------------------------------------
// 波形导出
////--------------------------------------
//initial begin
//    $dumpfile("uart_monitor_tb.vcd");
//    $dumpvars(0, uart_monitor_tb);
//end

endmodule