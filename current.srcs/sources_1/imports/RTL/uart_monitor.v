
//////--------------------------------------------------------------------------------------------------------
////// 模块    ：uart_monitor
////// 类型    ：Synthesizable
////// 标准    ：Verilog-2001
////// 功能    ：将3个12位无符号数转换成十进制，通过UART发送
////// UART格式：8位数据位、无校验、1位停止位（8N1）
////// 输出格式："xxxx xxxx xxxx\r\n"
////// 例如    ：12、345、4095 -> "  12  345 4095\r\n"
//////--------------------------------------------------------------------------------------------------------

//module uart_monitor #(
//    parameter [15:0] CLK_DIV = 16'd25
//)(
//    input  wire        clk,
//    input  wire        rstn,

//    // 上升沿触发一次发送
//    input  wire        i_en,

//    // ADC数据
//    input  wire [11:0] i_val0,
//    input  wire [11:0] i_val1,
//    input  wire [11:0] i_val2,

//    // 错误输入
//    input  wire        i_error,

//    // UART
//    output reg         o_uart_tx
//);


/////====================================================
//// 12bit ADC整数 转 IEEE754 float32
//// 输入范围: 0~4095
//// 输出: IEEE754格式32bit
////====================================================

//function [31:0] adc12_to_float;

//input [11:0] adc;

//reg [4:0] msb;
//reg [7:0] exponent;
//reg [22:0] mantissa;

//begin


//    if(adc==12'd0)
//    begin

//        adc12_to_float = 32'h00000000;

//    end


//    else
//    begin


//        //========================
//        // 找最高位
//        //========================

//        if(adc[11])
//            msb=11;
//        else if(adc[10])
//            msb=10;
//        else if(adc[9])
//            msb=9;
//        else if(adc[8])
//            msb=8;
//        else if(adc[7])
//            msb=7;
//        else if(adc[6])
//            msb=6;
//        else if(adc[5])
//            msb=5;
//        else if(adc[4])
//            msb=4;
//        else if(adc[3])
//            msb=3;
//        else if(adc[2])
//            msb=2;
//        else if(adc[1])
//            msb=1;
//        else
//            msb=0;



//        //========================
//        // exponent
//        //========================

//        exponent = msb + 127;



//        //========================
//        // mantissa
//        //========================

//        mantissa = 23'd0;


//        if(msb != 0)
//        begin

//            mantissa =
//            (adc << (23-msb))
//            & 23'h7fffff;

//        end



//        adc12_to_float =
//        {
//            1'b0,
//            exponent,
//            mantissa
//        };


//    end

//end

//endfunction

//wire [31:0] float0;
//wire [31:0] float1;
//wire [31:0] float2;


//assign float0 = adc12_to_float(i_val0);

//assign float1 = adc12_to_float(i_val1);

//assign float2 = adc12_to_float(i_val2);






////====================================================
//// 输入触发检测
////====================================================

//reg i_en_d;

//wire i_en_rise;

//assign i_en_rise = i_en & ~i_en_d;


//always @(posedge clk or negedge rstn)
//begin

//    if(!rstn)
//        i_en_d<=1'b0;
//    else
//        i_en_d<=i_en;

//end



////====================================================
//// 发送缓存
////====================================================

//reg [7:0] send_buf[0:31];

//reg [5:0] send_length;

//reg [5:0] send_index;





////====================================================
//// UART控制
////====================================================

//reg tx_start;
//reg [7:0] tx_data;

//reg tx_busy;
//reg tx_done;



//localparam
//ST_IDLE     =2'd0,
//ST_START   =2'd1,
//ST_WAIT    =2'd2;


//reg [1:0] state;



////====================================================
//// 主控制
////====================================================

//always @(posedge clk or negedge rstn)
//begin

//if(!rstn)
//begin

//    state<=ST_IDLE;

//    send_index<=0;
//    send_length<=16;

//    tx_start<=0;
//    tx_data<=0;

//end

//else
//begin


//    tx_start<=0;


//    case(state)


//    //--------------------------------
//    // 等待触发
//    //--------------------------------

//    ST_IDLE:
//    begin

//        if(i_en_rise)
//        begin

//            send_index<=0;


//            if(i_error)
//            begin

//                //----------------------
//                // ERROR
//                //----------------------

//                send_buf[0]<="E";
//                send_buf[1]<="R";
//                send_buf[2]<="R";
//                send_buf[3]<="O";
//                send_buf[4]<="R";

//                send_buf[5]<=8'h0D;
//                send_buf[6]<=8'h0A;


//                send_length<=7;


//            end


//            else
//begin


////===========================
//// float0
////===========================

//send_buf[0] <= float0[7:0];
//send_buf[1] <= float0[15:8];
//send_buf[2] <= float0[23:16];
//send_buf[3] <= float0[31:24];



////===========================
//// float1
////===========================

