`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 07.04.2026 22:18:22
// Design Name:
// Module Name: default_black_oled_display
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


module default_black_oled_display(
    input CLOCK_100MHZ,
    output [7:0] JC
  );

  //MODULE THAT JUST OUTPUTS BLACK SCREEN
  wire clk625mhz;
  wire frame_begin;
  wire sending_pixels;
  wire sample_pixel;
  wire [12:0] pixel_index;
  wire [15:0] pixel_data;


  localparam [15:0] COLOR_BLACK    = 16'h0000;


  slow_clock clock_6_25mhz(
               .CLOCK(CLOCK_100MHZ),
               .n_cycles(8),
               .OUTPUT_CLOCK(clk625mhz)
             );
  Oled_Display oled_inst (
                 .clk(clk625mhz),
                 .reset(1'b0),
                 .frame_begin(frame_begin),
                 .sending_pixels(sending_pixels),
                 .sample_pixel(sample_pixel),
                 .pixel_index(pixel_index),
                 .pixel_data(pixel_data),
                 .cs(JC[0]),
                 .sdin(JC[1]),
                 .sclk(JC[3]),
                 .d_cn(JC[4]),
                 .resn(JC[5]),
                 .vccen(JC[6]),
                 .pmoden(JC[7])
               );

  assign pixel_data = COLOR_BLACK;

endmodule
