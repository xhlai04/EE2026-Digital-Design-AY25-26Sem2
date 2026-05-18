`timescale 1ns / 1ps

module updated_waveform_oled(
    input CLOCK_100MHZ,
    input [31:0] scale_x,
    input [11:0] y_val,
    output [7:0] JC
  );


  
  wire tick;
  sample_rate_gen tick_gen (
                    .clk(CLOCK_100MHZ),
                    .reset(1'b0),
                    .sample_tick(tick)
                  );

  localparam integer OLED_W = 96;
  localparam integer OLED_H = 64;

  localparam [15:0] ColorBlack = 16'h0000;
  localparam [15:0] ColorWhite = 16'hFFFF;

  wire clk625mhz;
  wire frame_begin;
  wire sending_pixels;
  wire sample_pixel;
  wire [12:0] pixel_index;
  wire [15:0] pixel_data;

  wire [6:0] x;
  wire [5:0] y;

  reg [5:0] buf_top [0:OLED_W-1];
  reg [5:0] buf_bot [0:OLED_W-1];
  reg [5:0]  prev_y       = 0;
  reg [6:0]  write_ptr    = 0;
  reg [31:0] sample_counter = 0;

  slow_clock clock_6_25mhz(
               .CLOCK(CLOCK_100MHZ),
               .n_cycles(8),
               .OUTPUT_CLOCK(clk625mhz)
             );

  Oled_Display oled_inst (
                 .clk(clk625mhz),
                 .reset(1'b0),
                 .frame_begin(frame_begin),
                 .sending_pixels(sending_pixels),
                 .sample_pixel(sample_pixel),
                 .pixel_index(pixel_index),
                 .pixel_data(pixel_data),
                 .cs(JC[0]),
                 .sdin(JC[1]),
                 .sclk(JC[3]),
                 .d_cn(JC[4]),
                 .resn(JC[5]),
                 .vccen(JC[6]),
                 .pmoden(JC[7])
               );

  assign x = pixel_index % OLED_W;
  assign y = pixel_index / OLED_W;

  // Map 12-bit (0-4095) to 6-bit (0-63), flip so high amplitude = top of screen
  wire [5:0] y_scaled  = y_val >> 6;             // 4095 >> 6 = 63
  wire [5:0] y_flipped = (OLED_H - 1) - y_scaled;

  always @(posedge CLOCK_100MHZ) begin
    if (tick) begin
        if (sample_counter >= scale_x - 1) begin
            buf_top[write_ptr] <= (y_flipped < prev_y) ? y_flipped : prev_y;
            buf_bot[write_ptr] <= (y_flipped > prev_y) ? y_flipped : prev_y;
            prev_y             <= y_flipped;
            write_ptr          <= (write_ptr == OLED_W - 1) ? 7'd0 : write_ptr + 1'b1;
            sample_counter     <= 32'd0;
        end else begin
            sample_counter <= sample_counter + 1'b1;
        end
    end
end

  assign pixel_data = (y >= buf_top[x] && y <= buf_bot[x]) ? ColorWhite : ColorBlack;

endmodule
