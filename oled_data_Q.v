`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/10/2026 04:52:36 PM
// Design Name: 
// Module Name: oled_data_Q
// Project Name: 
// Target Devices: 
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


module oled_data_Q(input [12:0] pixel_index,
    input clk,              // 100 MHz
    input btnD,
    output [15:0] pixel_data
);
   wire [15:0] digit5_pixel;
   wire [15:0] digit1_pixel;
   wire [15:0] square_pixel;
   wire [15:0] square_colour;
   
   q_colour_cycle q1 (clk, btnD, square_colour);
   q_square q2 (pixel_index, square_colour, square_pixel);
   q_digit_5 q3 (pixel_index, digit5_pixel);
   q_digit_1 q4 (pixel_index, digit1_pixel);
   
   assign pixel_data =
       (digit5_pixel  != 16'h0000) ? digit5_pixel  :
       (digit1_pixel  != 16'h0000) ? digit1_pixel  :
       (square_pixel  != 16'h0000) ? square_pixel  :
                                     16'h0000;
endmodule


