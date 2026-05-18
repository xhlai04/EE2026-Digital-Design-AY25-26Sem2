`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/10/2026 05:05:41 PM
// Design Name: 
// Module Name: slow_clock
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
  //    reg OUTPUT_CLOCK = 4'b0000

  always @(posedge CLOCK)
  begin
    if (COUNT == (n_cycles-1))
    begin
      COUNT <= 0;
      OUTPUT_CLOCK <= ~OUTPUT_CLOCK;
    end
    else
    begin
      COUNT <= COUNT + 1;
    end
  end

endmodule
