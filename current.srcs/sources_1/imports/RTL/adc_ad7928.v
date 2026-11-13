////--------------------------------------------------------------------------------------------------------
//// Module : adc_ad7928
//// Function:
////      AD7928 SPI ADC driver
////
//// SPI:
////      CPOL = 1
////      CPHA = 1
////
////      SCLK idle high
////      Falling edge : MOSI change / ADC output data
////      Rising edge  : FPGA sample MISO
////
//// Data:
////      1bit  zero
////      3bit  channel address
////      12bit ADC data
////
////--------------------------------------------------------------------------------------------------------

//module adc_ad7928 #(

//    parameter [2:0] CH_CNT = 3'd7,

//    parameter [2:0] CH0 = 3'd0,
//    parameter [2:0] CH1 = 3'd1,
//    parameter [2:0] CH2 = 3'd2,
//    parameter [2:0] CH3 = 3'd3,
//    parameter [2:0] CH4 = 3'd4,
//    parameter [2:0] CH5 = 3'd5,
//    parameter [2:0] CH6 = 3'd6,
//    parameter [2:0] CH7 = 3'd7

//)(

//    input  wire clk,
//    input  wire rstn,


//    // SPI
//    output reg spi_ss,
//    output reg spi_sck,
//    output reg spi_mosi,
//    input  wire spi_miso,


//    // user
//    input wire i_sn_adc,

//    output reg o_en_adc,

//    output wire [11:0] o_adc_value0,
//    output wire [11:0] o_adc_value1,
//    output wire [11:0] o_adc_value2,
//    output wire [11:0] o_adc_value3,
//    output wire [11:0] o_adc_value4,
//    output wire [11:0] o_adc_value5,
//    output wire [11:0] o_adc_value6,
//    output wire [11:0] o_adc_value7

//);



///**************************************************
//* channel table
//**************************************************/

//wire [2:0] channel [0:7];

//assign channel[0]=CH0;
//assign channel[1]=CH1;
//assign channel[2]=CH2;
//assign channel[3]=CH3;
//assign channel[4]=CH4;
//assign channel[5]=CH5;
//assign channel[6]=CH6;
//assign channel[7]=CH7;



//reg [11:0] adc_data[0:7];


//assign o_adc_value0 = adc_data[0];
//assign o_adc_value1 = adc_data[1];
//assign o_adc_value2 = adc_data[2];
//assign o_adc_value3 = adc_data[3];
//assign o_adc_value4 = adc_data[4];
//assign o_adc_value5 = adc_data[5];
//assign o_adc_value6 = adc_data[6];
//assign o_adc_value7 = adc_data[7];



///**************************************************
//* SPI clock divider
//**************************************************/

//localparam CLK_DIV = 1;


//reg [7:0] div_cnt;

//reg spi_busy;



//always @(posedge clk or negedge rstn)
//begin

//    if(!rstn)
//    begin
//        div_cnt <=0;
//    end

//    else if(spi_busy)
//    begin

//        if(div_cnt==CLK_DIV-1)
//            div_cnt<=0;
//        else
//            div_cnt<=div_cnt+1'b1;

//    end

//    else
//        div_cnt<=0;

//end



//wire spi_tick;

//assign spi_tick =
//        spi_busy &&
//        (div_cnt==CLK_DIV-1);



///**************************************************
//* SPI control
//**************************************************/

//reg [4:0] bit_cnt;

//reg [15:0] tx_shift;

//reg [15:0] rx_shift;


//reg [2:0] ch_index;



//reg sck_rise_d;


//wire sck_rise;


//assign sck_rise =
//        spi_sck & ~sck_rise_d;



//always @(posedge clk or negedge rstn)
//begin

//    if(!rstn)

//        sck_rise_d<=0;

//    else

//        sck_rise_d<=spi_sck;

//end



///**************************************************
//* SPI main FSM
//**************************************************/

//always @(posedge clk or negedge rstn)
//begin

//if(!rstn)
//begin

//    spi_ss   <=1;
//    spi_sck  <=1;
//    spi_mosi <=1;

//    spi_busy <=0;

//    bit_cnt<=0;

//    ch_index<=0;

//    rx_shift<=0;

//    o_en_adc<=0;


//    adc_data[0]<=0;
//    adc_data[1]<=0;
//    adc_data[2]<=0;
//    adc_data[3]<=0;
//    adc_data[4]<=0;
//    adc_data[5]<=0;
//    adc_data[6]<=0;
//    adc_data[7]<=0;


//end


//else
//begin


//o_en_adc<=0;



///*
//启动一次扫描
//*/

//if(!spi_busy)
//begin

//    if(i_sn_adc)
//    begin

//        spi_busy<=1;

//        spi_ss<=0;

//        bit_cnt<=0;


//        /*
//        AD7928 control word

//        WRITE=1
//        SEQ=0
//        SHADOW=0
//        ADD2:0
//        */

//        tx_shift <=
//        {
//            1'b1,
//            1'b0,
//            1'b0,
//            channel[ch_index],
//            2'b11,
//            1'b0,
//            1'b0,
//            2'b11
//        };


//        spi_mosi <=
//            1'b1;

//        spi_sck<=1;


//    end

//end



//else if(spi_tick)
//begin


//    /*
//    产生下降沿
//    */

//    if(spi_sck)
//    begin

//        spi_sck<=0;


//        spi_mosi<=tx_shift[15];

//        tx_shift<=
//        {
//            tx_shift[14:0],
//            1'b0
//        };


//    end


//    /*
//    产生上升沿
//    */

//    else
//    begin

//        spi_sck<=1;


//        /*
//        sample MISO
//        */

