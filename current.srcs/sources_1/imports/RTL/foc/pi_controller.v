//--------------------------------------------------------------------------------------------------------
// 模块： pi_controller
// 功能： FOC电流环PI控制器
//
// 修改:
// 1. 标准离散PI积分:
//       I(k)=I(k-1)+Ki*error
//
// 2. 增加积分限幅，避免积分饱和
//
// 3. 输出:
//       out = Kp*error + Integral
//
//--------------------------------------------------------------------------------------------------------

module pi_controller (

    input  wire               rstn,
    input  wire               clk,
    input  wire               i_en,

    input  wire        [30:0] i_Kp,
    input  wire        [30:0] i_Ki,

    input  wire signed [15:0] i_aim,
    input  wire signed [15:0] i_real,

    output reg                o_en,

    output wire signed [15:0] o_value

);


//------------------------------------------------
// pipeline enable
//------------------------------------------------

reg en1;
reg en2;
reg en3;
reg en4;


//------------------------------------------------
// registers
//------------------------------------------------

reg signed [31:0] pdelta;       // error

reg signed [31:0] kpdelta1;
reg signed [31:0] kpdelta;

reg signed [31:0] idelta;       // integral

reg signed [31:0] kidelta;

reg signed [31:0] kpidelta;

reg signed [31:0] value;


reg [30:0] Kp0;
reg [30:0] Ki0;


//------------------------------------------------
// output Q16
//------------------------------------------------

assign o_value = value[31:16];



//================================================
// 加法保护
//================================================

function signed [31:0] protect_add;

    input signed [31:0] a;
    input signed [31:0] b;

    reg signed [32:0] y;

begin

    y = $signed({a[31],a})
      + $signed({b[31],b});


    if(y > 33'sh07fffffff)

        protect_add = 32'sh7fffffff;


    else if(y < -33'sh07fffffff)

        protect_add = -32'sh7fffffff;


    else

        protect_add = y[31:0];


end

endfunction



//================================================
// 乘法保护
//================================================

function signed [31:0] protect_mul;

    input signed [31:0] a;
    input signed [31:0] b;

    reg signed [63:0] y;


begin

    y = a*b;


    if(y > 64'sh000000007fffffff)

        protect_mul = 32'sh7fffffff;


    else if(y < -64'sh000000007fffffff)

        protect_mul = -32'sh7fffffff;


    else

        protect_mul = y[31:0];


end

endfunction



//================================================
// 积分限幅
//================================================

function signed [31:0] protect_integral;

    input signed [31:0] a;


begin


    // 积分最大限制
    // 根据电流环输出范围调整

    if(a > 32'sd1073741824)

        protect_integral = 32'sd1073741824;


    else if(a < -32'sd1073741824)

        protect_integral = -32'sd1073741824;


    else

        protect_integral = a;


end

endfunction





//================================================
// enable delay
//================================================

always @(posedge clk or negedge rstn)

begin

    if(!rstn)

    begin

        en1<=0;
        en2<=0;
        en3<=0;
        en4<=0;
        o_en<=0;

    end

    else

    begin

        en1<=i_en;
        en2<=en1;
        en3<=en2;
        en4<=en3;

        o_en<=en4;

    end

end





//================================================
// 输入采样
//================================================

always @(posedge clk or negedge rstn)

begin

    if(!rstn)

    begin

        Kp0<=0;
        Ki0<=0;
        pdelta<=0;

    end


    else if(i_en)

    begin

        Kp0<=i_Kp;
        Ki0<=i_Ki;


        // error = aim-real

        pdelta <=
        $signed({{16{i_aim[15]}},i_aim})
        -
        $signed({{16{i_real[15]}},i_real});


    end

end






//================================================
// P计算 + 积分计算
//================================================

always @(posedge clk or negedge rstn)

begin

    if(!rstn)

    begin

        kpdelta1<=0;
        idelta<=0;

    end


    else if(en1)

    begin


        //------------------------------------------------
        // P = Kp*error
        //------------------------------------------------

        kpdelta1 <= protect_mul(
                        pdelta,
                        $signed({1'b0,Kp0})
                    );



        //------------------------------------------------
        // I = I + Ki*error
        //------------------------------------------------

        idelta <= protect_integral
        (

            protect_add
            (

                idelta,

                protect_mul
                (
                    pdelta,
                    $signed({1'b0,Ki0})
                )

            )

        );


    end


end






//================================================
// 输出积分项
//================================================

always @(posedge clk or negedge rstn)

begin

    if(!rstn)

    begin

        kpdelta<=0;
        kidelta<=0;

    end


    else if(en2)

    begin

        kpdelta <= kpdelta1;


        // 积分输出

        kidelta <= idelta;


    end


end





//================================================
// PI求和
//================================================

always @(posedge clk or negedge rstn)

begin

    if(!rstn)

        kpidelta<=0;


    else if(en3)

        kpidelta <= protect_add(
                        kpdelta,
                        kidelta
                    );


end






//================================================
// 输出
//================================================

always @(posedge clk or negedge rstn)

begin

    if(!rstn)

        value<=0;


    else if(en4)

        value<=kpidelta;


end



endmodule