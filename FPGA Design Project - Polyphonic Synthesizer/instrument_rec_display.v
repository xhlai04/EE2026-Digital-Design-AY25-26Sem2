`timescale 1ns / 1ps

module instrument_rec_display(
    input clk,
    input [6:0] pixel_x,
    input [5:0] pixel_y,
    input [10:0] write_ptr,
    output reg [15:0] pixel_data
    );
    
    // Color Definitions (RGB565)
    localparam RED    = 16'hF800;
    localparam WHITE  = 16'hFFFF;
    localparam GREY   = 16'h2104; // Dark Grey
    localparam BLACK  = 16'h0000;
    localparam GREEN  = 16'h07E0;
    
    // --- Internal Blinking Clock ---
    reg [26:0] blink_counter = 0;
    always @(posedge clk) blink_counter <= blink_counter + 1;
    wire blink_sig = blink_counter[25]; // Using bit 25 for a visible blink rate
    
    // --- 1. Top Left: [1] + Pause Symbol ---
    wire num_1 = (pixel_x >= 2 && pixel_x <= 4 && pixel_y >= 2 && pixel_y <= 8) && (pixel_x == 3);
    
    wire pause_sym = (pixel_y >= 2 && pixel_y <= 8) && 
                     ((pixel_x >= 8 && pixel_x <= 9) || (pixel_x >= 12 && pixel_x <= 13));

    // --- 2. Top Right: [3] + Save Icon ---
    wire num_3 = (pixel_x >= 72 && pixel_x <= 75 && pixel_y >= 2 && pixel_y <= 8) &&
                 (pixel_y == 2 || pixel_y == 5 || pixel_y == 8 || pixel_x == 75);
                     
    // Save Icon (Download Arrow)
    wire down_stem   = (pixel_x == 85 && pixel_y >= 2 && pixel_y <= 5);
    wire [6:0] dx_sym = (pixel_x > 85) ? (pixel_x - 85) : (85 - pixel_x);
    wire [5:0] dy_sym = (pixel_y > 7)  ? (pixel_y - 7)  : (7 - pixel_y);
    wire down_arrows = (pixel_y >= 4 && pixel_y <= 7 && (dx_sym == dy_sym));
    wire down_bar    = (pixel_x >= 80 && pixel_x <= 90 && pixel_y == 8);
    wire save_sym    = (down_stem || down_arrows || down_bar);

    // --- 3. Center: Blinking REC Circle & "REC" Text ---
    // Circle math (Centered at 25, 32)
    wire [15:0] dist_sq = (pixel_x - 25)*(pixel_x - 25) + (pixel_y - 32)*(pixel_y - 32);
    wire rec_circle = (dist_sq < 40); 
    
    wire char_R = (pixel_x >= 38 && pixel_x <= 43 && pixel_y >= 28 && pixel_y <= 36) && (
                   (pixel_x == 38)                                   ||
                   (pixel_y == 28 && pixel_x <= 42)                  ||
                   (pixel_y == 32 && pixel_x <= 42)                  ||
                   (pixel_x == 43 && pixel_y > 28 && pixel_y < 32)   ||
                   (pixel_x == 38 + (pixel_y-32) && pixel_y >= 33)
                  );
    wire char_E = (pixel_x >= 47 && pixel_x <= 52 && pixel_y >= 28 && pixel_y <= 36) &&
                  (pixel_x == 47 || pixel_y == 28 || pixel_y == 32 || pixel_y == 36);
    wire char_C = (pixel_x >= 56 && pixel_x <= 61 && pixel_y >= 28 && pixel_y <= 36) &&
                  (pixel_x == 56 || pixel_y == 28 || pixel_y == 36);

    // --- 4. Bottom: Status Bar ---
    wire [31:0] prog_calc = (write_ptr * 96);
    wire [6:0] progress_width = prog_calc >> 11; // 2048 max capacity
    wire is_status_bg = (pixel_y >= 58 && pixel_y <= 62);
    wire is_progress  = is_status_bg && (pixel_x <= progress_width);

    // --- Final Pixel Mux ---
    always @(*) begin
        // Top Row Icons (Static White)
        if (num_1 || num_3 || pause_sym || save_sym) begin
            pixel_data = WHITE;
        end
        // Central UI (Blinking)
        else if (blink_sig && (rec_circle || char_R || char_E || char_C)) begin
            if (rec_circle)
                pixel_data = RED;
            else
                pixel_data = WHITE;
        end
        // Progress Bar
        else if (is_progress) begin
            pixel_data = GREEN;
        end
        else if (is_status_bg) begin
            pixel_data = GREY;
        end
        // Background
        else begin
            pixel_data = BLACK;
        end
    end

endmodule