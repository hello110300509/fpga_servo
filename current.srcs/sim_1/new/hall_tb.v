//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 2025/10/19 14:02:36
//// Design Name: 
//// Module Name: hall_tb
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////


//module hall_tb(

//    );
    
// // 测试平台内部信号（与被测试模块端口对应）
//    reg clk;              // 时钟信号
//    reg rst_n;            // 复位信号（低电平有效）
//    reg hall_h1;          // 霍尔H1信号
//    reg hall_h2;          // 霍尔H2信号
//    reg hall_h3;          // 霍尔H3信号
//    wire [11:0] elec_angle;  // 输出电角度（连接到模块输出）
//    wire  [2:0] hall_state;
//    wire [31:0] prev_state_duration;
//    wire state_changed;
//    wire [31:0] state_change_cnt;
//    wire [11:0] sector_start_angle;
//    // 例化被测试模块 hall_electric_angle
//    hall_electric_angle uut (
//        .clk(clk),              // 时钟信号连接
//        .rst_n(rst_n),          // 复位信号连接
//        .hall_h1(hall_h1),      // 霍尔H1信号连接
//        .hall_h2(hall_h2),      // 霍尔H2信号连接
//        .hall_h3(hall_h3),      // 霍尔H3信号连接
//       .hall_state           (hall_state) ,
//       .prev_state_duration  (prev_state_duration      ) ,
//       .state_changed        (state_changed) ,
//         .state_change_cnt(state_change_cnt),
//         .sector_start_angle(sector_start_angle),
//        .elec_angle(elec_angle) // 电角度输出连接
//    );

//    // 生成时钟信号（例如：50MHz，周期20ns）
//    initial begin
//        clk = 1'b0;
//        forever #10 clk = ~clk;  // 每10ns翻转一次，周期20ns
//    end

//    // 生成激励信号（复位 + 霍尔传感器信号序列）
//    initial begin
//        // 初始化信号
//        rst_n = 1'b0;    // 初始复位（低电平有效）
//        hall_h1 = 1'b0;
//        hall_h2 = 1'b0;
//        hall_h3 = 1'b0;

//        // 复位释放（例如：100ns后释放复位）
//        #100;
//        rst_n = 1'b1;

//        // 模拟霍尔传感器的6个状态循环（对应电机6个扇区）
//        // 霍尔信号序列：根据电机旋转方向，H1/H2/H3的组合会按固定顺序变化
//        //#200;  // 延迟200ns（等待复位稳定）
//        hall_h1 = 1'b1; hall_h2 = 1'b0; hall_h3 = 1'b1;  // 状态1
//        #400;  // 维持该状态400ns（可根据实际需求调整）
//        hall_h1 = 1'b1; hall_h2 = 1'b0; hall_h3 = 1'b0;  // 状态2
//        #400;
//        hall_h1 = 1'b1; hall_h2 = 1'b1; hall_h3 = 1'b0;  // 状态3
//        #400;
//        hall_h1 = 1'b0; hall_h2 = 1'b1; hall_h3 = 1'b0;  // 状态4
//        #400;
//        hall_h1 = 1'b0; hall_h2 = 1'b1; hall_h3 = 1'b1;  // 状态5
//        #400;
//        hall_h1 = 1'b0; hall_h2 = 1'b0; hall_h3 = 1'b1;  // 状态6
//        #400;

//        // 循环上述状态（模拟电机持续旋转）
//        repeat(3) begin  // 重复3次循环
//            hall_h1 = 1'b1; hall_h2 = 1'b0; hall_h3 = 1'b1;
//            #400;
//            hall_h1 = 1'b1; hall_h2 = 1'b0; hall_h3 = 1'b0;
//            #400;
//            hall_h1 = 1'b1; hall_h2 = 1'b1; hall_h3 = 1'b0;
//            #400;
//            hall_h1 = 1'b0; hall_h2 = 1'b1; hall_h3 = 1'b0;
//            #400;
//            hall_h1 = 1'b0; hall_h2 = 1'b1; hall_h3 = 1'b1;
//            #400;
//            hall_h1 = 1'b0; hall_h2 = 1'b0; hall_h3 = 1'b1;
//            #400;
//        end

