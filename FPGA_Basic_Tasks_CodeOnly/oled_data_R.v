`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 03/10/2026 04:59:01 PM
// Design Name:
// Module Name: oled_data_R
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


module oled_data_R(input [12:0] pixel_index,
                     input[15:0] sw,
                     input clk6p25m,
                     input clk ,
                     input sample_pixel,

                     output reg [15:0]  oled_data_R);


  wire clk32;

  reg [15:0] green_data = 16'h07E0;
  reg [15:0] blue_data = 16'h001F;
  reg [15:0] black_data = 16'h0000;
  reg [15:0] orange_data = 16'hFD40;

  //reg [15:0] red_data = 16'hF800;
  reg [31:0] x;
  reg [31:0] y;
  reg [31:0] offsety = 0;
  reg [31:0] offsetx = 0;
  reg direction = 1;

  wire is_seven_valid;
  wire is_five_valid;

  check_valid_seven u_seven (.offsetx(offsetx), .offsety(offsety), .x(x), .y(y), .check_valid_seven(is_seven_valid));
  check_valid_five u_five (.offsetx(0), .offsety(0), .x(x), .y(y), .check_valid_five(is_five_valid));
  slow_clock u32 (clk, 1851000, clk32);       // 100MHz / (2*1851851) = 27Hz -> 1 pixel/tick -> 96-15 = 81 pixels in 3s means i need 27 hz


  // Update offsetx at 32Hz: moves 1 pixel per tick -> 96 pixels in 3 seconds
  // '7' is 16px wide, '5' ends at offsetx+47, so limit offsetx to 48 (offsetx+47 = 95)
  always @(posedge clk32)
  begin
    if (~sw[1])

      if (direction)
      begin
        if (offsetx >= 80)
          direction <= 0;
        else
          offsetx <= offsetx + 1;
      end
      else
      begin
        if (offsetx == 0)
          direction <= 1;
        else
          offsetx <= offsetx - 1;
      end

  end

  // Draw pixels: must use CLOCK domain so sample_pixel pulses are never missed
  always @(posedge clk)
  begin
    x <= pixel_index % 96;
    y <= pixel_index / 96;

    if (sample_pixel)
    begin
      oled_data_R <= black_data;
      if (is_seven_valid)
        oled_data_R <= blue_data;

      if (is_five_valid)
        oled_data_R <= orange_data;
    end
  end


endmodule