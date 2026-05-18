`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2026 12:49:56 PM
// Design Name: 
// Module Name: circle_animation
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


module circle_animation(input[12:0] pixel_index, input btnL, btnR, input CLK, output reg[15:0] circle);
    wire[6:0] x = pixel_index % 96;
    wire[6:0] y = pixel_index / 96;
   
    reg[6:0] h = 38;
    reg[6:0] k = 30;
    
    wire[6:0] dx = (x > h)? (x - h): (h - x);
    wire[6:0] dy = (y > k)? (y - k): (k - y);
    
    reg is_moving_right = 0;
    reg is_moving_left = 0;
    reg move_tick = 0;
    
    reg[17:0] move_count = 0;
    
    always @ (posedge CLK) begin

        circle <= (dx*dx + dy*dy <= 100) ? 16'hF800 : 16'h0000 ;
        
        if (move_count == 125_000) begin
            move_count <= 0;
            move_tick <= 1;
        end else begin
            move_count <= move_count + 1;
            move_tick <= 0;
        end
        
        if (btnR) begin
            is_moving_right <= 1;
            is_moving_left <= 0;
        end
        
        if (btnL) begin
            is_moving_right <= 0;
            is_moving_left <= 1;
        end
        
        if (move_tick) begin
            if (is_moving_right) begin  
                if (h >= 85)
                     is_moving_right <= 0;
                else 
                    h <= h+1;
            end
            
            if (is_moving_left) begin
                if (h <= 32)
                    is_moving_left <= 0;
                else
                    h <= h - 1;
                end
            end
        end 
  
endmodule
