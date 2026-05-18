`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/10/2026 06:06:54 PM
// Design Name: 
// Module Name: check_valid_five
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


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10.03.2026 17:56:45
// Design Name:
// Module Name: check_valid_five
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


module check_valid_five(
    input [31:0] offsetx,
    input [31:0] offsety,
    input [31:0] x, y,
    output reg check_valid_five
  );

  integer datax, datay; // integer is signed - needed so datax < 0 works correctly

  always @(offsetx, offsety, x, y)
  begin
    datax = x - offsetx;
    datay = y - offsety;
    if (datax < 0 || datax >= 96 || datay < 0 || datay >= 64)
    begin
      check_valid_five = 0;
    end
    // Top horizontal bar: full width (x=28-47), top 3 rows (y=17-19)
    else if (datax >= 39 && datax <= 57 && datay >= 17 && datay <= 20)
    begin
      check_valid_five = 1;
    end
    // Top-left vertical: left 4 columns (x=28-31), (y=20-31)
    else if (datax >= 39 && datax <= 42 && datay >= 21 && datay <= 29)
    begin
      check_valid_five = 1;
    end
    // Middle horizontal bar: full width (x=28-47), (y=32-34)
    else if (datax >= 39 && datax <= 57 && datay >= 30 && datay <= 33)
    begin
      check_valid_five = 1;
    end
    // Bottom-right vertical: RIGHT 4 columns (x=44-47), (y=35-43)
    else if (datax >= 54 && datax <= 57 && datay >= 34 && datay <= 42)
    begin
      check_valid_five = 1;
    end
    // Bottom horizontal bar: full width (x=28-47), (y=43-46)
    else if (datax >= 39 && datax <= 57 && datay >= 43 && datay <= 46)
    begin
      check_valid_five = 1;
    end
    else
    begin
      check_valid_five = 0;
    end
  end
endmodule


