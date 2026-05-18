`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/10/2026 04:54:03 PM
// Design Name: 
// Module Name: q_colour_cycle
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


module q_colour_cycle(
    input clk,
    input btnD,
    output [15:0] square_colour
);

    localparam GREEN  = 16'h07E0;
    localparam RED    = 16'hF800;
    localparam BLUE   = 16'h001F;
    localparam YELLOW = 16'hFFE0;

    reg [1:0] colour_state = 2'b00;

    // debounce
    reg [24:0] debounce_count = 0;
    reg btn_ready = 1;

    always @(posedge clk) begin
        // button pressed and ready -> button must have been released from previous press
        if (btnD && btn_ready) begin
            btn_ready <= 0;
            colour_state <= colour_state + 1;
            debounce_count <= 0;
        end
        // debounce timer
        if (!btn_ready) begin
            if (debounce_count < 25'd19_999_999)
                debounce_count <= debounce_count + 1;
            else if (!btnD)     // wait for release
                btn_ready <= 1;
        end
    end

    assign square_colour =
        colour_state[1] ?
            (colour_state[0] ? YELLOW : BLUE) :
            (colour_state[0] ? RED : GREEN);
endmodule

