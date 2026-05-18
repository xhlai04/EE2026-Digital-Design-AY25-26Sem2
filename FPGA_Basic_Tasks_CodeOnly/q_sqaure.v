`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/10/2026 04:54:47 PM
// Design Name: 
// Module Name: q_sqaure
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

module q_square(
    input [12:0] pixel_index,
    input [15:0] square_colour,
    output [15:0] pixel_data
);
    wire [6:0] x = pixel_index % 96;
    wire [6:0] y = pixel_index / 96;
    assign pixel_data =
        (x >= 38 && x <= 57 && y >= 44 && y <= 63) ? square_colour : 16'h0000;
endmodule
