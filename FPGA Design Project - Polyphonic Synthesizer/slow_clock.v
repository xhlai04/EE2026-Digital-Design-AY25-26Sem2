`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11.02.2026 14:28:40
// Design Name:
// Module Name: slow_blinky_module
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


module slow_clock(
    input CLOCK,
    input [31:0] n_cycles,
    output reg OUTPUT_CLOCK = 0
  );
  reg [31:0] COUNT = 0;
  //    reg OUTPUT_CLOCK = 4'b0000;

  always @(posedge CLOCK)
  begin
    if (COUNT == (n_cycles-1))
    begin
      COUNT <= 0;
      OUTPUT_CLOCK <= 1;
    end
    else
    begin
      COUNT <= COUNT + 1;
      OUTPUT_CLOCK <=0;
      
    end
  end



endmodule