//        rx_shift <=
//        {
//            rx_shift[14:0],
//            spi_miso
//        };


//        if(bit_cnt==15)
//        begin


//            /*
//            保存12bit ADC

//            去掉：
//            bit15 前导0
//            bit14~12 地址

//            */

//            adc_data[ch_index]
//            <=
//            {
//            rx_shift[10:0],
//            spi_miso
//            };


//            spi_busy<=0;

//            spi_ss<=1;


//            if(ch_index==CH_CNT)
//            begin

//                ch_index<=0;

//                o_en_adc<=1;

//            end

//            else

//                ch_index<=ch_index+1'b1;



//        end

//        else

//            bit_cnt<=bit_cnt+1'b1;



//    end


//end



//end

//end



//endmodule

//--------------------------------------------------------------------------------------------------------
// Module : adc_ad7928
//
// AD7928 SPI ADC Driver
//
// SPI MODE:
// CPOL = 1
// CPHA = 1
//
// SCLK idle high
// Falling edge : MOSI change / ADC output
// Rising edge  : FPGA sample MISO
//
// Data:
// bit15       : zero
// bit14~12    : channel address
// bit11~0     : ADC data
//
//--------------------------------------------------------------------------------------------------------

//module adc_ad7928 #(

//    parameter [2:0] CH_CNT = 3'd7,

//    parameter [2:0] CH0 = 3'd0,
//    parameter [2:0] CH1 = 3'd1,
//    parameter [2:0] CH2 = 3'd2,
//    parameter [2:0] CH3 = 3'd3,
//    parameter [2:0] CH4 = 3'd4,
//    parameter [2:0] CH5 = 3'd5,
//    parameter [2:0] CH6 = 3'd6,
//    parameter [2:0] CH7 = 3'd7

//)
//(
//    input  wire clk,
//    input  wire rstn,


//    // SPI
//    output reg spi_ss,
//    output reg spi_sck,
//    output reg spi_mosi,
//    input  wire spi_miso,


//    // user
//    input  wire i_sn_adc,

//    output reg o_en_adc,

//output reg [4:0] bit_cnt,
//    output wire [11:0] o_adc_value0,
//    output wire [11:0] o_adc_value1,
//    output wire [11:0] o_adc_value2,
//    output wire [11:0] o_adc_value3,
//    output wire [11:0] o_adc_value4,
//    output wire [11:0] o_adc_value5,
//    output wire [11:0] o_adc_value6,
//    output wire [11:0] o_adc_value7

//);



////////////////////////////////////////////////////////
//// channel mapping
////////////////////////////////////////////////////////

//wire [2:0] channel [0:7];

//assign channel[0]=CH0;
//assign channel[1]=CH1;
//assign channel[2]=CH2;
//assign channel[3]=CH3;
//assign channel[4]=CH4;
//assign channel[5]=CH5;
//assign channel[6]=CH6;
//assign channel[7]=CH7;



////////////////////////////////////////////////////////
//// ADC data
////////////////////////////////////////////////////////

//reg [11:0] adc_data[0:7];


//assign o_adc_value0 = adc_data[0];
//assign o_adc_value1 = adc_data[1];
//assign o_adc_value2 = adc_data[2];
//assign o_adc_value3 = adc_data[3];
//assign o_adc_value4 = adc_data[4];
//assign o_adc_value5 = adc_data[5];
//assign o_adc_value6 = adc_data[6];
//assign o_adc_value7 = adc_data[7];



////////////////////////////////////////////////////////
//// SPI clock
////////////////////////////////////////////////////////

//localparam CLK_DIV = 25;


//reg [7:0] div_cnt;

//reg spi_busy;



//always @(posedge clk or negedge rstn)
//begin

//    if(!rstn)
//        div_cnt<=0;

//    else if(spi_busy)
//    begin

//        if(div_cnt==CLK_DIV-1)
//            div_cnt<=0;

//        else
//            div_cnt<=div_cnt+1'b1;

//    end

//    else

//        div_cnt<=0;

//end



//wire spi_tick;

//assign spi_tick =
//        spi_busy &&
//        (div_cnt==CLK_DIV-1);



////////////////////////////////////////////////////////
//// SPI registers
////////////////////////////////////////////////////////

////reg [4:0] bit_cnt;


//reg [15:0] tx_shift;

//reg [15:0] rx_shift;


//reg [3:0] ch_index;



//// 第一次转换丢弃
//reg first_data_skip;



////////////////////////////////////////////////////////
//// SCLK rising detect
////////////////////////////////////////////////////////

//reg spi_sck_d;


//wire sck_rise;


//assign sck_rise =
//        spi_sck & ~spi_sck_d;



//always @(posedge clk or negedge rstn)
//begin

//    if(!rstn)

//        spi_sck_d<=1'b1;

//    else

//        spi_sck_d<=spi_sck;

//end


//reg [6:0] cs_wait_cnt;
//reg cs_wait;
//reg alldone;
////////////////////////////////////////////////////////
//// SPI FSM
////////////////////////////////////////////////////////

//always @(posedge clk or negedge rstn)
//begin


//if(!rstn)
//begin


//    spi_ss<=1'b1;

//    spi_sck<=1'b1;

//    spi_mosi<=1'b1;


//    spi_busy<=1'b0;


//    bit_cnt<=0;

//    ch_index<=0;


//    tx_shift<=0;

//    rx_shift<=0;


//    first_data_skip<=1'b1;

//   alldone<=0;
//cs_wait<=0;
//    o_en_adc<=0;
//cs_wait_cnt <= 7'd0;

