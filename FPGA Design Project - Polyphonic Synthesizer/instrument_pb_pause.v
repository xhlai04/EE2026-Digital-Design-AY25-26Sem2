`timescale 1ns / 1ps

module instrument_pb_pause_dis(
    input [6:0] pixel_x,      // 0-95
    input [5:0] pixel_y,      // 0-63
    input [10:0] read_ptr,    // Current playback position
    input [10:0] max_ptr,     // Total recorded length
    output reg [15:0] pixel_data
);

    // Color Definitions (RGB565)
    localparam WHITE  = 16'hFFFF;
    localparam GREY   = 16'h2104; 
    localparam BLACK  = 16'h0000;
    localparam GREEN  = 16'h07E0;

    // --- 1. Top Left: [2] + Play Symbol (Right Pointing) ---
    wire num_2 = (pixel_x >= 2 && pixel_x <= 5 && pixel_y >= 2 && pixel_y <= 8) &&
                 (pixel_y == 2 || pixel_y == 5 || pixel_y == 8 || (pixel_x == 5 && pixel_y <= 5) || (pixel_x == 2 && pixel_y >= 5));
    
        // ? play_icon: base at x=8, tip at x=14 - spread = (14 - pixel_x)
     wire play_icon = (pixel_x >= 8 && pixel_x <= 14) && 
                                  (pixel_y + (14 - pixel_x) >= 5) && 
                                  (pixel_y <= 5 + (14 - pixel_x));

    // --- 2. Top Right: [3] + Rewind Symbol (Left Pointing) ---
    wire num_3 = (pixel_x >= 65 && pixel_x <= 68 && pixel_y >= 2 && pixel_y <= 8) &&
                 (pixel_y == 2 || pixel_y == 5 || pixel_y == 8 || pixel_x == 68);
    
        // ? tri_1: tip at x=74, base at x=80 - spread = (pixel_x - 74)
        wire tri_1 = (pixel_x >= 74 && pixel_x <= 80) && 
                              (pixel_y + (pixel_x - 74) >= 5) && 
                              (pixel_y <= 5 + (pixel_x - 74));
        // ? tri_2: tip at x=82, base at x=88 - spread = (pixel_x - 82)
        wire tri_2 = (pixel_x >= 82 && pixel_x <= 88) && 
                                           (pixel_y + (pixel_x - 82) >= 5) && 
                                           (pixel_y <= 5 + (pixel_x - 82));

    // --- 3. Middle: Large Static Pause Symbol & "PAUSE" ---
    wire pause_bars = (pixel_y >= 25 && pixel_y <= 39) && 
                      ((pixel_x >= 15 && pixel_x <= 19) || (pixel_x >= 24 && pixel_x <= 28));

    // PAUSE Text
    wire char_P = (pixel_x >= 35 && pixel_x <= 40 && pixel_y >= 28 && pixel_y <= 36) &&
                  (pixel_x == 35 || pixel_y == 28 || pixel_y == 32 || (pixel_x == 40 && pixel_y <= 32));
    
    wire char_A = (pixel_x >= 43 && pixel_x <= 48 && pixel_y >= 28 && pixel_y <= 36) &&
                  (pixel_x == 43 || pixel_x == 48 || pixel_y == 28 || pixel_y == 32);
    
    wire char_U = (pixel_x >= 51 && pixel_x <= 56 && pixel_y >= 28 && pixel_y <= 36) &&
                  (pixel_x == 51 || pixel_x == 56 || pixel_y == 36);
    
    wire char_S = (pixel_x >= 59 && pixel_x <= 64 && pixel_y >= 28 && pixel_y <= 36) &&
                  (pixel_y == 28 || pixel_y == 32 || pixel_y == 36 || (pixel_x == 59 && pixel_y <= 32) || (pixel_x == 64 && pixel_y >= 32));
    
    wire char_E = (pixel_x >= 67 && pixel_x <= 72 && pixel_y >= 28 && pixel_y <= 36) &&
                  (pixel_x == 67 || pixel_y == 28 || pixel_y == 32 || pixel_y == 36);

    // --- 4. Bottom: Status Bar ---
    wire [31:0] prog_calc = (read_ptr * 96);
    wire [6:0] progress_width = (max_ptr > 0) ? (prog_calc / max_ptr) : 0;
    wire is_status_bg = (pixel_y >= 58 && pixel_y <= 62);
    wire is_progress  = is_status_bg && (pixel_x <= progress_width);

    // --- Final Pixel Mux ---
    always @(*) begin
        if (num_2 || play_icon || num_3 || tri_1 || tri_2 || pause_bars || 
            char_P || char_A || char_U || char_S || char_E)
            pixel_data = WHITE;
        else if (is_progress)
            pixel_data = GREEN;
        else if (is_status_bg)
            pixel_data = GREY;
        else
            pixel_data = BLACK;
    end

endmodule