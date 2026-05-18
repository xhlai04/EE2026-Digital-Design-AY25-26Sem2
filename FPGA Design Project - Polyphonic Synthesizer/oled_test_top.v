`timescale 1ns / 1ps

module oled_test_top(
    input CLOCK_100MHZ,
    input BTNR,
    output [7:0] JB
);

    // ======================================================
    // Clock for OLED (6.25 MHz)
    // ======================================================
    wire clk6p25m;
    slow_clock clk_div(.CLOCK(CLOCK_100MHZ), .n_cycles(8), .OUTPUT_CLOCK(clk6p25m));

    // ======================================================
    // Simple edge detection (no debounce)
    // ======================================================
    reg btnR_prev = 0;
    wire btnR_edge;

    assign btnR_edge = BTNR & ~btnR_prev;

    always @(posedge CLOCK_100MHZ) begin
        btnR_prev <= BTNR;
    end

    // ======================================================
    // Screen state (0 ? 3)
    // ======================================================
    reg [1:0] screen_state = 2'd0;

    always @(posedge CLOCK_100MHZ) begin
        if (btnR_edge) begin
            if (screen_state == 2'd3)
                screen_state <= 2'd0;
            else
                screen_state <= screen_state + 1'b1;
        end
    end

    // ======================================================
    // OLED wiring
    // ======================================================
    wire frame_begin;
    wire sending_pixels;
    wire sample_pixel;
    wire [12:0] pixel_index;
    wire [15:0] pixel_data;

    Oled_Display oled_inst(
        .clk(clk6p25m),
        .reset(1'b0),
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

    // ======================================================
    // Map to encouragement_state
    // ======================================================
    reg [1:0] encouragement_state;

    always @(*) begin
        case (screen_state)
            2'd0: encouragement_state = 2'd0; // NONE (title only)
            2'd1: encouragement_state = 2'd1; // TRY AGAIN
            2'd2: encouragement_state = 2'd2; // KEEP IT UP
            2'd3: encouragement_state = 2'd3; // ON FIRE
            default: encouragement_state = 2'd0;
        endcase
    end

    // ======================================================
    // Your bitmap-based screen
    // ======================================================
    game_play_jb_screen u_test_screen (
        .pixel_index(pixel_index),
        .encouragement_state(encouragement_state),
        .pixel_data(pixel_data)
    );

endmodule