//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 2025/07/19 09:34:37
//// Design Name: 
//// Module Name: tb_ip
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


//module tb_ip(

//    );
// reg clk_50m;
// wire clk;  
//  reg         reset;     // 复位信号（高电平有效，注意与设计中的 rstn 极性匹配）

//// wire pwm_en;  // 3相共用的使能信号，
////wire pwm_a;   // A相PWM信号。当 
////wire pwm_b;   // B相PWM信号。当 
////wire pwm_c;   // C相PWM信号。当 

////wire spi_ss;               
////wire spi_sck;              
////wire spi_mosi;             
////wire spi_miso;             

////wire i2c_scl;              
////wire      i2c_sda;              

////wire uart_tx;              
                           
 


//initial clk_50m = 1'b1;
 
// always #10 clk_50m=~clk_50m;
//   initial begin
//        // 初始化信号
//        reset = 1'b0;  // 初始复位（高电平有效）

//        // 复位保持 100ns
//        #100;
//        reset = 1'b1;  // 释放复位
//        //        // 仿真持续足够长时间，观察时钟稳定输出
//        #1000;         // 持续 1000ns

//        // 仿真结束
//        $finish;
//    end
 
//fpga_top fpga_top_inst
//(       .rstn(reset),
//     .clk_50m(clk_50m), // 连接 50MHz 晶振
//     .clk(clk)
////    .pwm_en(pwm_en),  // 3相共用的使能信号，当 pwm_en=0 时，6个MOS管全部关断。
////    .pwm_a(pwm_a),   // A相PWM信号。当 =0 时。下桥臂导通；当 =1 时，上桥臂导通
////    .pwm_b(pwm_b),   // B相PWM信号。当 =0 时。下桥臂导通；当 =1 时，上桥臂导通
////    .pwm_c(pwm_c),   // C相PWM信号。当 =0 时。下桥臂导通；当 =1 时，上桥臂导通
////     .spi_ss(spi_ss),
////     .spi_sck(spi_sck),
////     .spi_mosi(spi_mosi),
////     .spi_miso(spi_miso),
////     .i2c_scl(i2c_scl),
////     .i2c_sda(i2c_sda),
////    .uart_tx(uart_tx)
//);


//endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/19 09:34:37
// Design Name: 
// Module Name: tb_ip
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


module tb_ip(

    );
 reg clk_50m;
 wire clk;  
// wire pwm_en;  // 3相共用的使能信号，
//wire pwm_a;   // A相PWM信号。当 
//wire pwm_b;   // B相PWM信号。当 
//wire pwm_c;   // C相PWM信号。当 

//wire spi_ss;               
//wire spi_sck;              
//wire spi_mosi;             
//wire spi_miso;             

//wire i2c_scl;              
//wire      i2c_sda;              

//wire uart_tx;              
                           
 initial clk_50m = 1'b1;
 
 always #10 clk_50m=~clk_50m;
fpga_top fpga_top_inst
(
     .clk_50m(clk_50m), // 连接 50MHz 晶振
     .clk(clk)
//    .pwm_en(pwm_en),  // 3相共用的使能信号，当 pwm_en=0 时，6个MOS管全部关断。
//    .pwm_a(pwm_a),   // A相PWM信号。当 =0 时。下桥臂导通；当 =1 时，上桥臂导通
//    .pwm_b(pwm_b),   // B相PWM信号。当 =0 时。下桥臂导通；当 =1 时，上桥臂导通
//    .pwm_c(pwm_c),   // C相PWM信号。当 =0 时。下桥臂导通；当 =1 时，上桥臂导通
//     .spi_ss(spi_ss),
//     .spi_sck(spi_sck),
//     .spi_mosi(spi_mosi),
//     .spi_miso(spi_miso),
//     .i2c_scl(i2c_scl),
//     .i2c_sda(i2c_sda),
//    .uart_tx(uart_tx)
);
endmodule