//    adc_data[0]<=0;
//    adc_data[1]<=0;
//    adc_data[2]<=0;
//    adc_data[3]<=0;
//    adc_data[4]<=0;
//    adc_data[5]<=0;
//    adc_data[6]<=0;
//    adc_data[7]<=0;


//end


//else
//begin


//    o_en_adc<=1'b0;



//    ////////////////////////////////////////////////
//    // start conversion
//    ////////////////////////////////////////////////

//    if(!spi_busy)
//    begin


//        if(i_sn_adc)
//        begin


//            spi_busy<=1;

//            spi_ss<=0;

//            spi_sck<=1;


//          // CS建立时间等待

//            cs_wait<=0;
//            alldone<=0;
//            cs_wait_cnt<=0;


//            bit_cnt<=0;


//            rx_shift<=16'd0;
//            first_data_skip <= 1'b1;


//            /*
//            AD7928 control word

//            WRITE
//            SEQ
//            SHADOW
//            ADDRESS
//            PM1 PM0
//            RANGE
//            CODING

//            */

//            tx_shift <=
//            {
//                1'b1,
//                1'b0,
//                1'b0,
//                channel[ch_index],
//                2'b11,
//                1'b0,
//                1'b0,
//                2'b11,
//                4'b0000
//          };


//        end

//    end



//    ////////////////////////////////////////////////
//    // SPI transfer
//    ////////////////////////////////////////////////
////    else if(cs_wait)
////      begin

////    if(cs_wait_cnt==3'd5)
////    begin

////        cs_wait<=0;

////    end

////    else
////    begin

////        cs_wait_cnt<=cs_wait_cnt+1'b1;

////    end

////      end


//    else if(spi_tick&spi_ss==0)
//    begin



//        ////////////////////////////////////////////
//        // falling edge
//        ////////////////////////////////////////////

//        if(spi_sck)
//        begin


//            spi_sck<=1'b0;


//            spi_mosi<=tx_shift[15];


//            tx_shift<=
//            {
//                tx_shift[14:0],
//                1'b0
//            };


//        end



//        ////////////////////////////////////////////
//        // rising edge
//        ////////////////////////////////////////////

//        else
//        begin


//            spi_sck<=1'b1;



//            // sample MISO

//            rx_shift <=
//            {
//                rx_shift[14:0],
//                spi_miso
//            };



//            ////////////////////////////////////////
//            // receive 16 bit
//            ////////////////////////////////////////

//            if(bit_cnt==5'd15)
//            begin



//                /*
//                 当前完整数据：

//                 {rx_shift[14:0],spi_miso}

//                 bit14~12 : channel
//                 bit11~0  : data

//                */


//                if(!first_data_skip)
//                begin


//                    case(rx_shift[13:11])


//                    CH0:
//                    adc_data[0]
//                    <=
//                    {
//                        rx_shift[10:0],
//                        spi_miso
//                    };


//                    CH1:
//                    adc_data[1]
//                    <=
//                    {
//                        rx_shift[10:0],
//                        spi_miso
//                    };


//                    CH2:
//                    adc_data[2]
//                    <=
//                    {
//                        rx_shift[10:0],
//                        spi_miso
//                    };


//                    CH3:
//                    adc_data[3]
//                    <=
//                    {
//                        rx_shift[10:0],
//                        spi_miso
//                    };


//                    CH4:
//                    adc_data[4]
//                    <=
//                    {
//                        rx_shift[10:0],
//                        spi_miso
//                    };


//                    CH5:
//                    adc_data[5]
//                    <=
//                    {
//                        rx_shift[10:0],
//                        spi_miso
//                    };


//                    CH6:
//                    adc_data[6]
//                    <=
//                    {
//                        rx_shift[10:0],
//                        spi_miso
//                    };


//                    CH7:
//                    adc_data[7]
//                    <=
//                    {
//                        rx_shift[10:0],
//                        spi_miso
//                    };


//                    endcase


//                end


//                else
//                begin

//                    first_data_skip<=1'b0;

//                end



//            spi_ss<=1'b1;


//            if(ch_index < CH_CNT)
//            begin

//                ch_index <= ch_index + 1'b1;


//                 spi_busy <= 1'b1;

//               //准备下一帧

//                  tx_shift <=
//            {
//            1'b1,
//            1'b0,
//            1'b0,
//            channel[ch_index+1],
//            2'b11,
//            1'b0,
//            1'b0,
//            2'b11,
//            4'b0000
//             };

//                bit_cnt<=0;
                   

                        
                 
                    


//             end
//             else if(ch_index ==CH_CNT)
//             begin
//         spi_busy <= 1'b1;
//         //准备下一帧

//        tx_shift <=
//        {
//            1'b1,
//            1'b0,
//            1'b0,
//           3'b000,
//            2'b11,
//            1'b0,
//            1'b0,
//            2'b11,
//            4'b0000
//        };
//         bit_cnt<=0;
//           ch_index <= ch_index + 1'b1;
                                  
//              end//判断通道有没有扫描完
//            else//chindex=8
//            begin
//            alldone<=1;
//            spi_busy<=0;

//             o_en_adc<=1'b1;
//            bit_cnt<=0;
//             ch_index<=0;
          
//             end
       
//           cs_wait     <= 1'b1;
//cs_wait_cnt <= 7'd0;//拉高等待
//           end//cnt==15
       

//            else

//                bit_cnt<=bit_cnt+1'b1;



//        end//如果是上升沿
        

//    end//如果允许翻转
      
//           if(cs_wait && !alldone)
//              begin
//    if(cs_wait_cnt == 7'd120)
//    begin
//        spi_ss     <= 1'b0;
//        cs_wait    <= 1'b0;
//        cs_wait_cnt <= 7'd0;
//    end
//    else
//    begin
//        cs_wait_cnt <= cs_wait_cnt + 1'b1;
//    end
//              end
//end//如果不是复位

