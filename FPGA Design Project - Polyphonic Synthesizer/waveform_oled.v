`timescale 1ns / 1ps
module waveform_oled(
    input CLOCK_100MHZ,
    input sample_tick,
    input [31:0] scale_x,
    input [31:0] envelope_level,
    input [11:0] y_val,
    output [7:0] JC
);

    localparam integer OLED_W     = 96;
    localparam integer OLED_H     = 64;

    localparam [15:0] ColorBlack  = 16'h0000;
    localparam [15:0] ColorWhite   = 16'hFFFF;

    wire clk625mhz;
    wire frame_begin;
    wire sending_pixels;
    wire sample_pixel;
    wire [12:0] pixel_index;
    reg  reset = 0;
    wire [15:0] pixel_data;

    wire [6:0] x;
    wire [5:0] y;

    //reg [5:0] buffer [0:OLED_W-1];  // one y value per column
    // Store top and bottom of each column for vertical fill
    reg [5:0] buf_top [0:OLED_W-1];  // upper y of the vertical segment
    reg [5:0] buf_bot [0:OLED_W-1];  // lower y of the vertical segment
    reg [5:0]  prev_y        = 0;    // previous column's y value

    reg [6:0] write_ptr     = 0;    // which column to write next (0-95)
    reg [31:0] sample_counter = 0;  // counts samples between writes

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
    wire [31:0] divisor;
    // Compress 12-bit (0-4095) into 6-bit (0-63), flip so high = top of screen
    //simpler solution was to simply shift right
    //wire [5:0] y_scaled  = y_val >> scale_y;
    
    assign divisor = 64 + ((4095 - envelope_level) * 32'd4032) / 32'd4095;

    wire [5:0] y_scaled = (divisor == 0) ? 6'd63 : (y_val / divisor);
    wire [5:0] y_flipped = (OLED_H - 1) - y_scaled;

    always @(posedge sample_tick) begin
            if (sample_counter >= scale_x - 1) begin
                // Store vertical segment: top = min(prev, curr), bot = max(prev, curr)
                buf_top[write_ptr] <= (y_flipped < prev_y) ? y_flipped : prev_y;
                buf_bot[write_ptr] <= (y_flipped > prev_y) ? y_flipped : prev_y;

                prev_y     <= y_flipped;
                write_ptr  <= (write_ptr == OLED_W - 1) ? 7'd0 : write_ptr + 1'b1;
                sample_counter <= 32'd0;

            end else begin
                sample_counter <= sample_counter + 1'b1;
            end
        end
    

    // For each pixel, light it up if its y matches the buffer value for that column
    assign pixel_data = (y >= buf_top[x] && y <= buf_bot[x]) ? ColorWhite : ColorBlack;

endmodule