//send_buf[4] <= float1[7:0];
//send_buf[5] <= float1[15:8];
//send_buf[6] <= float1[23:16];
//send_buf[7] <= float1[31:24];



////===========================
//// float2
////===========================

//send_buf[8]  <= float2[7:0];
//send_buf[9]  <= float2[15:8];
//send_buf[10] <= float2[23:16];
//send_buf[11] <= float2[31:24];



////===========================
//// JustFloat帧尾
////===========================

//send_buf[12] <= 8'h00;
//send_buf[13] <= 8'h00;
//send_buf[14] <= 8'h80;
//send_buf[15] <= 8'h7f;



//send_length <= 16;


//end

//            state<=ST_START;

//        end

//    end



//    //--------------------------------
//    // 启动一个字节
//    //--------------------------------

//    ST_START:
//    begin

//        if(!tx_busy)
//        begin

//            tx_data<=send_buf[send_index];

//            tx_start<=1'b1;

//            state<=ST_WAIT;

//        end

//    end



//    //--------------------------------
//    // 等待完成
//    //--------------------------------

//    ST_WAIT:
//    begin

//        if(tx_done)
//        begin

//            if(send_index == send_length-1)
//            begin

//                send_index<=0;

//                state<=ST_IDLE;

//            end

//            else
//            begin

//                send_index<=send_index+1'b1;

//                state<=ST_START;

//            end

//        end

//    end



//    default:
//        state<=ST_IDLE;


//    endcase


//end

//end



////====================================================
//// UART发送器
////====================================================

//reg [15:0] baud_cnt;

//reg [3:0] bit_cnt;

//reg [9:0] tx_shift;



//always @(posedge clk or negedge rstn)
//begin


//if(!rstn)
//begin

//    o_uart_tx<=1'b1;

//    baud_cnt<=0;

//    bit_cnt<=0;

//    tx_shift<=10'h3ff;

//    tx_busy<=0;

//    tx_done<=0;

//end

//else
//begin


//    tx_done<=0;



//    if(!tx_busy)
//    begin

//        o_uart_tx<=1'b1;

//        baud_cnt<=0;


//        if(tx_start)
//        begin

//            tx_shift <= {
//                1'b1,
//                tx_data,
//                1'b0
//            };


//            tx_busy<=1'b1;

//            bit_cnt<=10;

//        end

//    end


//    else
//    begin

//        o_uart_tx<=tx_shift[0];


//        if(baud_cnt < CLK_DIV-1)
//        begin

//            baud_cnt<=baud_cnt+1'b1;

//        end

//        else
//        begin

//            baud_cnt<=0;


//            tx_shift<={
//                1'b1,
//                tx_shift[9:1]
//            };


//            if(bit_cnt==1)
//            begin

//                tx_busy<=0;

//                tx_done<=1;

//                bit_cnt<=0;

//                o_uart_tx<=1'b1;

//            end

//            else
//            begin

//                bit_cnt<=bit_cnt-1'b1;

//            end

//        end

//    end

//end

//end


//endmodule
//三相电流波形




module uart_monitor #(
    parameter [15:0] CLK_DIV = 16'd72
)(
    input  wire        clk,
    input  wire        rstn,

    // 上升沿触发一次发送
    input  wire        i_en,

    // ADC数据
    input wire signed [15:0] i_val0,
input wire signed [15:0] i_val1,

//     错误输入
    input  wire        i_error,

    // UART
    output reg         o_uart_tx
);


//====================================================
// int16 转 IEEE754 float32
//====================================================

function [31:0] int16_to_float;

input signed [15:0] data;

reg sign;
reg [15:0] abs_data;
reg [4:0] msb;
reg [7:0] exponent;
reg [22:0] mantissa;

begin


    if(data==0)
    begin

        int16_to_float = 32'h00000000;

    end


    else
    begin


        // 符号位

        sign = data[15];


        // 取绝对值

        if(sign)

            abs_data = (~data)+1'b1;

        else

            abs_data = data;



        // 找最高位

        if(abs_data[15])
            msb=15;
        else if(abs_data[14])
            msb=14;
        else if(abs_data[13])
            msb=13;
        else if(abs_data[12])
            msb=12;
        else if(abs_data[11])
            msb=11;
        else if(abs_data[10])
            msb=10;
        else if(abs_data[9])
            msb=9;
        else if(abs_data[8])
            msb=8;
        else if(abs_data[7])
            msb=7;
        else if(abs_data[6])
            msb=6;
        else if(abs_data[5])
            msb=5;
        else if(abs_data[4])
            msb=4;
        else if(abs_data[3])
            msb=3;
        else if(abs_data[2])
            msb=2;
        else if(abs_data[1])
            msb=1;
        else
            msb=0;



        exponent = msb + 127;



        mantissa = 0;


        if(msb!=0)

        begin

            mantissa =
            (abs_data << (23-msb))
            & 23'h7fffff;

        end



        int16_to_float =
        {
            sign,
            exponent,
            mantissa
        };


    end


