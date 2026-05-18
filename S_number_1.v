`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/04/2026 11:05:56 PM
// Design Name: 
// Module Name: S_number_1
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


module S_number_1(input[12:0] pixel_index, output[15:0] oled_data_S);
    wire [12:0] x = pixel_index % 96; 
    wire [12:0] y = pixel_index / 96;
    
    assign oled_data_S = (x >=  8 && x <= 10 && y >= 24 && y <= 40)? 16'h07f2 : 16'h0000;
endmodule
