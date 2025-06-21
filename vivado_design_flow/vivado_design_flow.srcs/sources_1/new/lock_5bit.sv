`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 23 Microelectronics Science & Engineering
// Engineer: RysHsk
// 
// Create Date: 2025/06/03 23:33:09
// Design Name: 
// Module Name: lock_5bit
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


module lock_5bit(
    input  logic [ 7:0] sw_pin,
    output logic [15:0] led
    );

    lock u_lock(
        .ena        (sw_pin[7]),
        .pwd_in     (sw_pin[4:0]),
        .pwd_true   (led[8]),
        .pwd_false  (led[11])
    );

    // unused led
    always_comb begin
        led[7:0] = 8'b0;
        led[10:9] = 2'b0;
        led[15:12] = 4'b0;
    end

endmodule

module lock(
    input  logic        ena,
    input  logic [4:0]  pwd_in,
    output logic        pwd_true,
    output logic        pwd_false
);

    always_comb begin
        if(ena) begin
            case(pwd_in)
                5'b11001,
                5'b10111,
                5'b01010,
                5'b11100: begin
                    pwd_true = 1;
                    pwd_false = 0;
                end
                default: begin
                    pwd_true = 0;
                    pwd_false = 1;
                end
            endcase
        end else begin
            pwd_true = 0;
            pwd_false = 0;
        end
    end

endmodule
