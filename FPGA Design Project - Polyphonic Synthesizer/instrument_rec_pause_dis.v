`timescale 1ns / 1ps

module instrument_rec_pause_dis(
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

    // --- Internal Blinking Clock ---
    reg [26:0] blink_counter = 0;
    always @(posedge clk) blink_counter <= blink_counter + 1; 
    wire blink_sig = blink_counter[25]; 

    // --- 1. Top Left: [1] + Recording Symbol (Circle) ---
    wire num_1 = (pixel_x >= 2 && pixel_x <= 4 && pixel_y >= 2 && pixel_y <= 8) && (pixel_x == 3);
    wire [15:0] top_dist_sq = (pixel_x - 10)*(pixel_x - 10) + (pixel_y - 5)*(pixel_y - 5);
    wire rec_icon = (top_dist_sq < 12);

    // --- 2. Top Right: [3] + Save Icon ---
    wire num_3 = (pixel_x >= 72 && pixel_x <= 75 && pixel_y >= 2 && pixel_y <= 8) &&
                 (pixel_y == 2 || pixel_y == 5 || pixel_y == 8 || pixel_x == 75);
                     
    wire down_stem   = (pixel_x == 85 && pixel_y >= 2 && pixel_y <= 5);
    wire [6:0] dx_sym = (pixel_x > 85) ? (pixel_x - 85) : (85 - pixel_x);
    wire [5:0] dy_sym = (pixel_y > 7)  ? (pixel_y - 7)  : (7 - pixel_y);
    wire down_arrows = (pixel_y >= 4 && pixel_y <= 7 && (dx_sym == dy_sym));
    wire down_bar    = (pixel_x >= 80 && pixel_x <= 90 && pixel_y == 8);
    wire save_sym    = (down_stem || down_arrows || down_bar);

    // --- 3. Center: Blinking Pause Symbol & "REC" ---
    // Pause Bars (Blinking)
    wire pause_center = (pixel_y >= 25 && pixel_y <= 39) && blink_sig &&
                        ((pixel_x >= 25 && pixel_x <= 28) || (pixel_x >= 32 && pixel_x <= 35));

    // Improved "REC" Text
    wire char_R = (pixel_x >= 45 && pixel_x <= 50 && pixel_y >= 28 && pixel_y <= 36) && (
                   (pixel_x == 45)                                   ||
                   (pixel_y == 28 && pixel_x <= 49)                  ||
                   (pixel_y == 32 && pixel_x <= 49)                  ||
                   (pixel_x == 50 && pixel_y > 28 && pixel_y < 32)   ||
                   (pixel_x == 45 + (pixel_y-32) && pixel_y >= 33)
                  );
    wire char_E = (pixel_x >= 54 && pixel_x <= 59 && pixel_y >= 28 && pixel_y <= 36) &&
                  (pixel_x == 54 || pixel_y == 28 || pixel_y == 32 || pixel_y == 36);
    wire char_C = (pixel_x >= 63 && pixel_x <= 68 && pixel_y >= 28 && pixel_y <= 36) &&
                  (pixel_x == 63 || pixel_y == 28 || pixel_y == 36);
                  
    // --- 4. Bottom: Status Bar ---
                  wire [31:0] prog_calc = (write_ptr * 96);
                  wire [6:0] progress_width = (prog_calc / 11'd2047); // normalized against max buffer
                  wire is_status_bg = (pixel_y >= 58 && pixel_y <= 62);
                  wire is_progress  = is_status_bg && (pixel_x <= progress_width);

    // --- Final Pixel Mux ---
    always @(*) begin
        if (num_1 || num_3 || save_sym || pause_center || char_R || char_E || char_C)
            pixel_data = WHITE;
        else if (rec_icon)
            pixel_data = RED;
        else if (is_progress)
            pixel_data = GREEN;
        else if (is_status_bg)
            pixel_data = GREY;
        else
            pixel_data = BLACK;
    end

endmodule