`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10.03.2026 17:55:40
// Design Name:
// Module Name: check_valid_seven
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


module check_valid_seven(
    input [31:0] offsetx,
    input [31:0] offsety,
    input [31:0] x, y,
    output reg check_valid_seven
  );

  integer datax, datay; // integer is signed - needed so datax < 0 works correctly

  always @(offsetx, offsety, x, y)
  begin
    datax = x - offsetx;
    datay = y - offsety;

    if (datax < 0 || datax >= 96 || datay < 0 || datay >= 64)
    begin
      check_valid_seven = 0;
    end
    // Top horizontal bar: full width (x=0-15), top 3 rows (y=22-24)
    else if (datax >= 0 && datax <= 15 && datay >= 21 && datay <= 24)
    begin
      check_valid_seven = 1;
    end
    // Right vertical line: rightmost 4 columns (x=12-15), remaining rows (y=25-41)
    else if (datax >= 12 && datax <= 15 && datay >= 24 && datay <= 40)
    begin
      check_valid_seven = 1;
    end
    else
    begin
      check_valid_seven = 0;
    end
  end
endmodule
