`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 23 Microelectronics Science & Engineering
// Engineer: RysHsk
// 
// Create Date: 2025/06/04 23:06:36
// Design Name: 
// Module Name: top_timer
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


module top_timer(
    input  logic        clk,
    input  logic        rst,
    input  logic [ 4:0] btn_pin,
    input  logic [ 7:0] sw_pin,
    output logic [ 7:0] seg_cs_pin,
    output logic [ 7:0] seg_data_0_pin,
    output logic [ 7:0] seg_data_1_pin,
    output logic [15:0] led
    );

    logic clk_sw;
    logic rst_sw;
    logic start_sw;
    logic stop_sw;
    logic lap_sw;

    logic running_sw;
    logic [3:0]  min_10_sw;
    logic [3:0]  min_1_sw;
    logic [3:0]  sec_10_sw;
    logic [3:0]  sec_1_sw;
    logic [3:0]  ms_10_sw;
    logic [3:0]  ms_1_sw;

    logic clk_cd;
    logic rst_cd;
    logic start_cd;
    logic stop_cd;

    logic running_cd;
    logic zero_cd;
    logic [3:0]  min_10_cd;
    logic [3:0]  min_1_cd;
    logic [3:0]  sec_10_cd;
    logic [3:0]  sec_1_cd;
    logic [3:0]  ms_10_cd;
    logic [3:0]  ms_1_cd;

    logic clk_init;
    logic rst_init;
    logic sel_init;
    logic inc_init;
    logic dec_init;

    logic [3:0]  min_10_init;
    logic [3:0]  min_1_init;
    logic [3:0]  sec_10_init;
    logic [3:0]  sec_1_init;
    logic [3:0]  ms_10_init;
    logic [3:0]  ms_1_init;
    logic [5:0]  init_digit_sel;

    logic clk_rc;
    logic rst_rc;
    logic next_rc;
    logic [3:0]  recall_index;
    
    logic [31:0] seg_data;

    logic [23:0] save, save1, save2, save3, save4, save5, save6, save7, save8;
    logic [7:0] save_cnt;

    always_comb begin
        led = '0;
        clk_sw = clk;
        clk_cd = clk;
        clk_init = 0;
        clk_rc = 0;
        rst_sw = 1;
        rst_cd = 1;
        rst_init = 1;
        rst_rc = 1;
        start_sw = 0;
        start_cd = 0;
        stop_sw = 0;
        stop_cd = 0;
        sel_init = 1;
        inc_init = 1;
        dec_init = 1;
        next_rc = 0;

        lap_sw = 0; 

        case(sw_pin[7:6])
            2'b00: begin
                clk_sw = clk;
                rst_sw = rst;
                start_sw = btn_pin[2];
                stop_sw = btn_pin[0];
                lap_sw = btn_pin[4];
                led[8] = running_sw;
                led[9] = ~running_sw;
                led[7:0] = save_cnt[7:0];
                seg_data = {8'hA0,min_10_sw,min_1_sw,sec_10_sw,sec_1_sw,ms_10_sw,ms_1_sw};
            end
            2'b01: begin
                clk_rc = clk;
                rst_rc = rst;
                next_rc = btn_pin[1];
                led[7:0] = save_cnt[7:0];
                seg_data = {4'hB,recall_index,save};
            end
            2'b10: begin
                clk_cd = clk;
                rst_cd = rst;
                start_cd = btn_pin[2];
                stop_cd = btn_pin[0];
                led[8] = running_cd;
                led[9] = ~running_cd;
                seg_data = {8'hC0,min_10_cd,min_1_cd,sec_10_cd,sec_1_cd,ms_10_cd,ms_1_cd};
                led[10] = zero_cd;
            end
            2'b11: begin
                clk_init = clk;
                rst_init = rst;
                sel_init = btn_pin[3];
                inc_init = btn_pin[4];
                dec_init = btn_pin[1];
                seg_data = {8'hD0,min_10_init,min_1_init,sec_10_init,sec_1_init,ms_10_init,ms_1_init};
                led[8] = init_digit_sel[5];
                led[9] = init_digit_sel[4];
                led[10] = init_digit_sel[3];
                led[11] = init_digit_sel[2];
                led[12] = init_digit_sel[1];
                led[13] = init_digit_sel[0];
            end
            default: begin
                seg_data = '0;
                led = '0;
            end
        endcase
    end

    smg_ip_model u_smg(
        .clk            (clk),
        .data           (seg_data),
        .sm_wei         (seg_cs_pin),
        .sm_duan        (seg_data_0_pin),
        .sm_duan1       (seg_data_1_pin),
        .dots           (8'b01010100)
    );

    stopwatch u_stopwatch(
        .clk            (clk_sw),
        .rst            (rst_sw),
        .start          (start_sw),
        .stop           (stop_sw),
        .lap            (lap_sw),
        .running        (running_sw),
        .min_10         (min_10_sw),
        .min_1          (min_1_sw),
        .sec_10         (sec_10_sw),
        .sec_1          (sec_1_sw),
        .ms_10          (ms_10_sw),
        .ms_1           (ms_1_sw),
        .save1          (save1),
        .save2          (save2),
        .save3          (save3),
        .save4          (save4),
        .save5          (save5),
        .save6          (save6),
        .save7          (save7),
        .save8          (save8),
        .save_cnt       (save_cnt)
    );

    countdown u_countdown(
        .clk            (clk_cd),
        .rst            (rst_cd),
        .start          (start_cd),
        .stop           (stop_cd),
        .min_10_init    (min_10_init),
        .min_1_init     (min_1_init),
        .sec_10_init    (sec_10_init),
        .sec_1_init     (sec_1_init),
        .ms_10_init     (ms_10_init),
        .ms_1_init      (ms_1_init),
        .running        (running_cd),
        .min_10         (min_10_cd),
        .min_1          (min_1_cd),
        .sec_10         (sec_10_cd),
        .sec_1          (sec_1_cd),
        .ms_10          (ms_10_cd),
        .ms_1           (ms_1_cd),
        .zero           (zero_cd)
    );


    init_val_loader u_init(
        .clk            (clk_init),
        .rst            (rst_init),
        .sel            (sel_init),
        .inc            (inc_init),
        .dec            (dec_init),
        .min_10         (min_10_init),
        .min_1          (min_1_init),
        .sec_10         (sec_10_init),
        .sec_1          (sec_1_init),
        .ms_10          (ms_10_init),
        .ms_1           (ms_1_init),
        .digit_sel      (init_digit_sel)
    );

    recall u_recall(
        .clk            (clk_rc),
        .rst            (rst_rc),
        .next           (next_rc),
        .save1          (save1),
        .save2          (save2),
        .save3          (save3),
        .save4          (save4),
        .save5          (save5),
        .save6          (save6),
        .save7          (save7),
        .save8          (save8),
        .save           (save),
        .recall_index   (recall_index)
    );

endmodule
