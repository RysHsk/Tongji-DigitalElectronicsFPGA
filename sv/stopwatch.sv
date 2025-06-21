`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 23 Microelectronics Science & Engineering
// Engineer: RysHsk
// 
// Create Date: 2025/06/04 23:07:02
// Design Name: 
// Module Name: stopwatch
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


module stopwatch (
    input  logic        clk,      // 100 MHz clock
    input  logic        rst,      // low-active reset
    input  logic        start,    // start/resume timing
    input  logic        stop,     // pause timing
    input  logic        lap,
    output logic        running,
    output logic [3:0]  min_10,
    output logic [3:0]  min_1,
    output logic [3:0]  sec_10,
    output logic [3:0]  sec_1,
    output logic [3:0]  ms_10,
    output logic [3:0]  ms_1,
    output logic [23:0] save1, save2, save3, save4,
                        save5, save6, save7, save8,
    output logic [7:0]  save_cnt
);

    assign running = ~pausing;

    // 状态寄存器：是否计时中
    logic pausing = 1'b1;

    // 10ms计数器（从0到999_999）
    logic [19:0] cnt_10ms;

    // 主计时逻辑
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            cnt_10ms <= 20'd0;
            ms_1     <= 4'd0;
            ms_10    <= 4'd0;
            sec_1    <= 4'd0;
            sec_10   <= 4'd0;
            min_1    <= 4'd0;
            min_10   <= 4'd0;
            pausing  <= 1'b1;
        end else begin
            // 控制运行状态
            if (start)
                pausing <= 1'b0;
            else if (stop)
                pausing <= 1'b1;

            // 如果处于运行状态，进行计数
            if (!pausing) begin
                if (cnt_10ms == 20'd999_999) begin // 10ms（100MHz）
                    cnt_10ms <= 20'd0;

                    // 10ms位++
                    if (ms_1 == 4'd9) begin
                        ms_1 <= 4'd0;
                        if (ms_10 == 4'd9) begin
                            ms_10 <= 4'd0;

                            // 秒个位++
                            if (sec_1 == 4'd9) begin
                                sec_1 <= 4'd0;
                                if (sec_10 == 4'd5) begin
                                    sec_10 <= 4'd0;

                                    // 分钟个位++
                                    if (min_1 == 4'd9) begin
                                        min_1 <= 4'd0;
                                        if (min_10 == 4'd5)
                                            min_10 <= 4'd0;
                                        else
                                            min_10 <= min_10 + 1;
                                    end else begin
                                        min_1 <= min_1 + 1;
                                    end
                                end else begin
                                    sec_10 <= sec_10 + 1;
                                end
                            end else begin
                                sec_1 <= sec_1 + 1;
                            end
                        end else begin
                            ms_10 <= ms_10 + 1;
                        end
                    end else begin
                        ms_1 <= ms_1 + 1;
                    end
                end else begin
                    cnt_10ms <= cnt_10ms + 1;
                end
            end
        end
    end

    // 新增寄存器
    // logic [23:0] save1, save2, save3, save4, save5, save6, save7, save8;
    // logic [2:0]  save_cnt;       // 记录已保存次数，最大为7
    logic        lap_d; // 用于检测lap上升沿
    logic        lap_posedge;

    // 上升沿检测
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            lap_d <= 0;
        end else begin
            lap_d <= lap;
        end
    end

    assign lap_posedge = lap & ~lap_d;


    // lap记录逻辑
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            save1 <= 0; save2 <= 0; save3 <= 0; save4 <= 0;
            save5 <= 0; save6 <= 0; save7 <= 0; save8 <= 0;
            save_cnt <= 8'b0;
        end else if (lap_posedge) begin
            case (save_cnt)
                8'b0000_0000: begin
                    save1 <= {min_10, min_1, sec_10, sec_1, ms_10, ms_1};
                    save_cnt <= 8'b0000_0001;
                end
                8'b0000_0001: begin
                    save2 <= {min_10, min_1, sec_10, sec_1, ms_10, ms_1};
                    save_cnt <= 8'b0000_0011;
                end
                8'b0000_0011: begin
                    save3 <= {min_10, min_1, sec_10, sec_1, ms_10, ms_1};
                    save_cnt <= 8'b0000_0111;
                end
                8'b0000_0111: begin
                    save4 <= {min_10, min_1, sec_10, sec_1, ms_10, ms_1};
                    save_cnt <= 8'b0000_1111;
                end
                8'b0000_1111: begin
                    save5 <= {min_10, min_1, sec_10, sec_1, ms_10, ms_1};
                    save_cnt <= 8'b0001_1111;
                end
                8'b0001_1111: begin
                    save6 <= {min_10, min_1, sec_10, sec_1, ms_10, ms_1};
                    save_cnt <= 8'b0011_1111;
                end
                8'b0011_1111: begin
                    save7 <= {min_10, min_1, sec_10, sec_1, ms_10, ms_1};
                    save_cnt <= 8'b0111_1111;
                end
                8'b0111_1111: begin
                    save8 <= {min_10, min_1, sec_10, sec_1, ms_10, ms_1};
                    save_cnt <= 8'b1111_1111;
                end
                default: ; // 已满，不再记录
            endcase
        end
    end

endmodule
