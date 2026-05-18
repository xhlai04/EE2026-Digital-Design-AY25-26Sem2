`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/04/2026 11:25:18 PM
// Design Name: 
// Module Name: wall
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


module wall(input[12:0]pixel_index, output[15:0] oled_data_S);
    wire [12:0] x;
    wire [12:0] y;
    assign x = pixel_index % 96;
    assign y = pixel_index / 96;
 
    assign oled_data_S = (x >= 17 && x <= 21 && y>= 7 && y<=56 )? 16'hFFFF: 16'h0000; 
endmodule

