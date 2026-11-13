module hall_electric_angle (

    input  wire clk,
    input  wire rst_n,

    input  wire hall_h1,
    input  wire hall_h2,
    input  wire hall_h3,

    input  wire hall_enable,


    output reg [2:0] hall_state,


    output reg [31:0] prev_state_duration,

    output reg state_changed,

    output reg [31:0] state_change_cnt,


    output reg [11:0] sector_start_angle,

    output reg [11:0] elec_angle,


    output reg [31:0] speed_rpm,

    output reg [31:0] angular_vel,


    output reg [2:0] state_switch_cnt,


    output reg [31:0] mechanical_cycle_cnt,

    output reg [31:0] temp_cycle_cnt

);



parameter CLK_FREQ = 32'd14_400_000;

parameter POLE_PAIRS = 32'd4;


// 4096电角度

parameter FULL_ANGLE = 32'd4096;


// 一个霍尔区对应电角度
//
// 4096*4/6 = 2730

parameter ELEC_SECTOR_STEP =
        (32'd4096 * POLE_PAIRS)/6;



parameter PI_SCALE = 32'd3141593;




//====================================================
// 霍尔对应电角度
//
// POLE_PAIRS=4
//
// 101 -> 0
// 100 -> 2730
// 110 -> 1365
// 010 -> 0
// 011 -> 2730
// 001 -> 1365
//
//====================================================


parameter [11:0] SECTOR_ANGLE_101 = 12'd0;

parameter [11:0] SECTOR_ANGLE_100 = 12'd2730;

parameter [11:0] SECTOR_ANGLE_110 = 12'd1365;

parameter [11:0] SECTOR_ANGLE_010 = 12'd0;

parameter [11:0] SECTOR_ANGLE_011 = 12'd2730;

parameter [11:0] SECTOR_ANGLE_001 = 12'd1365;




//====================================================
// 内部变量
//====================================================


reg [2:0] hall_sync_1;

reg [2:0] hall_sync_2;


reg [2:0] prev_hall_state;


reg hall_initialized;


reg period_valid;


reg [11:0] decoded_sector_angle;


reg [31:0] interp_angle;

reg [31:0] angle_tmp;




wire hall_valid;



//====================================================
// 霍尔同步
//====================================================


always @(posedge clk or negedge rst_n)

begin

    if(!rst_n)

    begin

        hall_sync_1 <= 3'b000;

        hall_sync_2 <= 3'b000;

    end


    else if(hall_enable)

    begin

        hall_sync_1 <= {hall_h1,hall_h2,hall_h3};

        hall_sync_2 <= hall_sync_1;

    end

end




always @(*)

begin

    hall_state = hall_sync_2;

end




//====================================================
// 霍尔状态有效
//====================================================


assign hall_valid =

       (hall_state==3'b101)

    || (hall_state==3'b100)

    || (hall_state==3'b110)

    || (hall_state==3'b010)

    || (hall_state==3'b011)

    || (hall_state==3'b001);




//====================================================
// 霍尔状态查表
//====================================================


always @(*)

begin


    case(hall_state)


        3'b101:

            decoded_sector_angle =
            SECTOR_ANGLE_101;



        3'b100:

            decoded_sector_angle =
            SECTOR_ANGLE_100;



        3'b110:

            decoded_sector_angle =
            SECTOR_ANGLE_110;



        3'b010:

            decoded_sector_angle =
            SECTOR_ANGLE_010;



        3'b011:

            decoded_sector_angle =
            SECTOR_ANGLE_011;



        3'b001:

            decoded_sector_angle =
            SECTOR_ANGLE_001;



        default:

            decoded_sector_angle =
            sector_start_angle;


    endcase


end




//====================================================
// 霍尔变化检测
//====================================================


always @(posedge clk or negedge rst_n)

begin

    if(!rst_n)

    begin

        prev_hall_state <= 3'b000;

        hall_initialized <= 1'b0;

        state_changed <= 1'b0;

    end


    else

    begin


        state_changed <= 1'b0;



        if(hall_enable && hall_valid)

        begin


            if(!hall_initialized)

            begin

                prev_hall_state <= hall_state;

                hall_initialized <= 1'b1;

            end



            else if(hall_state != prev_hall_state)

            begin

                prev_hall_state <= hall_state;

                state_changed <= 1'b1;

            end


        end


    end


end




//====================================================
// 当前霍尔扇区角度
//====================================================


always @(posedge clk or negedge rst_n)

begin


    if(!rst_n)

        sector_start_angle <= 12'd0;



    else if(hall_enable && hall_valid)

        sector_start_angle <= decoded_sector_angle;


end
//====================================================
// 霍尔周期测量
//
// state_change_cnt:
// 当前霍尔状态持续时间
//
// prev_state_duration:
// 上一次霍尔区间时间
//
//====================================================


always @(posedge clk or negedge rst_n)

begin

    if(!rst_n)

    begin

        state_change_cnt <= 32'd0;

        prev_state_duration <= 32'd0;

        period_valid <= 1'b0;

    end


    else if(!hall_initialized)

    begin

        state_change_cnt <= 32'd0;

        period_valid <= 1'b0;

    end


    else

    begin


        if(state_changed)

        begin


            if(state_change_cnt != 0)

            begin

                prev_state_duration <= state_change_cnt;

                period_valid <= 1'b1;

            end


            state_change_cnt <= 32'd0;


        end


        else

        begin

            state_change_cnt <= state_change_cnt + 1'b1;

        end


    end


end




//====================================================
// 电角度计算
//
// 不使用固定中点角度
//
// 有速度:
//      扇区起始角 + 插值
//
// 无速度:
//      直接输出扇区起始角
//
//====================================================


always @(*)

begin


    if(!hall_initialized || !hall_valid)

    begin

        angle_tmp = 32'd0;

    end


    else

    begin


        if(period_valid && prev_state_duration != 0)

        begin


            // 电角度插值
            //
            // 一个霍尔区:
            // 2730电角度


            interp_angle =

            (ELEC_SECTOR_STEP * state_change_cnt)

            /

            prev_state_duration;



            if(interp_angle > ELEC_SECTOR_STEP)

                interp_angle = ELEC_SECTOR_STEP;



            angle_tmp =

            sector_start_angle + interp_angle;


        end


        else

        begin


            // 第一次运行
            // 不使用+341
            //
            // 直接使用霍尔确定角度

            angle_tmp =

            sector_start_angle;


        end


    end



    // 4096取模

    if(angle_tmp >= FULL_ANGLE)

        angle_tmp = angle_tmp - FULL_ANGLE;


end





//====================================================
// 输出电角度
//
// 保留原逻辑:
// 无效时输出0
//
//====================================================


always @(posedge clk or negedge rst_n)

begin


    if(!rst_n)

    begin

        elec_angle <= 12'd0;

    end


    else if(hall_enable && hall_valid)

    begin

        elec_angle <= angle_tmp[11:0];

    end


    else

    begin

        elec_angle <= 12'd0;

    end


end





//====================================================
// 速度计算
//
// 六个霍尔状态:
// 一个机械周期
//
// 机械转速:
//
// RPM = 60*f_clk
//       ----------------
//       T_hall*6*pole_pairs
//
//====================================================


always @(posedge clk or negedge rst_n)

begin


    if(!rst_n)

    begin

        speed_rpm <= 32'd0;

        angular_vel <= 32'd0;

    end


    else

    begin



        if(hall_enable &&
           prev_state_duration != 0)

        begin



            speed_rpm <=

            (60 * CLK_FREQ)

            /

            (prev_state_duration *
             6 *
             POLE_PAIRS);



            // rad/s

            angular_vel <=

            (PI_SCALE * speed_rpm)

            /

            30000;



        end


        else

        begin

            speed_rpm <= 32'd0;

            angular_vel <= 32'd0;


        end


    end


end





//====================================================
// 霍尔周期计数
//
// 6次状态变化 = 一机械周期
//
//====================================================


always @(posedge clk or negedge rst_n)

begin


    if(!rst_n)

    begin

        state_switch_cnt <= 3'd0;

        temp_cycle_cnt <= 32'd0;

        mechanical_cycle_cnt <= 32'd0;

    end



    else if(state_changed)

    begin



        if(state_switch_cnt == 3'd5)

        begin


            mechanical_cycle_cnt <=

            temp_cycle_cnt + state_change_cnt;



            temp_cycle_cnt <= 32'd0;


            state_switch_cnt <= 3'd0;



        end


        else

        begin


            temp_cycle_cnt <=

            temp_cycle_cnt + state_change_cnt;



            state_switch_cnt <=

            state_switch_cnt + 1'b1;



        end



    end



end



endmodule