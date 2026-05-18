`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/10/2026 04:55:28 PM
// Design Name: 
// Module Name: q_digit_5
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


module q_digit_5(
    input [12:0] pixel_index,
    output [15:0] pixel_data
);
    wire [6:0] x = pixel_index % 96;
    wire [6:0] y = pixel_index / 96;
    wire digit5_region;
    assign digit5_region =
        ((x >= 8  && x <= 23) && (y >= 44 && y <= 47)) ||   // top
        ((x >= 8  && x <= 11) && (y >= 44 && y <= 53)) ||   // upper left
        ((x >= 8  && x <= 23) && (y >= 52 && y <= 55)) ||   // middle
        ((x >= 20 && x <= 23) && (y >= 52 && y <= 63)) ||   // lower right
        ((x >= 8  && x <= 23) && (y >= 60 && y <= 63));     // bottom
    
    //RED
    assign pixel_data = digit5_region ? 16'hF800 : 16'h0000;
endmodule
