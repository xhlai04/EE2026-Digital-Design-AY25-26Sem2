`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.03.2026 12:43:58
// Design Name: 
// Module Name: sample_rate_gen
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


module my_sample_rate_gen(
    input CLOCK_100MHZ,
    input reset,
    input [31:0] PULSE_EVERY,
    output reg sample_tick
    );

    reg [31:0] COUNT = 0;
    
    always @(posedge CLOCK_100MHZ) begin
        if (reset)
        begin
            COUNT <= 0;
            sample_tick <= 0;
        end

        else if (COUNT == PULSE_EVERY-1) begin
            COUNT <= 0;
            sample_tick <= 1;
        end
        else begin
            COUNT <= COUNT +1;
            sample_tick <=0;
        end
    end
endmodule
