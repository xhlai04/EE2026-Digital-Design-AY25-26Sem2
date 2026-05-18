`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/10/2026 05:38:53 PM
// Design Name: 
// Module Name: segment_display
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


module segment_display(
    input clk,
    output reg [3:0] an,
    output reg [6:0] seg,
    output reg dp
);

    reg [16:0] refresh_counter = 0; //divides clk/2^17 = 763 then 4 digits so refresh at = 763/4 =  381 Hz
    wire [1:0] digit_sel;
    always @(posedge clk) begin
        refresh_counter <= refresh_counter + 1;
    end

    assign digit_sel = refresh_counter[16:15];  
    // adjust bits if refresh too fast/slow

    always @(digit_sel) begin
        case (digit_sel)
            2'b00: begin
                an = 4'b1110;   // AN0 on
                seg = 7'b0010010; // 5
                dp  = 1'b1;
            end
            2'b01: begin
                an = 4'b1101;   // AN1 on
                seg = 7'b1000000; // 0
                dp  = 1'b1;
            end
            2'b10: begin
                an = 4'b1011;   // AN2 on
                seg = 7'b0000010; // 6
                dp  = 1'b0;       // decimal point ON (active low)
            end
            2'b11: begin
                an = 4'b0111;   // AN3 on
                seg = 7'b0010010; // 5
                dp  = 1'b1;
            end
        endcase
    end
endmodule
