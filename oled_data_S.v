`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2026 09:37:39 PM
// Design Name: 
// Module Name: oled_data_S
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


module oled_data_S(input[12:0] pixel_index, input btnL, btnR, CLK, output[15:0] oled_data_S);
    wire[15:0] number_one;
    wire[15:0] wall;
    wire[15:0] circle;
    
    S_number_1 fa0 (pixel_index, number_one);
    wall fa1 (pixel_index, wall);
    circle_animation fa2 (pixel_index, btnL, btnR, CLK, circle);
    
    assign oled_data_S = number_one | wall | circle;
endmodule
