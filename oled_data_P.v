`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/10/2026 04:23:21 PM
// Design Name: 
// Module Name: oled_data_P
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


module oled_data_P(input[12:0] pixel_index, input btnu, clk6p25m, clk100m, output[15:0] oled_data_P);
    wire [6:0] x; // 0 to 95
    wire [5:0] y; // 0 to 63
    
    assign x = pixel_index % 96;
    assign y = pixel_index / 96;
    
    wire press; 
    reg showing = 1'b1; // toggle based on button pressed or not

 always @(posedge clk100m) begin //6p25mHz clock
        if (press) begin
            showing <= ~showing;
        end
    end

        //drawing time
    wire circle, four, five;
    wire [15:0] oled_data;
    
        //circle fomula
    assign circle = ((x-7)*(x-7) + (y-7)*(y-7) <= 36);
            
                // shows 4, red, left side
                // x[18 to 43] so width 26, y[10 to 55] so height 46,  thickness 7 
    assign four = ((x >= 37 && x <= 43) && (y >= 10 && y <= 55)) || // right vert
                      ((x >= 18 && x <= 24) && (y >= 10 && y <= 32)) || // left vert
                      ((y >= 26 && y <= 32) && (x >= 18 && x <= 43));   // middle hori
            
                // shows 5, green , right side 
                // x[60 to 85] so width 26 , y[10 to 55] so height 46, thickness 7 
     assign five = ((y >= 10 && y <= 16) && (x >= 60 && x <= 85)) || // top hori
                      ((y >= 29 && y <= 35) && (x >= 60 && x <= 85)) || // middle hori
                      ((y >= 49 && y <= 55) && (x >= 60 && x <= 85)) || // bottom hori
                      ((x >= 60 && x <= 66) && (y >= 10 && y <= 35)) || // left vert
                      ((x >= 79 && x <= 85) && (y >= 29 && y <= 55));   // right vert

     assign oled_data_P = (!showing) ? 16'h0000 : // black when off
                           (circle)      ? 16'hFFFF : // white circle
                           (four)        ? 16'hF800 : // red 4
                           (five)        ? 16'h07E0 : // green 5
                                           16'h0000;  // default black
    
      // instatiate debouncer module (at bottom of this file)
    debouncer mustt (
          .clock(clk100m),
          .raw_press(btnu),
          .crisp_press(press)
      );


endmodule
