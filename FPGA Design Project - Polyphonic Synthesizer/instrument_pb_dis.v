`timescale 1ns / 1ps

module instrument_pb_dis(
    input clk,                // 100MHz System Clock
    input [6:0] pixel_x,      // 0-95
    input [5:0] pixel_y,      // 0-63
    input [10:0] read_ptr,    // Current playback pointer
    input [10:0] max_ptr,     // The captured_write_ptr (end of recording)
    output reg [15:0] pixel_data
);

    // Color Definitions (RGB565)
    localparam GREEN  = 16'h07E0;
    localparam WHITE  = 16'hFFFF;
    localparam GREY   = 16'h2104; 
    localparam BLACK  = 16'h0000;

    // --- Internal Blinking Clock ---
    reg [25:0] blink_counter = 0;
    always @(posedge clk) blink_counter <= blink_counter + 1;
    wire blink_sig = blink_counter[24]; 

    // --- 1. Top Left: [2] + Pause Symbol ---
    wire num_2 = (pixel_x >= 2 && pixel_x <= 5 && pixel_y >= 2 && pixel_y <= 8) &&
                 (pixel_y == 2 || pixel_y == 5 || pixel_y == 8 || (pixel_x == 5 && pixel_y <= 5) || (pixel_x == 2 && pixel_y >= 5));
    
    wire pause_sym = (pixel_y >= 2 && pixel_y <= 8) && 
                     ((pixel_x >= 8 && pixel_x <= 9) || (pixel_x >= 12 && pixel_x <= 13));

    // --- 2. Top Right: [3] + Forward Symbol (>>) ---
    wire num_3 = (pixel_x >= 65 && pixel_x <= 68 && pixel_y >= 2 && pixel_y <= 8) &&
                 (pixel_y == 2 || pixel_y == 5 || pixel_y == 8 || pixel_x == 68);
    
    // Triangle 1: Base at x=74 (y=5±6), Tip at x=80
     wire tri_1 = (pixel_x >= 74 && pixel_x <= 80) && 
                              (pixel_y + (80 - pixel_x) >= 5) && 
                              (pixel_y <= 5 + (80 - pixel_x));
                 
     // Triangle 2: Base at x=82 (y=5±6), Tip at x=88
      wire tri_2 = (pixel_x >= 82 && pixel_x <= 88) && 
                              (pixel_y + (88 - pixel_x) >= 5) && 
                              (pixel_y <= 5 + (88 - pixel_x));

    // Center play triangle: Base at x=20 (y=32±10), Tip at x=30
    wire play_tri = (pixel_x >= 20 && pixel_x <= 30) && 
                (pixel_y + (30 - pixel_x) >= 32) && 
                (pixel_y <= 32 + (30 - pixel_x)) && blink_sig;

    // "PLAY" Text
    wire char_P = (pixel_x >= 40 && pixel_x <= 45 && pixel_y >= 28 && pixel_y <= 36) &&
                  (pixel_x == 40 || pixel_y == 28 || pixel_y == 32 || (pixel_x == 45 && pixel_y <= 32));
    wire char_L = (pixel_x >= 48 && pixel_x <= 53 && pixel_y >= 28 && pixel_y <= 36) &&
                  (pixel_x == 48 || pixel_y == 36);
    wire char_A = (pixel_x >= 56 && pixel_x <= 61 && pixel_y >= 28 && pixel_y <= 36) &&
                  (pixel_x == 56 || pixel_x == 61 || pixel_y == 28 || pixel_y == 32);
    wire char_Y = (pixel_x >= 64 && pixel_x <= 69 && pixel_y >= 28 && pixel_y <= 36) &&
                  ((pixel_y <= 32 && (pixel_x == 64 || pixel_x == 69)) || (pixel_y >= 32 && pixel_x == 66));

    // --- 4. Bottom: Status Bar ---
    wire [31:0] prog_calc = (read_ptr * 96);
    wire [6:0] progress_width = (max_ptr > 0) ? (prog_calc / max_ptr) : 0;
    wire is_status_bg = (pixel_y >= 58 && pixel_y <= 62);
    wire is_progress  = is_status_bg && (pixel_x <= progress_width);

    // --- Final Pixel Mux ---
    always @(*) begin
        if (num_2 || num_3 || pause_sym || tri_1 || tri_2 || char_P || char_L || char_A || char_Y)
            pixel_data = WHITE;
        else if (play_tri)
            pixel_data = GREEN;
        else if (is_progress)
            pixel_data = GREEN;
        else if (is_status_bg)
            pixel_data = GREY;
        else
            pixel_data = BLACK;
    end

endmodule