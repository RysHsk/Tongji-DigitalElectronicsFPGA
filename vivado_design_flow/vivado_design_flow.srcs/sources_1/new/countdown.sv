`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 23 Microelectronics Science & Engineering
// Engineer: RysHsk
// 
// Create Date: 2025/06/05 16:36:23
// Design Name: 
// Module Name: countdown
// Project Name: timer
// Target Devices: EGo1
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


module countdown (
    input  logic        clk,      // 100 MHz clock
    input  logic        rst,      // low-active reset
    input  logic        start,    // start/resume countdown
    input  logic        stop,     // pause countdown
    input  logic [3:0]  min_10_init, // 倒计时初值：分钟十位
    input  logic [3:0]  min_1_init,  // 分钟个位
    input  logic [3:0]  sec_10_init, // 秒十位
    input  logic [3:0]  sec_1_init,  // 秒个位
    input  logic [3:0]  ms_10_init,  // 毫秒十位 (10ms单位)
    input  logic [3:0]  ms_1_init,   // 毫秒个位 (1ms单位)
    output logic        running,
    output logic [3:0]  min_10,
    output logic [3:0]  min_1,
    output logic [3:0]  sec_10,
    output logic [3:0]  sec_1,
    output logic [3:0]  ms_10,
    output logic [3:0]  ms_1,
    output logic        zero       // 全部归零输出1
);

    assign running = ~pausing;

    // 状态寄存器：是否计时中
    logic pausing = 1'b1;

    // 10ms计数器（从0到999_999，100MHz时钟10ms计数）
    logic [19:0] cnt_10ms;

    // 复位时将计时数初始化为输入值
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            cnt_10ms <= 20'd0;
            min_10   <= min_10_init;
            min_1    <= min_1_init;
            sec_10   <= sec_10_init;
            sec_1    <= sec_1_init;
            ms_10    <= ms_10_init;
            ms_1     <= ms_1_init;
            pausing  <= 1'b1;
        end else begin
            // start/stop 控制计时状态，倒计时结束自动暂停
            if (start)
                pausing <= 1'b0;
            else if (stop)
                pausing <= 1'b1;

            // 判断是否归零
            zero <= (min_10 == 0 && min_1 == 0 && sec_10 == 0 && sec_1 == 0 && ms_10 == 0 && ms_1 == 0);

            // 如果倒计时结束，自动暂停
            if (zero)
                pausing <= 1'b1;

            // 计时逻辑
            if (!pausing) begin
                if (cnt_10ms == 20'd999_999) begin // 10ms周期
                    cnt_10ms <= 20'd0;

                    // 递减最小位毫秒
                    if (ms_1 == 0) begin
                        ms_1 <= 4'd9;

                        if (ms_10 == 0) begin
                            ms_10 <= 4'd9;

                            // 秒个位递减
                            if (sec_1 == 0) begin
                                sec_1 <= 4'd9;

                                if (sec_10 == 0) begin
                                    sec_10 <= 4'd5;

                                    // 分钟个位递减
                                    if (min_1 == 0) begin
                                        min_1 <= 4'd9;

                                        if (min_10 == 0) begin
                                            // 全部归零，保持0
                                            min_10 <= 4'd0;
                                            min_1  <= 4'd0;
                                            sec_10 <= 4'd0;
                                            sec_1  <= 4'd0;
                                            ms_10  <= 4'd0;
                                            ms_1   <= 4'd0;
                                        end else begin
                                            min_10 <= min_10 - 1;
                                        end
                                    end else begin
                                        min_1 <= min_1 - 1;
                                    end
                                end else begin
                                    sec_10 <= sec_10 - 1;
                                end
                            end else begin
                                sec_1 <= sec_1 - 1;
                            end
                        end else begin
                            ms_10 <= ms_10 - 1;
                        end
                    end else begin
                        ms_1 <= ms_1 - 1;
                    end
                end else begin
                    cnt_10ms <= cnt_10ms + 1;
                end
            end
        end
    end

endmodule

