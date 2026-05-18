`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/04/2026 02:28:19 PM
// Design Name: 
// Module Name: clk6p25m
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


module clk6p25m(input CLK, output reg clk6p25m = 0);
    reg [2:0] COUNT = 0;
    always @ (posedge CLK) begin
    if (COUNT >= 7) begin
        COUNT <= 0;
        clk6p25m <= ~ clk6p25m;
    end else begin
        COUNT <= COUNT + 1;
    end
    end
endmodule
