`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: E-ELEMENTS
// Engineer: 
// 
// Create Date: 2025/06/04 23:33:03
// Design Name: 
// Module Name: smg_ip_model
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


module smg_ip_model(
    clk,
    data,
    sm_wei,
    sm_duan,
    sm_duan1,
    dots
); 
    input clk;
    input [31:0] data;
    output [7:0] sm_wei;
    output [7:0] sm_duan; 
    output [7:0] sm_duan1;
    input [7:0] dots;
//----------------------------------------------------------
//分频
    integer clk_cnt;
    reg clk_400Hz;
    always @(posedge clk)
        if(clk_cnt==32'd100000) begin 
            clk_cnt <= 1'b0; 
            clk_400Hz <= ~clk_400Hz;
        end else
            clk_cnt <= clk_cnt + 1'b1; 
//----------------------------------------------------------
//位控制
    reg [7:0]wei_ctrl=8'b1111_1110;
    always @(posedge clk_400Hz)
        wei_ctrl <= {wei_ctrl[6:0],wei_ctrl[7]};
//段控制
    reg [3:0]duan_ctrl;
    always @(wei_ctrl)
        case(wei_ctrl)
            8'b1111_1110:duan_ctrl=data[3:0];
            8'b1111_1101:duan_ctrl=data[7:4];
            8'b1111_1011:duan_ctrl=data[11:8];
            8'b1111_0111:duan_ctrl=data[15:12]; 
            8'b1110_1111:duan_ctrl=data[19:16];
            8'b1101_1111:duan_ctrl=data[23:20];
            8'b1011_1111:duan_ctrl=data[27:24];
            8'b0111_1111:duan_ctrl=data[31:28];
            default:duan_ctrl=4'hf;  
        endcase 
//---------------------------------------------------------- //解码模块
    reg [7:0]duan; 
    always @(duan_ctrl) 
        case(duan_ctrl) 
            4'h0:duan[6:0]=7'b011_1111;//0 
            4'h1:duan[6:0]=7'b000_0110;//1 
            4'h2:duan[6:0]=7'b101_1011;//2 
            4'h3:duan[6:0]=7'b100_1111;//3 
            4'h4:duan[6:0]=7'b110_0110;//4 
            4'h5:duan[6:0]=7'b110_1101;//5 
            4'h6:duan[6:0]=7'b111_1101;//6 
            4'h7:duan[6:0]=7'b000_0111;//7 
            4'h8:duan[6:0]=7'b111_1111;//8 
            4'h9:duan[6:0]=7'b110_1111;//9 
            4'ha:duan[6:0]=7'b111_0111;//a 
            4'hb:duan[6:0]=7'b111_1100;//b 
            4'hc:duan[6:0]=7'b011_1001;//c 
            4'hd:duan[6:0]=7'b101_1110;//d 
            4'he:duan[6:0]=7'b111_1000;//e 
            4'hf:duan[6:0]=7'b111_0001;//f 
            // 4'hf:duan=8'b1111_1111;//不显示
            default : duan[6:0] = 7'b011_1111;//0 
        endcase 
    
    always @(wei_ctrl)
        case(wei_ctrl)
            8'b1111_1110:duan[7]=dots[0];
            8'b1111_1101:duan[7]=dots[1];
            8'b1111_1011:duan[7]=dots[2];
            8'b1111_0111:duan[7]=dots[3];
            8'b1110_1111:duan[7]=dots[4];
            8'b1101_1111:duan[7]=dots[5];
            8'b1011_1111:duan[7]=dots[6];
            8'b0111_1111:duan[7]=dots[7];
            default:duan[7]=0;
        endcase 
//---------------------------------------------------------- 
    assign sm_wei =~wei_ctrl; 
    assign sm_duan = duan; 
    assign sm_duan1 = duan;
endmodule 
