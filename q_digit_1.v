`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/10/2026 04:56:02 PM
// Design Name: 
// Module Name: q_digit_1
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


module q_digit_1(
    input [12:0] pixel_index,
    output [15:0] pixel_data
);
    wire [6:0] x = pixel_index % 96;
    wire [6:0] y = pixel_index / 96;
    wire digit1_region;
    assign digit1_region =
        (x >= 80 && x <= 83) && (y >= 44 && y <= 63);   

    // BLUE
    assign pixel_data = digit1_region ? 16'h001F : 16'h0000;

endmodule

