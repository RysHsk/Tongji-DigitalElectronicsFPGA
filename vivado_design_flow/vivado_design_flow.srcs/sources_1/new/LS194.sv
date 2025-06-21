`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 23 Microelectronics Science & Engineering
// Engineer: RysHsk
// 
// Create Date: 2025/06/04 00:43:21
// Design Name: 
// Module Name: LS194
// Project Name: 
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

module top_LS194(
    input  logic        rst,
    input  logic [ 7:0] sw_pin,
    input  logic [ 4:0] btn_pin,
    input  logic [ 7:0] dip_pin,
    output logic [15:0] led
);

    LS194 u_LS194(
        .clk_in     (btn_pin[0]),
        .clr_n      (rst),
        .ena        (dip_pin[0]),
        .s1         (sw_pin[7]),
        .s0         (sw_pin[6]),
        .d          (sw_pin[3:0]),
        .sr         (sw_pin[5]),
        .sl         (sw_pin[4]),
        .q          (led[11:8])
    );

    // unused led
    always_comb begin
        led[7:0] = 8'b0;
        led[15:12] = 4'b0;
    end

endmodule

module LS194(
    input  logic        clk_in,     // 时钟输入
    input  logic        clr_n,      // 异步复位（低电平有效）
    input  logic        ena,        // 使能
    input  logic        s1, s0,     // 控制信号
    input  logic [3:0]  d,          // 并行数据输入
    input  logic        sr,         // 串行右输入
    input  logic        sl,         // 串行左输入
    output logic [3:0]  q           // 输出数据
);

    always_ff @(posedge clk_in or negedge clr_n) begin
        if (!clr_n)
            q <= 4'b0000;
        else if (ena) begin
            case ({s1, s0})
                2'b00: q <= q;                         // 保持
                2'b01: q <= {sr, q[3:1]};              // 右移
                2'b10: q <= {q[2:0], sl};              // 左移
                2'b11: q <= d;                         // 并行加载
                default: q <= q;
            endcase
        end
    end

endmodule