//end//always


//endmodule
//module adc_ad7928 #(

//    parameter [2:0] CH_CNT = 3'd7,

//    parameter [2:0] CH0 = 3'd0,
//    parameter [2:0] CH1 = 3'd1,
//    parameter [2:0] CH2 = 3'd2,
//    parameter [2:0] CH3 = 3'd3,
//    parameter [2:0] CH4 = 3'd4,
//    parameter [2:0] CH5 = 3'd5,
//    parameter [2:0] CH6 = 3'd6,
//    parameter [2:0] CH7 = 3'd7

//)
//(
//    input  wire clk,
//    input  wire rstn,


//    // SPI
//    output reg spi_ss,
//    output reg spi_sck,
//    output reg spi_mosi,
//    input  wire spi_miso,


//    // user
//    input  wire i_sn_adc,

//    output reg o_en_adc,

//output reg [4:0] bit_cnt,
//    output wire [11:0] o_adc_value0,
//    output wire [11:0] o_adc_value1,
//    output wire [11:0] o_adc_value2,
//    output wire [11:0] o_adc_value3,
//    output wire [11:0] o_adc_value4,
//    output wire [11:0] o_adc_value5,
//    output wire [11:0] o_adc_value6,
//    output wire [11:0] o_adc_value7

//);



////////////////////////////////////////////////////////
//// channel mapping
////////////////////////////////////////////////////////

//wire [2:0] channel [0:7];

//assign channel[0]=CH0;
//assign channel[1]=CH1;
//assign channel[2]=CH2;
//assign channel[3]=CH3;
//assign channel[4]=CH4;
//assign channel[5]=CH5;
//assign channel[6]=CH6;
//assign channel[7]=CH7;



////////////////////////////////////////////////////////
//// ADC data
////////////////////////////////////////////////////////

//reg [11:0] adc_data[0:7];


//assign o_adc_value0 = adc_data[0];
//assign o_adc_value1 = adc_data[1];
//assign o_adc_value2 = adc_data[2];
//assign o_adc_value3 = adc_data[3];
//assign o_adc_value4 = adc_data[4];
//assign o_adc_value5 = adc_data[5];
//assign o_adc_value6 = adc_data[6];
//assign o_adc_value7 = adc_data[7];



////////////////////////////////////////////////////////
//// SPI clock
////////////////////////////////////////////////////////

//localparam CLK_DIV = 25;


//reg [7:0] div_cnt;

//reg spi_busy;



//always @(posedge clk or negedge rstn)
//begin

//    if(!rstn)
//        div_cnt<=0;

//    else if(spi_busy)
//    begin

//        if(div_cnt==CLK_DIV-1)
//            div_cnt<=0;

//        else
//            div_cnt<=div_cnt+1'b1;

//    end

//    else

//        div_cnt<=0;

//end



//wire spi_tick;

//assign spi_tick =
//        spi_busy &&
//        (div_cnt==CLK_DIV-1);



////////////////////////////////////////////////////////
//// SPI registers
////////////////////////////////////////////////////////

////reg [4:0] bit_cnt;


//reg [15:0] tx_shift;

//// 3位通道地址 + 12位ADC数据
//reg [14:0] rx_shift;


//reg [3:0] ch_index;



//// 第一次转换丢弃
//reg first_data_skip;



////////////////////////////////////////////////////////
//// SCLK rising detect
////////////////////////////////////////////////////////

//reg spi_sck_d;


//wire sck_rise;


//assign sck_rise =
//        spi_sck & ~spi_sck_d;



//always @(posedge clk or negedge rstn)
//begin

//    if(!rstn)

//        spi_sck_d<=1'b1;

//    else

//        spi_sck_d<=spi_sck;

//end
//reg [6:0] cs_high_cnt;
//reg cs_waithigh;

//reg [6:0] cs_wait_cnt;
//reg cs_wait;
//reg alldone;
////////////////////////////////////////////////////////
//// SPI FSM
////////////////////////////////////////////////////////

//always @(posedge clk or negedge rstn)
//begin


//if(!rstn)
//begin


//    spi_ss<=1'b1;

//    spi_sck<=1'b1;

//    spi_mosi<=1'b1;


//    spi_busy<=1'b0;


//    bit_cnt<=0;

//    ch_index<=0;


//    tx_shift<=0;

//    rx_shift<=0;


//    first_data_skip<=1'b1;

//   alldone<=0;
//cs_wait<=0;
//    o_en_adc<=0;
//cs_wait_cnt <= 7'd0;
//cs_high_cnt<=0;
//  cs_waithigh<=0;
//    adc_data[0]<=0;
//    adc_data[1]<=0;
//    adc_data[2]<=0;
//    adc_data[3]<=0;
//    adc_data[4]<=0;
//    adc_data[5]<=0;
//    adc_data[6]<=0;
//    adc_data[7]<=0;


//end


//else
//begin


//    o_en_adc<=1'b0;



//    ////////////////////////////////////////////////
//    // start conversion
//    ////////////////////////////////////////////////

//    if(!spi_busy&!cs_waithigh)
//    begin


//        if(i_sn_adc)
//        begin


//            spi_busy<=1;

//            spi_ss<=0;

//            spi_sck<=1;


//          // CS建立时间等待

//            cs_wait<=0;
//            alldone<=0;
//            cs_wait_cnt<=0;
// cs_high_cnt<=0;
//  cs_waithigh<=0;

//            bit_cnt<=0;


//            rx_shift<=15'd0;
//            first_data_skip <= 1'b1;


