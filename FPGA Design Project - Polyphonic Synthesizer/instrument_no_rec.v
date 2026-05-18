module instrument_no_rec_dis(
    input [6:0] pixel_x,      // 0-95
    input [5:0] pixel_y,      // 0-63
    output reg [15:0] pixel_data
);

    localparam RED   = 16'hF800;
    localparam WHITE = 16'hFFFF;
    localparam BLACK = 16'h0000;

    // --- 1. Big Red Cross ---
    wire [6:0] dx = (pixel_x > 48) ? (pixel_x - 48) : (48 - pixel_x);
    wire [5:0] dy = (pixel_y > 25) ? (pixel_y - 25) : (25 - pixel_y);
    wire in_cross_area = (pixel_x >= 33 && pixel_x <= 63 && pixel_y >= 10 && pixel_y <= 40);
    wire is_cross = in_cross_area && ((dx == dy) || (dx == dy + 1) || (dx == dy - 1));

    // --- 2. "NO REC" Text ---
    
    // N
    wire char_N = (pixel_x >= 26 && pixel_x <= 31 && pixel_y >= 50 && pixel_y <= 58) &&
                  (pixel_x == 26 || pixel_x == 31 || (pixel_x == pixel_y - 24));
    // O
    wire char_O = (pixel_x >= 34 && pixel_x <= 39 && pixel_y >= 50 && pixel_y <= 58) &&
                  (pixel_x == 34 || pixel_x == 39 || pixel_y == 50 || pixel_y == 58);

    // R (Improved Diagonal)
    wire char_R = (pixel_x >= 47 && pixel_x <= 52 && pixel_y >= 50 && pixel_y <= 58) &&
                  (pixel_x == 47 || pixel_y == 50 || pixel_y == 54 || (pixel_x == 52 && pixel_y <= 54) || (pixel_x == pixel_y - 6 && pixel_y >= 54));
    
    // E
    wire char_E = (pixel_x >= 55 && pixel_x <= 60 && pixel_y >= 50 && pixel_y <= 58) &&
                  (pixel_x == 55 || pixel_y == 50 || pixel_y == 54 || pixel_y == 58);
    
    // C
    wire char_C = (pixel_x >= 63 && pixel_x <= 68 && pixel_y >= 50 && pixel_y <= 58) &&
                  (pixel_x == 63 || pixel_y == 50 || pixel_y == 58);

    wire is_text = char_N || char_O || char_R || char_E || char_C;

    always @(*) begin
        if (is_cross)      pixel_data = RED;
        else if (is_text)  pixel_data = WHITE;
        else               pixel_data = BLACK;
    end
endmodule