`timescale 1ns / 1ps

module instrument_pb_done_dis(
    input [6:0] pixel_x,      // 0-95
    input [5:0] pixel_y,      // 0-63
    input [10:0] max_ptr,     // The total length of the recording
    output reg [15:0] pixel_data
);

    // Color Definitions (RGB565)
    localparam GREEN  = 16'h07E0;
    localparam WHITE  = 16'hFFFF;
    localparam GREY   = 16'h2104; 
    localparam BLACK  = 16'h0000;
    localparam RED    = 16'hF800;

    // --- 1. Top Left: [1] + Recording Symbol (Circle) ---
    wire num_1 = (pixel_x >= 2 && pixel_x <= 4 && pixel_y >= 2 && pixel_y <= 8) && (pixel_x == 3);
    
    // Solid Recording Circle icon
    wire [15:0] top_dist_sq = (pixel_x - 10)*(pixel_x - 10) + (pixel_y - 5)*(pixel_y - 5);
    wire rec_icon = (top_dist_sq < 12);

    // --- 2. Middle: Green Tick & "DONE" ---
    // Green Tick Logic (Solid)
    // Part 1: Downward stroke from (22, 32) to (27, 37)
    wire tick_part1 = (pixel_x >= 22 && pixel_x <= 27) && 
                      (pixel_y >= pixel_x + 10) && (pixel_y <= pixel_x + 12);
    // Part 2: Upward stroke from (27, 37) to (37, 25)
    wire tick_part2 = (pixel_x >= 27 && pixel_x <= 37) && 
                      (pixel_y >= 64 - pixel_x) && (pixel_y <= 66 - pixel_x);
    wire is_tick = (tick_part1 || tick_part2);

    // "DONE" Text
    // D: Left bar and curved-style box
    wire char_D = (pixel_x >= 45 && pixel_x <= 50 && pixel_y >= 28 && pixel_y <= 36) &&
                  (pixel_x == 45 || (pixel_x == 50 && pixel_y > 28 && pixel_y < 36) || pixel_y == 28 || pixel_y == 36);
    // O: Full box
    wire char_O = (pixel_x >= 54 && pixel_x <= 59 && pixel_y >= 28 && pixel_y <= 36) &&
                  (pixel_x == 54 || pixel_x == 59 || pixel_y == 28 || pixel_y == 36);
    // N: Left bar, right bar, and calculated diagonal
    wire char_N = (pixel_x >= 63 && pixel_x <= 68 && pixel_y >= 28 && pixel_y <= 36) &&
                  (pixel_x == 63 || pixel_x == 68 || (pixel_x == pixel_y + 35));
    // E: Left bar and three horizontal bars
    wire char_E = (pixel_x >= 72 && pixel_x <= 77 && pixel_y >= 28 && pixel_y <= 36) &&
                  (pixel_x == 72 || pixel_y == 28 || pixel_y == 32 || pixel_y == 36);

    // --- 3. Bottom: Full Status Bar ---
    wire is_status_bg = (pixel_y >= 58 && pixel_y <= 62);
    wire is_progress  = is_status_bg && (pixel_x <= 95); 

    // --- Final Pixel Mux ---
    always @(*) begin
        if (num_1 || char_D || char_O || char_N || char_E)
            pixel_data = WHITE;
        else if (rec_icon)
            pixel_data = RED; // Recording icons are traditionally red
        else if (is_tick || is_progress)
            pixel_data = GREEN;
        else if (is_status_bg)
            pixel_data = GREY;
        else
            pixel_data = BLACK;
    end

endmodule