//            /*
//            AD7928 control word

//            WRITE
//            SEQ
//            SHADOW
//            ADDRESS
//            PM1 PM0
//            RANGE
//            CODING

//            */

//            tx_shift <=
//            {
//                1'b1,
//                1'b0,
//                1'b0,
//                channel[ch_index],
//                2'b11,
//                1'b0,
//                1'b0,
//                2'b11,
//                4'b0000
//          };


//        end

//    end



//    ////////////////////////////////////////////////
//    // SPI transfer
//    ////////////////////////////////////////////////
////    else if(cs_wait)
////      begin

////    if(cs_wait_cnt==3'd5)
////    begin

////        cs_wait<=0;

////    end

////    else
////    begin

////        cs_wait_cnt<=cs_wait_cnt+1'b1;

////    end

////      end


//    else if(spi_tick&spi_ss==0&!cs_waithigh)
//    begin



//        ////////////////////////////////////////////
//        // falling edge
//        ////////////////////////////////////////////

//        if(spi_sck)
//        begin


//            spi_sck<=1'b0;


     


//        end



//        ////////////////////////////////////////////
//        // rising edge
//        ////////////////////////////////////////////

//        else
//        begin


//            spi_sck<=1'b1;



//            // sample MISO

//          if(bit_cnt < 5'd15)
//           begin
//        rx_shift <= {
//            rx_shift[13:0],
//            spi_miso
//        };
//            end

//            //准备下一bit
//                 spi_mosi <= tx_shift[15];

//                tx_shift <= {
//                 tx_shift[14:0],
//                    1'b0
//                    };

//            ////////////////////////////////////////
//            // receive 16 bit
//            ////////////////////////////////////////

//            if(bit_cnt==5'd15)
//            begin



//                /*
//                 当前完整数据：

//                 {rx_shift[14:0],spi_miso}

//                 bit14~12 : channel
//                 bit11~0  : data

//                */


//                if(!first_data_skip)
//                begin


//                    case(rx_shift[14:12])


//                    CH0:
//                begin
//                    adc_data[0] <= rx_shift[11:0];
//                end

//                CH1:
//                begin
//                    adc_data[1] <= rx_shift[11:0];
//                end

//                CH2:
//                begin
//                    adc_data[2] <= rx_shift[11:0];
//                end

//                CH3:
//                begin
//                    adc_data[3] <= rx_shift[11:0];
//                end

//                CH4:
//                begin
//                    adc_data[4] <= rx_shift[11:0];
//                end

//                CH5:
//                begin
//                    adc_data[5] <= rx_shift[11:0];
//                end

//                CH6:
//                begin
//                    adc_data[6] <= rx_shift[11:0];
//                end

//                CH7:
//                begin
//                    adc_data[7] <= rx_shift[11:0];
//                end

//                default:
//                begin
//                    // 无效地址，不更新数据
//                end


//                    endcase


//                end


//                else
//                begin

//                    first_data_skip<=1'b0;

//                end




// cs_waithigh<=1;



//            if(ch_index < CH_CNT)
//            begin

//                ch_index <= ch_index + 1'b1;


//                 spi_busy <= 1'b1;

//               //准备下一帧

//                  tx_shift <=
//            {
//            1'b1,
//            1'b0,
//            1'b0,
//            channel[ch_index+1],
//            2'b11,
//            1'b0,
//            1'b0,
//            2'b11,
//            4'b0000
//             };

//                bit_cnt<=0;
//                   rx_shift <= 15'd0;

                        
                 
                    


//             end
//             else if(ch_index ==CH_CNT)
//             begin
//         spi_busy <= 1'b1;
//         //准备下一帧

//        tx_shift <=
//        {
//            1'b1,
//            1'b0,
//            1'b0,
//           3'b000,
//            2'b11,
//            1'b0,
//            1'b0,
//            2'b11,
//            4'b0000
//        };
//         bit_cnt<=0;
//           ch_index <= ch_index + 1'b1;
//                 rx_shift <= 15'd0;                 
//              end//判断通道有没有扫描完
//            else//chindex=8
//            begin
//            alldone<=1;
//            spi_busy<=0;

//             o_en_adc<=1'b1;
//            bit_cnt<=0;
//             ch_index<=0;
//          rx_shift <= 15'd0;
//             end
       
//          cs_waithigh    <= 1'b1;
//cs_high_cnt <= 7'd0;//拉高等待
//           end//cnt==15
       

//            else

//                bit_cnt<=bit_cnt+1'b1;



//        end//如果是上升沿
        

//    end//如果允许翻转
      
      
//   else    if(cs_waithigh)
//              begin
//    if(cs_high_cnt == 7'd120)
//    begin
//        spi_ss     <= 1'b1;
//        cs_waithigh    <= 1'b0;
//        cs_wait<=1'b1;
//       cs_high_cnt <= 7'd0;
//    end
//    else
//    begin
//       cs_high_cnt <= cs_high_cnt + 1'b1;
//    end
//              end
//    else       if(cs_wait && !alldone)
//              begin
//    if(cs_wait_cnt == 7'd120)
//    begin
//        spi_ss     <= 1'b0;
//        cs_wait    <= 1'b0;
//        cs_wait_cnt <= 7'd0;
//    end
//    else
//    begin
//        cs_wait_cnt <= cs_wait_cnt + 1'b1;
//    end
//              end
              
         
//end//如果不是复位

//end//always


//endmodule 



