`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 23 Microelectronics Science & Engineering
// Engineer: RysHsk
// 
// Create Date: 2025/06/03 22:50:45
// Design Name: 
// Module Name: adder_2bit
// Project Name: Digital Electronics Experiments
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


module adder_2bit(
    input  logic [ 7:0] sw_pin,
    output logic [15:0] led
    );

    full_adder_2bit u_adder_2bit(
        .a          (sw_pin[3:2]),
        .b          (sw_pin[7:6]),
        .cin        (sw_pin[0]),
        .sum        (led[9:8]),
        .cout       (led[11])
    );

    // unused led
    always_comb begin
        led[7:0] = 8'b0;
        led[10] = 0;
        led[15:12] = 4'b0;
    end

endmodule

module full_adder_1bit (
    input  logic a,
    input  logic b,
    input  logic cin,
    output logic sum,
    output logic cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule

module full_adder_2bit (
    input  logic [1:0] a,
    input  logic [1:0] b,
    input  logic       cin,
    output logic [1:0] sum,
    output logic       cout
);
    logic c1;  // 第一位到第二位的进位

    // 第0位全加器
    full_adder_1bit fa0 (
        .a   (a[0]),
        .b   (b[0]),
        .cin (cin),
        .sum (sum[0]),
        .cout(c1)
    );

    // 第1位全加器
    full_adder_1bit fa1 (
        .a   (a[1]),
        .b   (b[1]),
        .cin (c1),
        .sum (sum[1]),
        .cout(cout)
    );
endmodule
