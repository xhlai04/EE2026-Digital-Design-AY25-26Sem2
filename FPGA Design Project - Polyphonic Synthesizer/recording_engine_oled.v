`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/26/2026 06:22:46 PM
// Design Name: 
// Module Name: recording_engine_oled
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


module recording_engine_oled(
    input CLOCK_100MHZ,
    input[4:0]  fsm_state, 
    input[10:0] read_ptr,
    input[10:0] write_ptr, //from recording_engine
    input[10:0] max_read_ptr, //captured_write_ptr
    input buffer_full, 
    output[7:0] JB //oled
    );
    
    wire clk625mhz;
    wire frame_begin;
    wire sending_pixels;
    wire sample_pixel;
    wire [12:0] pixel_index;
    reg  reset = 0;
    reg [15:0] pixel_data;
    
    wire [6:0] x;
    wire [5:0] y;
    
    localparam GREEN = 16'h07e0;
    localparam RED   = 16'hf800;
    localparam BLACK = 16'h0000;
    localparam WHITE = 16'hffff;
    localparam GRAY = 16'h7bcf ;
    localparam BLUE = 16'h001f;
    
    assign x = pixel_index % 96;
    assign y = pixel_index / 96;
    
   slow_clock clock_6_25mhz(
                 .CLOCK(CLOCK_100MHZ),
                 .n_cycles(8),
                 .OUTPUT_CLOCK(clk625mhz)
               );
               
    Oled_Display oled_inst (
                                .clk(clk625mhz),
                                .reset(reset),
                                .frame_begin(frame_begin),
                                .sending_pixels(sending_pixels),
                                .sample_pixel(sample_pixel),
                                .pixel_index(pixel_index),
                                .pixel_data(pixel_data),
                                .cs(JB[0]),
                                .sdin(JB[1]),
                                .sclk(JB[3]),
                                .d_cn(JB[4]),
                                .resn(JB[5]),
                                .vccen(JB[6]),
                                .pmoden(JB[7])
                              );  
                              
       //calculate bar width according to write_ptr
       wire[6:0] record_bar_width = (write_ptr * 96) >> 11; //divide by 2048     
       wire[6:0] play_back_bar_width = (max_read_ptr > 0)? ((read_ptr*96)/max_read_ptr) : 0;      
       
        always @ (*) begin
                   pixel_data = BLACK;
                    
                   // 1. Center Icons (Record / Play / Pause)
                   if (sw[0]) begin
                       if (x >= 38 && x <= 58 && y >= 22 && y <= 42) 
                           pixel_data = RED;
                   end
                   else if (sw[1]) begin
                       if (x >= 35 && x <= 60) begin
                           if (y >= (15 + ((x-35)*17/25)) && y <= (49 - ((x-35)*17/25)))
                               pixel_data = GREEN;
                       end
                   end
                   else if (max_read_ptr > 0) begin
                       if (y >= 22 && y <= 42) begin
                           if ((x >= 40 && x <= 44) || (x >= 52 && x <= 56)) 
                               pixel_data = WHITE;
                       end
                   end
                   
                   // 2. Dynamic Progress Bar
                   if (y >= 55 && y <= 60) begin
                       if (sw[0]) begin
                           // Recording Mode
                           if (x < record_bar_width) 
                               pixel_data = (buffer_full) ? RED : GREEN;
                           else 
                               pixel_data = GRAY;
                       end 
                       else begin
                           // Playback or Pause Mode
                           if (x < play_back_bar_width) 
                               pixel_data = BLUE;
                           else if (x < record_bar_width) 
                               pixel_data = GRAY;
                       end
                   end
                   
                   // 3. Buffer Full Border
                   if (buffer_full && (y < 2 || y > 61 || x < 2 || x > 93)) begin
                       pixel_data = RED;
                   end
              end
            
      
endmodule