////--------------------------------------------------------------------------------------------------------
//// 模块: adc_ad7928
//// Type    : synthesizable
//// Standard: Verilog 2001 (IEEE1364-2001)
//// 功能：通过 SPI 接口从 ADC7928 (ADC芯片) 中读出 ADC 值。
//// 参数：详见下方注释，该模块可以使用参数完全自由地配置单次转换要用多少个通道以及用哪些通道
//// 输入输出：详见下方注释
////--------------------------------------------------------------------------------------------------------

//module adc_ad7928 #(
//    parameter [2:0] CH_CNT = 3'd7,  // 单次 ADC 转换使用的通道数为 CH_CNT+1，例如若 CH_CNT=0，则只使用 CH0 。若 CH_CNT=2，则使用 CH0,CH1,CH2。 若 CH_CNT=7，则使用 CH0,CH1,CH2,CH3,CH4,CH5,CH6,CH7。用的通道越多，ADC转换时延越长（即从 sn_adc 到 en_adc 之间的时间差越长）
//    parameter [2:0] CH0 = 3'd0,     // 指示了 CH0 对应 AD7928 的哪个通道
//    parameter [2:0] CH1 = 3'd1,     // 指示了 CH1 对应 AD7928 的哪个通道
//    parameter [2:0] CH2 = 3'd2,     // 指示了 CH2 对应 AD7928 的哪个通道
//    parameter [2:0] CH3 = 3'd3,     // 指示了 CH3 对应 AD7928 的哪个通道
//    parameter [2:0] CH4 = 3'd4,     // 指示了 CH4 对应 AD7928 的哪个通道
//    parameter [2:0] CH5 = 3'd5,     // 指示了 CH5 对应 AD7928 的哪个通道
//    parameter [2:0] CH6 = 3'd6,     // 指示了 CH6 对应 AD7928 的哪个通道
//    parameter [2:0] CH7 = 3'd7      // 指示了 CH7 对应 AD7928 的哪个通道
//) (
//    input  wire        rstn,
//    input  wire        clk,
//    // -------------------- SPI 接口，应该接到 AD7928 芯片上   ---------------------------------------------------------------
//    output reg         spi_ss,      // SPI 接口：SS
//    output reg         spi_sck,     // SPI 接口：SCK
//    output reg         spi_mosi,    // SPI 接口：MOSI
//    input  wire        spi_miso,    // SPI 接口：MISO
//    // -------------------- 用户逻辑接口  ------------------------------------------------------------------------------------
//    input  wire        i_sn_adc,    // ADC 转换开始信号，当 i_sn_adc 上出现高电平脉冲时，ADC转换开始
//    output reg         o_en_adc,  
//    output reg adc_addr_error,  // ADC 转换完成信号，当转换完成时，o_en_adc 产生一个时钟周期的高电平脉冲
//    output wire [11:0] o_adc_value0,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH0 的 ADC 转换结果出现在该信号上
//    output wire [11:0] o_adc_value1,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH1 的 ADC 转换结果出现在该信号上
//    output wire [11:0] o_adc_value2,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH2 的 ADC 转换结果出现在该信号上
//    output wire [11:0] o_adc_value3,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH3 的 ADC 转换结果出现在该信号上
//    output wire [11:0] o_adc_value4,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH4 的 ADC 转换结果出现在该信号上
//    output wire [11:0] o_adc_value5,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH5 的 ADC 转换结果出现在该信号上
//    output wire [11:0] o_adc_value6,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH6 的 ADC 转换结果出现在该信号上
//    output wire [11:0] o_adc_value7 // 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH7 的 ADC 转换结果出现在该信号上
//);

//localparam WAIT_CNT = 8'd6;

//wire [2:0] channels [0:7];
//assign channels[0] = CH0;
//assign channels[1] = CH1;
//assign channels[2] = CH2;
//assign channels[3] = CH3;
//assign channels[4] = CH4;
//assign channels[5] = CH5;
//assign channels[6] = CH6;
//assign channels[7] = CH7;
//reg first_convert;
//reg  [ 7:0] cnt;
//reg  [ 2:0] idx;
//reg  [ 2:0] addr;
//reg  [11:0] wshift;
//reg         nfirst;
//// 保存AD7928返回的15bit
//// bit14:12 = ADD2~ADD0
//// bit11:0  = ADC DATA
//reg [14:0] data_in_latch;
//reg         sck_pre;
//reg  [11:0] ch_value [0:7];
//reg [2:0] last_channel;
//assign o_adc_value0 = ch_value[0];
//assign o_adc_value1 = ch_value[1];
//assign o_adc_value2 = ch_value[2];
//assign o_adc_value3 = ch_value[3];
//assign o_adc_value4 = ch_value[4];
//assign o_adc_value5 = ch_value[5];
//assign o_adc_value6 = ch_value[6];
//assign o_adc_value7 = ch_value[7];

//always @ (posedge clk or negedge rstn)
//    if(~rstn)
//        spi_sck <= 1'b1;
//    else
//        spi_sck <= sck_pre;

//always @ (posedge clk or negedge rstn)
//    if(~rstn) begin
      
//        cnt <= 0;
//        idx <= 3'd7;
//        addr <= 3'd0;
//        wshift <= 12'hFFF;
//        {spi_ss, sck_pre, spi_mosi} <= 3'b111;
//    end else begin
//        if(cnt==8'd0) begin
//            {spi_ss, sck_pre, spi_mosi} <= 3'b111;
//            if(idx != 3'd0) begin
//                cnt <= 8'd1;
//                idx <= idx - 3'd1;
//            end else if(i_sn_adc) begin
//                cnt <= 8'd1;
//                idx <= CH_CNT;
//            end
//        end else if(cnt==8'd1) begin
//            {spi_ss, sck_pre, spi_mosi} <= 3'b111;
//            addr <= (idx == 3'd0) ? CH_CNT : idx - 3'd1;
//            cnt <= cnt + 8'd1;
//        end else if(cnt==8'd2) begin
//            {spi_ss, sck_pre, spi_mosi} <= 3'b111;
//          last_channel <= channels[addr];

