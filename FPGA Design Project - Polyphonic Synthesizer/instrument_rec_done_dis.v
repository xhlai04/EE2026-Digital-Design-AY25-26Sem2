`timescale 1ns / 1ps

module instrument_rec_done_dis(
    input clk,                // 100MHz System Clock
    input [6:0] pixel_x,      // 0-95
    input [5:0] pixel_y,      // 0-63
    input [10:0] write_ptr,   
    output reg [15:0] pixel_data
);

    // Color Definitions (RGB565)
    localparam RED    = 16'hF800;
    localparam WHITE  = 16'hFFFF;
    localparam GREY   = 16'h2104; 
    localparam BLACK  = 16'h0000;
    localparam GREEN  = 16'h07E0;

    // --- 1. Top Left: [2] + Play Symbol ---
    wire num_2 = (pixel_x >= 2 && pixel_x <= 5 && pixel_y >= 2 && pixel_y <= 8) &&
                 (pixel_y == 2 || pixel_y == 5 || pixel_y == 8 || (pixel_x == 5 && pixel_y <= 5) || (pixel_x == 2 && pixel_y >= 5));
    
    wire play_sym = (pixel_x >= 8 && pixel_x <= 14) && 
                                 (pixel_y + (14 - pixel_x) >= 5) && 
                                 (pixel_y <= 5 + (14 - pixel_x));

    // --- 2. Middle: Static Red Circle + "REC SAVED" ---
    wire [15:0] dist_sq = (pixel_x - 15)*(pixel_x - 15) + (pixel_y - 32)*(pixel_y - 32);
    wire rec_circle = (dist_sq < 40); 

    // Character R: Cleaned Up Logic
    wire char_R = (pixel_x >= 25 && pixel_x <= 30 && pixel_y >= 28 && pixel_y <= 36) && (
                  (pixel_x == 25) ||                                 // Vertical Spine
                  (pixel_y == 28 && pixel_x <= 29) ||                // Top Bar
                  (pixel_y == 32 && pixel_x <= 29) ||                // Middle Bar
                  (pixel_x == 30 && pixel_y > 28 && pixel_y < 32) || // Curved Right Side
                  (pixel_x == 28 && pixel_y == 33) ||                // Leg Start
                  (pixel_x == 29 && pixel_y == 34) ||                // Leg Mid
                  (pixel_x == 30 && pixel_y >= 35)                   // Leg End
              );

    wire char_E = (pixel_x >= 33 && pixel_x <= 38 && pixel_y >= 28 && pixel_y <= 36) &&
                  (pixel_x == 33 || pixel_y == 28 || pixel_y == 32 || pixel_y == 36);
    wire char_C = (pixel_x >= 41 && pixel_x <= 46 && pixel_y >= 28 && pixel_y <= 36) &&
                  (pixel_x == 41 || pixel_y == 28 || pixel_y == 36);

    // "SAVED" Text
    wire char_S = (pixel_x >= 52 && pixel_x <= 57 && pixel_y >= 28 && pixel_y <= 36) &&
                  (pixel_y == 28 || pixel_y == 32 || pixel_y == 36 || (pixel_x == 52 && pixel_y <= 32) || (pixel_x == 57 && pixel_y >= 32));
    wire char_A = (pixel_x >= 60 && pixel_x <= 65 && pixel_y >= 28 && pixel_y <= 36) &&
                  (pixel_x == 60 || pixel_x == 65 || pixel_y == 28 || pixel_y == 32);
    wire char_V = (pixel_x >= 68 && pixel_x <= 73 && pixel_y >= 28 && pixel_y <= 36) &&
                  ((pixel_x == 68 || pixel_x == 73) && pixel_y <= 33 || (pixel_x >= 70 && pixel_x <= 71 && pixel_y >= 34));
    wire char_E2 = (pixel_x >= 76 && pixel_x <= 81 && pixel_y >= 28 && pixel_y <= 36) &&
                  (pixel_x == 76 || pixel_y == 28 || pixel_y == 32 || pixel_y == 36);
    wire char_D = (pixel_x >= 84 && pixel_x <= 89 && pixel_y >= 28 && pixel_y <= 36) &&
                  (pixel_x == 84 || (pixel_x == 89 && pixel_y > 28 && pixel_y < 36) || (pixel_y == 28 && pixel_x < 89) || (pixel_y == 36 && pixel_x < 89));

    // --- 3. Bottom: Status Bar ---
    wire [31:0] prog_calc = (write_ptr * 96);
    wire [6:0] progress_width = prog_calc >> 11;
    wire is_status_bg = (pixel_y >= 58 && pixel_y <= 62);
    wire is_progress  = is_status_bg && (pixel_x <= progress_width);

    // --- Final Pixel Mux ---
    always @(*) begin
        if (num_2 || play_sym || char_R || char_E || char_C || char_S || char_A || char_V || char_E2 || char_D)
            pixel_data = WHITE;
        else if (rec_circle)
            pixel_data = RED;
        else if (is_progress)
            pixel_data = GREEN;
        else if (is_status_bg)
            pixel_data = GREY;
        else
            pixel_data = BLACK;
    end

endmodule