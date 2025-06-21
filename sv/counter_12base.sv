`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 23 Microelectronics Science & Engineering
// Engineer: RysHsk
// 
// Create Date: 2025/06/04 00:02:09
// Design Name: 
// Module Name: counter_12base
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


module counter_12base(
    input  logic        clk,
    input  logic        rst,
    input  logic [ 7:0] sw_pin,
    output logic [15:0] led
);

    logic clk_1Hz;
    logic [3:0] count;

    clk_1Hz u_clk_1Hz(
        .clk            (clk),
        .clk_1Hz_out    (clk_1Hz)
    );

    counter u_counter(
        .clk_1Hz        (clk_1Hz),
        .rst            (rst),
        .ena            (sw_pin[0]),
        .count          (count)
    );

    assign led[11:8] = count;

    // unused led
    always_comb begin
        led[7:0] = 8'b0;
        led[15:12] = 4'b0;
    end

endmodule


module counter(
    input  logic       clk_1Hz,
    input  logic       rst,
    input  logic       ena,
    output logic [3:0] count
);

    always_ff @(posedge clk_1Hz) begin
        if (!rst) begin
            count <= 4'd0;
        end else if (ena) begin
            if (count == 4'd11)
                count <= 4'd0;
            else
                count <= count + 1;
        end
    end

endmodule


module clk_1Hz(
    input  logic clk,
    output logic clk_1Hz_out
);

    logic [26:0] counter;

    always_ff @(posedge clk) begin
        if (counter == 27'd49_999_999) begin
            counter      <= 0;
            clk_1Hz_out  <= ~clk_1Hz_out;
        end else begin
            counter <= counter + 1;
        end
    end

endmodule