//wshift <= {
//    1'b1,
//    1'b0,
//    1'b0,
//    channels[addr],
//    2'b11,
//    1'b0,
//    1'b0,
//    2'b11
//};
//            cnt <= cnt + 8'd1;
//        end else if(cnt<WAIT_CNT) begin
//            {spi_ss, sck_pre, spi_mosi} <= 3'b111;
//            cnt <= cnt + 8'd1;
//        end else if(cnt<WAIT_CNT+8'd32) begin
//            spi_ss <= 1'b0;
//            sck_pre <= ~sck_pre;
//            if(sck_pre)
//                {spi_mosi,wshift} <= {wshift,1'b1};
//            cnt <= cnt + 8'd1;
//        end else begin
//            spi_ss <= 1'b0;
//            {sck_pre, spi_mosi} <= 2'b11;
//            cnt <= 8'd0;
//        end
//    end


//always @ (posedge clk or negedge rstn)
//    if(~rstn) begin
//     adc_addr_error<=0;
//    first_convert <= 1'b0;
//        o_en_adc <= 1'b0;
//        nfirst <= 1'b0;
//        data_in_latch <= 15'd0;
//        ch_value[0] <= 12'd0;
//        ch_value[1] <= 12'd0;
//        ch_value[2] <= 12'd0;
//        ch_value[3] <= 12'd0;
//        ch_value[4] <= 12'd0;
//        ch_value[5] <= 12'd0;
//        ch_value[6] <= 12'd0;
//        ch_value[7] <= 12'd0;
//    end else begin
//        o_en_adc <= 1'b0;
//        if(cnt>=WAIT_CNT+8'd2 && cnt<WAIT_CNT+8'd32) begin
//            if(spi_sck)
             
//               begin
//        data_in_latch <= {
//            data_in_latch[13:0],
//            spi_miso
//        };
//               end
//        end else if(cnt==WAIT_CNT+8'd32) begin
//            if(idx == 3'd0) begin
//                nfirst <= 1'b1;
//                o_en_adc <= nfirst;
//            end
//           // 检查AD7928返回地址
//if(data_in_latch[14:12] == last_channel)
//begin
//    adc_addr_error <= 1'b0;
//    case(last_channel)

//    CH0:
//        ch_value[0] <= data_in_latch[11:0];

//    CH1:
//        ch_value[1] <= data_in_latch[11:0];

//    CH2:
//        ch_value[2] <= data_in_latch[11:0];

//    CH3:
//        ch_value[3] <= data_in_latch[11:0];

//    CH4:
//        ch_value[4] <= data_in_latch[11:0];

//    CH5:
//        ch_value[5] <= data_in_latch[11:0];

//    CH6:
//        ch_value[6] <= data_in_latch[11:0];

//    CH7:
//        ch_value[7] <= data_in_latch[11:0];

//    default:
//        ;

//    endcase

//end
//else
//begin

//    adc_addr_error <= 1'b1;

//end
//        end
//    end

//endmodule

//--------------------------------------------------------------------------------------------------------
// 模块: adc_ad7928
// Type    : synthesizable
// Standard: Verilog 2001 (IEEE1364-2001)
// 功能：通过 SPI 接口从 ADC7928 (ADC芯片) 中读出 ADC 值。
// 参数：详见下方注释，该模块可以使用参数完全自由地配置单次转换要用多少个通道以及用哪些通道
// 输入输出：详见下方注释
//--------------------------------------------------------------------------------------------------------

module adc_ad7928 #(
    parameter [2:0] CH_CNT = 3'd7,  // 单次 ADC 转换使用的通道数为 CH_CNT+1，例如若 CH_CNT=0，则只使用 CH0 。若 CH_CNT=2，则使用 CH0,CH1,CH2。 若 CH_CNT=7，则使用 CH0,CH1,CH2,CH3,CH4,CH5,CH6,CH7。用的通道越多，ADC转换时延越长（即从 sn_adc 到 en_adc 之间的时间差越长）
    parameter [2:0] CH0 = 3'd0,     // 指示了 CH0 对应 AD7928 的哪个通道
    parameter [2:0] CH1 = 3'd1,     // 指示了 CH1 对应 AD7928 的哪个通道
    parameter [2:0] CH2 = 3'd2,     // 指示了 CH2 对应 AD7928 的哪个通道
    parameter [2:0] CH3 = 3'd3,     // 指示了 CH3 对应 AD7928 的哪个通道
    parameter [2:0] CH4 = 3'd4,     // 指示了 CH4 对应 AD7928 的哪个通道
    parameter [2:0] CH5 = 3'd5,     // 指示了 CH5 对应 AD7928 的哪个通道
    parameter [2:0] CH6 = 3'd6,     // 指示了 CH6 对应 AD7928 的哪个通道
    parameter [2:0] CH7 = 3'd7      // 指示了 CH7 对应 AD7928 的哪个通道
) (
    input  wire        rstn,
    input  wire        clk,
    // -------------------- SPI 接口，应该接到 AD7928 芯片上   ---------------------------------------------------------------
    output reg         spi_ss,      // SPI 接口：SS
    output reg         spi_sck,     // SPI 接口：SCK
    output reg         spi_mosi,    // SPI 接口：MOSI
    input  wire        spi_miso,    // SPI 接口：MISO
    output reg  signed [15:0] i_a, i_b, i_c,
    // -------------------- 用户逻辑接口  ------------------------------------------------------------------------------------
    input  wire        i_sn_adc,    // ADC 转换开始信号，当 i_sn_adc 上出现高电平脉冲时，ADC转换开始
    output reg         o_en_adc,    // ADC 转换完成信号，当转换完成时，o_en_adc 产生一个时钟周期的高电平脉冲
    output wire [11:0] o_adc_value0,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH0 的 ADC 转换结果出现在该信号上
    output wire [11:0] o_adc_value1,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH1 的 ADC 转换结果出现在该信号上
    output wire [11:0] o_adc_value2,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH2 的 ADC 转换结果出现在该信号上
    output wire [11:0] o_adc_value3,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH3 的 ADC 转换结果出现在该信号上
    output wire [11:0] o_adc_value4,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH4 的 ADC 转换结果出现在该信号上
    output wire [11:0] o_adc_value5,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH5 的 ADC 转换结果出现在该信号上
    output wire [11:0] o_adc_value6,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH6 的 ADC 转换结果出现在该信号上
    output wire [11:0] o_adc_value7 // 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH7 的 ADC 转换结果出现在该信号上
);

