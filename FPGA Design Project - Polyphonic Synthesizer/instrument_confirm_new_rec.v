`timescale 1ns / 1ps

module instrument_confirm_new_rec(
    input [6:0] pixel_x,      // 0-95
    input [5:0] pixel_y,      // 0-63
    output reg [15:0] pixel_data
);

    // Color Definitions (RGB565)
    localparam WHITE  = 16'hFFFF;
    localparam BLACK  = 16'h0000;
    localparam RED    = 16'hF800;

    // --- 1. Top Left: "1: YES" ---
    wire char_1 = (pixel_x == 5 && pixel_y >= 5 && pixel_y <= 11);
    
// char_Y: left arm x=8?11, right arm x=14?11, stem at x=11
    wire char_Y = (pixel_y >= 5 && pixel_y <= 8 && (pixel_x == pixel_y + 3 || pixel_x == 19 - pixel_y)) ||
                  (pixel_x == 11 && pixel_y >= 8 && pixel_y <= 11);

    
    wire char_E = (pixel_x >= 15 && pixel_x <= 18 && pixel_y >= 5 && pixel_y <= 11) && 
                  (pixel_x == 15 || pixel_y == 5 || pixel_y == 8 || pixel_y == 11);
    wire char_S = (pixel_x >= 20 && pixel_x <= 23 && pixel_y >= 5 && pixel_y <= 11) && 
                  (pixel_y == 5 || pixel_y == 8 || pixel_y == 11 || (pixel_x == 20 && pixel_y <= 8) || (pixel_x == 23 && pixel_y >= 8));

    // --- 2. Top Right: "3: NO" (Fixed to 3) ---
    // Number 3
    wire char_3 = (pixel_x >= 72 && pixel_x <= 75 && pixel_y >= 5 && pixel_y <= 11) &&
                  (pixel_y == 5 || pixel_y == 8 || pixel_y == 11 || pixel_x == 75);

    wire char_N = (pixel_x >= 80 && pixel_x <= 84 && pixel_y >= 5 && pixel_y <= 11) && 
                  (pixel_x == 80 || pixel_x == 84 || (pixel_x == pixel_y + 75));
    wire char_O = (pixel_x >= 87 && pixel_x <= 91 && pixel_y >= 5 && pixel_y <= 11) && 
                  (pixel_y == 5 || pixel_y == 11 || pixel_x == 87 || pixel_x == 91);

    // --- 3. Middle: Large "?" (Centered) ---
    wire char_Q_Mark = (pixel_x >= 44 && pixel_x <= 52 && pixel_y >= 20 && pixel_y <= 40) && (
        (pixel_y == 20 && pixel_x >= 45 && pixel_x <= 51) || 
        (pixel_x == 52 && pixel_y >= 21 && pixel_y <= 28) || 
        (pixel_y == 28 && pixel_x >= 48 && pixel_x <= 51) || 
        (pixel_x == 48 && pixel_y >= 29 && pixel_y <= 34) || 
        (pixel_x == 48 && pixel_y >= 38 && pixel_y <= 40)
    );

    // --- 4. Bottom: "NEW REC" (Centered) ---
    // Total width of "NEW REC" is roughly 52 pixels. 
    // Starting at X=22 to center it (96 - 52)/2 = 22.

    // NEW
    wire b_N = (pixel_x >= 22 && pixel_x <= 27 && pixel_y >= 50 && pixel_y <= 58) && (pixel_x == 22 || pixel_x == 27 || pixel_x == pixel_y - 28);
    wire b_E = (pixel_x >= 30 && pixel_x <= 35 && pixel_y >= 50 && pixel_y <= 58) && (pixel_x == 30 || pixel_y == 50 || pixel_y == 54 || pixel_y == 58);
    wire b_W = (pixel_x >= 38 && pixel_x <= 44 && pixel_y >= 50 && pixel_y <= 58) && 
               (pixel_x == 38 || pixel_x == 44 || (pixel_y == 58 && pixel_x >= 39 && pixel_x <= 43) || (pixel_x == 41 && pixel_y >= 54));
    
    // REC
    // b_R: spine | top | mid | right curve | diagonal leg stays in-bounds
    wire b_R = (pixel_x >= 52 && pixel_x <= 57 && pixel_y >= 50 && pixel_y <= 58) && (
               (pixel_x == 52)                                    ||  // Spine
               (pixel_y == 50 && pixel_x <= 56)                   ||  // Top bar
               (pixel_y == 54 && pixel_x <= 56)                   ||  // Mid bar
               (pixel_x == 57 && pixel_y > 50 && pixel_y < 54)    ||  // Right curve
               (pixel_x == 52 + (pixel_y - 54) && pixel_y >= 55)      // Leg: x=53..58 clamped by box
               );
    
    wire b_E2 = (pixel_x >= 60 && pixel_x <= 65 && pixel_y >= 50 && pixel_y <= 58) && (pixel_x == 60 || pixel_y == 50 || pixel_y == 54 || pixel_y == 58);
    wire b_C = (pixel_x >= 68 && pixel_x <= 73 && pixel_y >= 50 && pixel_y <= 58) && (pixel_x == 68 || pixel_y == 50 || pixel_y == 58);

    // --- Final Pixel Mux ---
    always @(*) begin
        if (char_1 || char_Y || char_E || char_S || char_3 || char_N || char_O || b_N || b_E || b_W || b_R || b_E2 || b_C)
            pixel_data = WHITE;
        else if (char_Q_Mark)
            pixel_data = RED;
        else
            pixel_data = BLACK;
    end

endmodule