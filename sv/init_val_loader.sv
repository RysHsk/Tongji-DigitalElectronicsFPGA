`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 23 Microelectronics Science & Engineering
// Engineer: RysHsk
// 
// Create Date: 2025/06/05 17:05:12
// Design Name: 
// Module Name: init_val_loader
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


module init_val_loader (
    input  logic       clk,
    input  logic       rst,         // 低电平复位
    input  logic       sel,         // 选择位按钮（下降沿触发）
    input  logic       inc,         // 增加按钮（下降沿触发）
    input  logic       dec,         // 减少按钮（下降沿触发）
    output logic [5:0] digit_sel,   // one-hot 当前选择位
    output logic [3:0] min_10,
    output logic [3:0] min_1,
    output logic [3:0] sec_10,
    output logic [3:0] sec_1,
    output logic [3:0] ms_10,
    output logic [3:0] ms_1
);

    // === 按钮同步寄存器 ===
    logic sel_d, inc_d, dec_d;
    logic sel_sync, inc_sync, dec_sync;
    logic sel_edge, inc_edge, dec_edge;

    always_ff @(posedge clk) begin
        sel_d  <= sel;
        inc_d  <= inc;
        dec_d  <= dec;
        sel_sync <= sel_d;
        inc_sync <= inc_d;
        dec_sync <= dec_d;
    end

    // === 边沿检测（下降沿） ===
    assign sel_edge = (sel_sync == 1'b1 && sel_d == 1'b0);
    assign inc_edge = (inc_sync == 1'b1 && inc_d == 1'b0);
    assign dec_edge = (dec_sync == 1'b1 && dec_d == 1'b0);

    // === 当前选择位索引（0~5） ===
    logic [2:0] sel_index;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst)
            sel_index <= 3'd0;
        else if (sel_edge)
            sel_index <= (sel_index == 3'd5) ? 3'd0 : sel_index + 3'd1;
    end

    // === digit_sel 输出（one-hot 编码） ===
    always_comb begin
        digit_sel = 6'b000001 << sel_index;
    end

    // === 数码位控制 ===
    // 每个位的最大值（BCD 10进制）
    localparam MAX_MIN_10  = 4'd5;
    localparam MAX_MIN_1   = 4'd9;
    localparam MAX_SEC_10  = 4'd5;
    localparam MAX_SEC_1   = 4'd9;
    localparam MAX_MS_10   = 4'd9;
    localparam MAX_MS_1    = 4'd9;

    // 分钟十位
    always_ff @(posedge clk or negedge rst) begin
        if (!rst)
            min_10 <= 4'd0;
        else if (sel_index == 3'd0) begin
            if (inc_edge)
                min_10 <= (min_10 == MAX_MIN_10) ? 4'd0 : min_10 + 1;
            else if (dec_edge)
                min_10 <= (min_10 == 4'd0) ? MAX_MIN_10 : min_10 - 1;
        end
    end

    // 分钟个位
    always_ff @(posedge clk or negedge rst) begin
        if (!rst)
            min_1 <= 4'd0;
        else if (sel_index == 3'd1) begin
            if (inc_edge)
                min_1 <= (min_1 == MAX_MIN_1) ? 4'd0 : min_1 + 1;
            else if (dec_edge)
                min_1 <= (min_1 == 4'd0) ? MAX_MIN_1 : min_1 - 1;
        end
    end

    // 秒十位
    always_ff @(posedge clk or negedge rst) begin
        if (!rst)
            sec_10 <= 4'd0;
        else if (sel_index == 3'd2) begin
            if (inc_edge)
                sec_10 <= (sec_10 == MAX_SEC_10) ? 4'd0 : sec_10 + 1;
            else if (dec_edge)
                sec_10 <= (sec_10 == 4'd0) ? MAX_SEC_10 : sec_10 - 1;
        end
    end

    // 秒个位
    always_ff @(posedge clk or negedge rst) begin
        if (!rst)
            sec_1 <= 4'd0;
        else if (sel_index == 3'd3) begin
            if (inc_edge)
                sec_1 <= (sec_1 == MAX_SEC_1) ? 4'd0 : sec_1 + 1;
            else if (dec_edge)
                sec_1 <= (sec_1 == 4'd0) ? MAX_SEC_1 : sec_1 - 1;
        end
    end

    // 毫秒十位
    always_ff @(posedge clk or negedge rst) begin
        if (!rst)
            ms_10 <= 4'd0;
        else if (sel_index == 3'd4) begin
            if (inc_edge)
                ms_10 <= (ms_10 == MAX_MS_10) ? 4'd0 : ms_10 + 1;
            else if (dec_edge)
                ms_10 <= (ms_10 == 4'd0) ? MAX_MS_10 : ms_10 - 1;
        end
    end

    // 毫秒个位
    always_ff @(posedge clk or negedge rst) begin
        if (!rst)
            ms_1 <= 4'd0;
        else if (sel_index == 3'd5) begin
            if (inc_edge)
                ms_1 <= (ms_1 == MAX_MS_1) ? 4'd0 : ms_1 + 1;
            else if (dec_edge)
                ms_1 <= (ms_1 == 4'd0) ? MAX_MS_1 : ms_1 - 1;
        end
    end

endmodule