localparam WAIT_CNT = 8'd6;

wire [2:0] channels [0:7];
assign channels[0] = CH0;
assign channels[1] = CH1;
assign channels[2] = CH2;
assign channels[3] = CH3;
assign channels[4] = CH4;
assign channels[5] = CH5;
assign channels[6] = CH6;
assign channels[7] = CH7;

reg  [ 7:0] cnt;
reg  [ 2:0] idx;
reg  [ 2:0] addr;
reg  [11:0] wshift;
reg         nfirst;
reg  [11:0] data_in_latch;
reg         sck_pre;
reg  [11:0] ch_value [0:7];

assign o_adc_value0 = ch_value[0];
assign o_adc_value1 = ch_value[1];
assign o_adc_value2 = ch_value[2];
assign o_adc_value3 = ch_value[3];
assign o_adc_value4 = ch_value[4];
assign o_adc_value5 = ch_value[5];
assign o_adc_value6 = ch_value[6];
assign o_adc_value7 = ch_value[7];

always @ (posedge clk or negedge rstn)
    if(~rstn)
        spi_sck <= 1'b1;
    else
        spi_sck <= sck_pre;

always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        cnt <= 0;
        idx <= 3'd7;
        addr <= 3'd0;
        wshift <= 12'hFFF;
        {spi_ss, sck_pre, spi_mosi} <= 3'b111;
    end else begin
        if(cnt==8'd0) begin
            {spi_ss, sck_pre, spi_mosi} <= 3'b111;
            if(idx != 3'd0) begin
                cnt <= 8'd1;
                idx <= idx - 3'd1;
            end else if(i_sn_adc) begin
                cnt <= 8'd1;
                idx <= CH_CNT;
            end
        end else if(cnt==8'd1) begin
            {spi_ss, sck_pre, spi_mosi} <= 3'b111;
            addr <= (idx == 3'd0) ? CH_CNT : idx - 3'd1;
            cnt <= cnt + 8'd1;
        end else if(cnt==8'd2) begin
            {spi_ss, sck_pre, spi_mosi} <= 3'b111;
            wshift <= {1'b1, 1'b0, 1'b0, channels[addr], 2'b11, 1'b0, 1'b0, 2'b11};
            cnt <= cnt + 8'd1;
        end else if(cnt<WAIT_CNT) begin
            {spi_ss, sck_pre, spi_mosi} <= 3'b111;
            cnt <= cnt + 8'd1;
        end else if(cnt<WAIT_CNT+8'd32) begin
            spi_ss <= 1'b0;
            sck_pre <= ~sck_pre;
            if(sck_pre)
                {spi_mosi,wshift} <= {wshift,1'b1};
            cnt <= cnt + 8'd1;
        end else begin
            spi_ss <= 1'b0;
            {sck_pre, spi_mosi} <= 2'b11;
            cnt <= 8'd0;
        end
    end


always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        o_en_adc <= 1'b0;
        nfirst <= 1'b0;
        data_in_latch <= 12'd0;
        ch_value[0] <= 12'd0;
        ch_value[1] <= 12'd0;
        ch_value[2] <= 12'd0;
        ch_value[3] <= 12'd0;
        ch_value[4] <= 12'd0;
        ch_value[5] <= 12'd0;
        ch_value[6] <= 12'd0;
        ch_value[7] <= 12'd0;
    end else begin
        o_en_adc <= 1'b0;
        if(cnt>=WAIT_CNT+8'd2 && cnt<WAIT_CNT+8'd32) begin
            if(spi_sck)
                data_in_latch <= {data_in_latch[10:0], spi_miso};
        end else if(cnt==WAIT_CNT+8'd32) begin
            if(idx == 3'd0) begin
                nfirst <= 1'b1;
                o_en_adc <= nfirst;
    
    
  
            i_a <= $signed( {4'b0, ch_value[3]} + {4'b0, ch_value[2]} - {3'b0, ch_value[4], 1'b0} );   // Ia = ADCb + ADCc - 2*ADCa
            i_b <= $signed( {4'b0, ch_value[4]} + {4'b0, ch_value[2]} - {3'b0, ch_value[3], 1'b0} );   // Ib = ADCa + ADCc - 2*ADCb
            i_c <= $signed( {4'b0, ch_value[4]} + {4'b0, ch_value[3]} - {3'b0, ch_value[2], 1'b0} );   // Ic = ADCa + ADCb - 2*ADCc
    
                
                
            end
            ch_value[idx] <= data_in_latch;
        end
    end

endmodule
