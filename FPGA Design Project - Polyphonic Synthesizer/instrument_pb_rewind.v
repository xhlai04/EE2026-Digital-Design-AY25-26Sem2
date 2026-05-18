`timescale 1ns / 1ps

module instrument_pb_rewind_dis(
    input clk,                // 100MHz System Clock
    input [6:0] pixel_x,      // 0-95
    input [5:0] pixel_y,      // 0-63
    input [10:0] read_ptr,    // Current decreasing playback position
    input [10:0] max_ptr,     // Total recorded length
    output reg [15:0] pixel_data
);

    // Color Definitions (RGB565)
    localparam WHITE  = 16'hFFFF;
    localparam GREY   = 16'h2104; 
    localparam BLACK  = 16'h0000;
    localparam CYAN   = 16'h07FF; 

    // --- Internal Rapid Blinking Clock ---
    reg [25:0] blink_counter = 0;
    always @(posedge clk) blink_counter <= blink_counter + 1;
    wire fast_blink = blink_counter[23]; 

    // --- 1. Middle: Large Fast-Blinking Rewind Icon (Solid) ---
    // Double Triangle pointing LEFT
    // Triangle 1: Tip at 20, Base at 30, Center Y=32
    // Height expands as we move AWAY from the tip (X=20)
    wire tri_1 = (pixel_x >= 20 && pixel_x <= 30) && 
                 (pixel_y >= 32 - (pixel_x - 20)) && 
                 (pixel_y <= 32 + (pixel_x - 20)) && fast_blink;
    
    // Triangle 2: Tip at 32, Base at 42, Center Y=32
    wire tri_2 = (pixel_x >= 32 && pixel_x <= 42) && 
                 (pixel_y >= 32 - (pixel_x - 32)) && 
                 (pixel_y <= 32 + (pixel_x - 32)) && fast_blink;

    // --- 2. "REW" Text ---
    // R: Vertical bar, top curve, and fixed diagonal leg
    wire char_R = (pixel_x >= 50 && pixel_x <= 55 && pixel_y >= 28 && pixel_y <= 36) && (
                  (pixel_x == 50) ||                         // Spine
                  (pixel_y == 28 && pixel_x <= 54) ||        // Top
                  (pixel_y == 32 && pixel_x <= 54) ||        // Mid
                  (pixel_x == 55 && pixel_y > 28 && pixel_y < 32) || // Curve
                  (pixel_x == pixel_y + 19 && pixel_y >= 32)  // Leg: 32+19=51, 36+19=55. Fits 50-55.
              );

    // E: Vertical bar and three horizontal bars
    wire char_E = (pixel_x >= 58 && pixel_x <= 63 && pixel_y >= 28 && pixel_y <= 36) &&
                  (pixel_x == 58 || pixel_y == 28 || pixel_y == 32 || pixel_y == 36);

    // W: Refined with middle stem
    wire char_W = (pixel_x >= 66 && pixel_x <= 72 && pixel_y >= 28 && pixel_y <= 36) &&
                  (pixel_x == 66 || pixel_x == 72 || 
                  (pixel_y == 36 && pixel_x >= 67 && pixel_x <= 71) ||
                  (pixel_x == 69 && pixel_y >= 32));

    // --- 3. Bottom: Status Bar ---
    wire [31:0] prog_calc = (read_ptr * 96);
    wire [6:0] progress_width = (max_ptr > 0) ? (prog_calc / max_ptr) : 0;
    wire is_status_bg = (pixel_y >= 58 && pixel_y <= 62);
    wire is_progress  = is_status_bg && (pixel_x <= progress_width);

    // --- Final Pixel Mux ---
    always @(*) begin
        if (char_R || char_E || char_W)
            pixel_data = WHITE;
        else if (tri_1 || tri_2)
            pixel_data = CYAN; 
        else if (is_progress)
            pixel_data = CYAN;
        else if (is_status_bg)
            pixel_data = GREY;
        else
            pixel_data = BLACK;
    end

endmodule