end

endfunction
wire [31:0] float0;
wire [31:0] float1;


assign float0 = int16_to_float(i_val0);

assign float1 = int16_to_float(i_val1);
wire [31:0] float0;
wire [31:0] float1;
wire [31:0] float2;









//====================================================
// 输入触发检测
//====================================================

reg i_en_d;

wire i_en_rise;

assign i_en_rise = i_en & ~i_en_d;


always @(posedge clk or negedge rstn)
begin

    if(!rstn)
        i_en_d<=1'b0;
    else
        i_en_d<=i_en;

end



//====================================================
// 发送缓存
//====================================================

reg [7:0] send_buf[0:31];

reg [5:0] send_length;

reg [5:0] send_index;





//====================================================
// UART控制
//====================================================

reg tx_start;
reg [7:0] tx_data;

reg tx_busy;
reg tx_done;



localparam
ST_IDLE     =2'd0,
ST_START   =2'd1,
ST_WAIT    =2'd2;


reg [1:0] state;



//====================================================
// 主控制
//====================================================

always @(posedge clk or negedge rstn)
begin

if(!rstn)
begin

    state<=ST_IDLE;

    send_index<=0;
    send_length<=12;

    tx_start<=0;
    tx_data<=0;

end

else
begin


    tx_start<=0;


    case(state)


    //--------------------------------
    // 等待触发
    //--------------------------------

    ST_IDLE:
    begin

        if(i_en_rise)
        begin

            send_index<=0;


            if(i_error)
            begin

                //----------------------
                // ERROR
                //----------------------

                send_buf[0]<="E";
                send_buf[1]<="R";
                send_buf[2]<="R";
                send_buf[3]<="O";
                send_buf[4]<="R";

                send_buf[5]<=8'h0D;
                send_buf[6]<=8'h0A;


                send_length<=7;


            end


            else
begin


//===========================
// float0
// 4 Byte
//===========================

send_buf[0] <= float0[7:0];
send_buf[1] <= float0[15:8];
send_buf[2] <= float0[23:16];
send_buf[3] <= float0[31:24];



//===========================
// float1
// 4 Byte
//===========================

send_buf[4] <= float1[7:0];
send_buf[5] <= float1[15:8];
send_buf[6] <= float1[23:16];
send_buf[7] <= float1[31:24];



//===========================
// JustFloat帧尾
//===========================

send_buf[8]  <= 8'h00;
send_buf[9]  <= 8'h00;
send_buf[10] <= 8'h80;
send_buf[11] <= 8'h7f;



// 总长度
send_length <= 12;


end
            state<=ST_START;

        end

    end



    //--------------------------------
    // 启动一个字节
    //--------------------------------

    ST_START:
    begin

        if(!tx_busy)
        begin

            tx_data<=send_buf[send_index];

            tx_start<=1'b1;

            state<=ST_WAIT;

        end

    end



    //--------------------------------
    // 等待完成
    //--------------------------------

    ST_WAIT:
    begin

        if(tx_done)
        begin

            if(send_index == send_length-1)
            begin

                send_index<=0;

                state<=ST_IDLE;

            end

            else
            begin

                send_index<=send_index+1'b1;

                state<=ST_START;

            end

        end

    end



    default:
        state<=ST_IDLE;


    endcase


end

end



//====================================================
// UART发送器
//====================================================

reg [15:0] baud_cnt;

reg [3:0] bit_cnt;

reg [9:0] tx_shift;



always @(posedge clk or negedge rstn)
begin


if(!rstn)
begin

    o_uart_tx<=1'b1;

    baud_cnt<=0;

    bit_cnt<=0;

    tx_shift<=10'h3ff;

    tx_busy<=0;

    tx_done<=0;

end

else
begin


    tx_done<=0;



    if(!tx_busy)
    begin

        o_uart_tx<=1'b1;

        baud_cnt<=0;


        if(tx_start)
        begin

            tx_shift <= {
                1'b1,
                tx_data,
                1'b0
            };


            tx_busy<=1'b1;

            bit_cnt<=10;

        end

    end


    else
    begin

        o_uart_tx<=tx_shift[0];


        if(baud_cnt < CLK_DIV-1)
        begin

            baud_cnt<=baud_cnt+1'b1;

        end

        else
        begin

            baud_cnt<=0;


            tx_shift<={
                1'b1,
                tx_shift[9:1]
            };


            if(bit_cnt==1)
            begin

                tx_busy<=0;

                tx_done<=1;

                bit_cnt<=0;

                o_uart_tx<=1'b1;

            end

            else
            begin

                bit_cnt<=bit_cnt-1'b1;

            end

        end

    end

end

end


endmodule
//dq周电流
/////////////////////////////////////////////////////////////////////////////////////////////
