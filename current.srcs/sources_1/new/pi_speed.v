// =====================================================
// Verilog 速度环 PI 控制器（带输入使能信号）
// 输入:  speed_ref, speed_in (32位有符号)
// 输出:  ctrl_out (16位有符号，对应 Iq_ref)
// 控制:  en = 1 启动PI运算；en = 0 保持输出并停止积分
// 作者:  ChatGPT (GPT-5)
// =====================================================

module pi_speed #(
    parameter signed [31:0] KP = 32'sd500,      // 比例增益
    parameter signed [31:0] KI = 32'sd50,       // 积分增益
    parameter signed [15:0] MAX_OUT = 16'sd30000,  // 输出上限
    parameter signed [15:0] MIN_OUT = -16'sd30000  // 输出下限
)(
    input  wire              clk,
    input  wire              rst_n,
    input  wire              en,                // ✅ 使能信号
    input  wire signed [31:0] speed_ref,        // 目标速度
    input  wire signed [31:0] speed_in,         // 实际速度
    output reg  signed [15:0] ctrl_out          // 输出 Iq_ref
);

    // ------------------------
    // 内部寄存器
    // ------------------------
    reg signed [31:0] error;              // 速度误差
    reg signed [63:0] p_term;             // 比例项
    reg signed [63:0] i_accum;            // 积分项累加器
    reg signed [63:0] output_sum;         // 输出总和

    // ------------------------
    // 主逻辑
    // ------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            error      <= 32'sd0;
            p_term     <= 64'sd0;
            i_accum    <= 64'sd0;
            output_sum <= 64'sd0;
            ctrl_out   <= 16'sd0;
        end else if (en) begin
            // 当使能有效时执行PI控制
            error <= speed_ref - speed_in;

            // 比例项
            p_term <= error * KP;

            // 积分项累加
            i_accum <= i_accum + (error * KI);

            // PI总和
            output_sum <= p_term + i_accum;

            // 缩放：内部64位 → 输出16位
            ctrl_out <= $signed(output_sum >>> 16);

            // 饱和限制
            if (ctrl_out > MAX_OUT)
                ctrl_out <= MAX_OUT;
            else if (ctrl_out < MIN_OUT)
                ctrl_out <= MIN_OUT;

        end else begin
            // 使能无效时保持输出不变，不更新积分
            ctrl_out <= ctrl_out;
            i_accum  <= i_accum;
        end
    end

endmodule