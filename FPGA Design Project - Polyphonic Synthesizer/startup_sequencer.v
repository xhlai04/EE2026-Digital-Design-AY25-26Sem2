`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/01/2026 04:44:21 PM
// Design Name: 
// Module Name: startup_sequencer
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


module startup_sequencer(
    input clk, // 100 MHz
    input rst,
    input [15:0] leds_from_music,
    output [15:0] led_out,
    output is_booting //flag
    );
    
    reg [28:0] count = 0;
    reg booting = 1;
    wire blink_pattern; 
    
    always @ (posedge clk) begin
        if (rst) begin
            count <= 0;
            booting <= 1;
        end 
        else if (count < 300_000_000) begin
            count <= count + 1;
            booting <= 1;
        end
        else begin
            booting <= 0;
        end
    end
    
    //16'hAAAA = 16'b1010_1010_1010_1010
    //16'h5555 = 16'h0101_0101_0101_0101
    
    assign blink_pattern = count[24] ? 16'hAAAA: 16'h5555;
    
    assign led_out = (booting) ? blink_pattern : leds_from_music;
    assign is_booting  = booting;
    
endmodule