//        // 仿真结束
//        #1000;
//        $stop;  // 停止仿真
//    end

//    // 可选：监控输出电角度的变化
//    initial begin
//        $monitor("Time: %0t, H1=%b, H2=%b, H3=%b, elec_angle=%d (%.2f°)",
//                 $time, hall_h1, hall_h2, hall_h3,
//                 elec_angle, elec_angle * 360.0 / 4096.0);  // 12位精度：4096对应360°
//    end

    
//endmodule

`timescale 1ns / 1ps

module hall_tb;

// 输入信号（连接DUT）
reg clk;              // 时钟信号（100MHz，与模块CLK_FREQ一致）
reg rst_n;            // 复位信号（低电平有效）
reg hall_h1;          // 霍尔H1信号
reg hall_h2;          // 霍尔H2信号
reg hall_h3;          // 霍尔H3信号

// 输出信号（来自DUT）
wire [2:0] hall_state;
wire [31:0] prev_state_duration;
wire state_changed;
wire [31:0] state_change_cnt;
wire [11:0] sector_start_angle;
wire [11:0] elec_angle;
wire [31:0] speed_rpm;
wire [31:0] angular_vel;
wire [31:0] mechanical_cycle_cnt;
 wire [31:0] temp_cycle_cnt; 
wire [2:0] state_switch_cnt; 
// 实例化待测试模块（DUT）
hall_electric_angle uut (
    .clk(clk),
    .rst_n(rst_n),
    .hall_h1(hall_h1),
    .hall_h2(hall_h2),
    .hall_h3(hall_h3),
    .hall_state(hall_state),
    .prev_state_duration(prev_state_duration),
    .state_changed(state_changed),
    .state_change_cnt(state_change_cnt),
    .sector_start_angle(sector_start_angle),
    .elec_angle(elec_angle),
    .speed_rpm(speed_rpm),
    .angular_vel(angular_vel),
    .state_switch_cnt(state_switch_cnt), 
    .mechanical_cycle_cnt(mechanical_cycle_cnt),
     .temp_cycle_cnt(temp_cycle_cnt) 
);

// 1. 生成100MHz时钟（周期10ns）
initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;  // 100MHz = 1/(2×5ns)
end

// 2. 复位序列
initial begin
    rst_n = 1'b0;          // 初始复位（低电平有效）
    #200;                  // 复位保持200ns
    rst_n = 1'b1;          // 释放复位
    #20_000_000;           // 仿真总时长20ms（足够观察多个机械周期）
    $finish;               // 结束仿真
end

// 3. 模拟霍尔信号序列（6个有效状态循环，对应电机旋转）
// 霍尔有效状态顺序：101 → 100 → 110 → 010 → 011 → 001（循环）
// 每个状态持续时间可调整，模拟不同转速（示例：每个状态50us，对应转速1000rpm）
reg [3:0] hall_seq_cnt;    // 霍尔序列计数器（0-5，对应6个状态）
reg [31:0] hall_state_cnt; // 每个霍尔状态的持续时钟计数

// 霍尔状态序列定义（6个有效状态）
parameter [2:0] HALL_STATE_0 = 3'b101;
parameter [2:0] HALL_STATE_1 = 3'b100;
parameter [2:0] HALL_STATE_2 = 3'b110;
parameter [2:0] HALL_STATE_3 = 3'b010;
parameter [2:0] HALL_STATE_4 = 3'b011;
parameter [2:0] HALL_STATE_5 = 3'b001;

// 每个状态持续时间（单位：时钟周期，100MHz时钟下，50us=5000个时钟周期）
parameter HALL_STATE_DURATION = 32'd100000;

initial begin
    // 初始化霍尔信号
    hall_h1 = 1'b1;
    hall_h2 = 1'b0;
    hall_h3 = 1'b1;
    hall_seq_cnt = 4'd0;
    hall_state_cnt = 32'd0;

    wait(rst_n == 1'b1);  // 等待复位释放

    forever @(posedge clk) begin
        if (hall_state_cnt >= HALL_STATE_DURATION) begin
            // 状态持续时间到，切换到下一个霍尔状态
            hall_seq_cnt <= hall_seq_cnt + 4'd1;
            hall_state_cnt <= 32'd0;
        end else begin
            hall_state_cnt <= hall_state_cnt + 32'd1;
        end

        // 根据序列计数器设置霍尔信号
        case (hall_seq_cnt)
            4'd0: {hall_h1, hall_h2, hall_h3} = HALL_STATE_0;
            4'd1: {hall_h1, hall_h2, hall_h3} = HALL_STATE_1;
            4'd2: {hall_h1, hall_h2, hall_h3} = HALL_STATE_2;
            4'd3: {hall_h1, hall_h2, hall_h3} = HALL_STATE_3;
            4'd4: {hall_h1, hall_h2, hall_h3} = HALL_STATE_4;
            4'd5: begin
                {hall_h1, hall_h2, hall_h3} = HALL_STATE_5;
                // 第5个状态结束后，重置序列计数器，循环
                if (hall_state_cnt >= HALL_STATE_DURATION) begin
                    hall_seq_cnt <= 4'd0;
                end
            end
            default: {hall_h1, hall_h2, hall_h3} = HALL_STATE_0;
        endcase
    end
end
// hall_h1 = 1'b1; hall_h2 = 1'b0; hall_h3 = 1'b1;  // 状态1
//        #1000000;  // 维持该状态400ns（可根据实际需求调整）
//        hall_h1 = 1'b1; hall_h2 = 1'b0; hall_h3 = 1'b0;  // 状态2
//        #1000000;
//        hall_h1 = 1'b1; hall_h2 = 1'b1; hall_h3 = 1'b0;  // 状态3
//        #1000000;
//        hall_h1 = 1'b0; hall_h2 = 1'b1; hall_h3 = 1'b0;  // 状态4
//        #1000000;
//        hall_h1 = 1'b0; hall_h2 = 1'b1; hall_h3 = 1'b1;  // 状态5
//        #1000000;
//        hall_h1 = 1'b0; hall_h2 = 1'b0; hall_h3 = 1'b1;  // 状态6
//        #1000000;

//        // 循环上述状态（模拟电机持续旋转）
//        repeat(3) begin  // 重复3次循环
//            hall_h1 = 1'b1; hall_h2 = 1'b0; hall_h3 = 1'b1;
//            #1000000;
//            hall_h1 = 1'b1; hall_h2 = 1'b0; hall_h3 = 1'b0;
//            #1000000;
//            hall_h1 = 1'b1; hall_h2 = 1'b1; hall_h3 = 1'b0;
//            #1000000;
//            hall_h1 = 1'b0; hall_h2 = 1'b1; hall_h3 = 1'b0;
//            #1000000;
//            hall_h1 = 1'b0; hall_h2 = 1'b1; hall_h3 = 1'b1;
//            #1000000;
//            hall_h1 = 1'b0; hall_h2 = 1'b0; hall_h3 = 1'b1;
//            #1000000;
//        end
// 4. 波形记录（生成VCD文件，用于仿真工具查看）
//initial begin
//    $dumpfile("tb_hall_electric_angle.vcd");  // 波形文件名称
//    $dumpvars(0, tb_hall_electric_angle);     // 记录所有模块信号
//    $monitor("Time: %t, Hall State: %b, Elec Angle: %d, RPM: %d, Angular Vel: %d",
//             $time, hall_state, elec_angle, speed_rpm, angular_vel);  // 实时打印关键信号
//end

endmodule