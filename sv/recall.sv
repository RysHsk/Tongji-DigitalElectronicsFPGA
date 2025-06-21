`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 23 Microelectronics Science & Engineering
// Engineer: RysHsk
// 
// Create Date: 2025/06/06 02:25:38
// Design Name: 
// Module Name: recall
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


module recall (
    input  logic        clk,
    input  logic        rst,         // low-active reset
    input  logic        next,        // 按键高电平，触发逻辑处理
    input  logic [23:0] save1,
    input  logic [23:0] save2,
    input  logic [23:0] save3,
    input  logic [23:0] save4,
    input  logic [23:0] save5,
    input  logic [23:0] save6,
    input  logic [23:0] save7,
    input  logic [23:0] save8,
    output logic [23:0] save,
    output logic [3:0]  recall_index   // 当前回调编号（1-8）
);

    logic next_prev;
    logic armed;

    // 边沿检测
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            next_prev <= 1'b0;
        end else begin
            next_prev <= next;
        end
    end

    // armed: 上升沿置1，下降沿触发动作后清0
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            armed <= 1'b0;
        end else if (~next_prev & next) begin  // 上升沿
            armed <= 1'b1;
        end else if (next_prev & ~next && armed) begin  // 下降沿 + armed
            armed <= 1'b0;
        end
    end

    // index: 在 next 的下降沿 + armed 时增加（1~8 循环）
    logic [3:0] index;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            index <= 4'd1;
        end else if (next_prev & ~next && armed) begin  // 执行一次触发
            if (index == 4'd8)
                index <= 4'd1;
            else
                index <= index + 1;
        end
    end

    // 显示当前 index 对应的 save 值
    always_comb begin
        case (index)
            4'd1: save = save1;
            4'd2: save = save2;
            4'd3: save = save3;
            4'd4: save = save4;
            4'd5: save = save5;
            4'd6: save = save6;
            4'd7: save = save7;
            4'd8: save = save8;
            default: save = 24'd0;
        endcase
    end

    assign recall_index = index;

endmodule
