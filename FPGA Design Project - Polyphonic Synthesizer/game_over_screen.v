`timescale 1ns / 1ps

module game_over_screen(
    input [12:0] pixel_index,
    output [15:0] pixel_data
);

    localparam BLACK = 16'h0000;

    localparam TEXT_X = 12;
    localparam TEXT_Y = 24;
    localparam TEXT_W = 72;
    localparam TEXT_H = 16;

    wire [6:0] x;
    wire [5:0] y;

    wire [15:0] game_over_text_pixel;
    wire game_over_text_on;

    assign x = pixel_index % 96;
    assign y = pixel_index / 96;

    bitmap_rgb565_rom #(.W(TEXT_W), .H(TEXT_H), .FILE("game_over.mem")) u_game_over_text (.x(x - TEXT_X), .y(y - TEXT_Y), .pixel_data(game_over_text_pixel), .pixel_on(game_over_text_on));

    assign pixel_data = game_over_text_on ? game_over_text_pixel : BLACK;

endmodule