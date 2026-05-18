`timescale 1ns / 1ps

module game_play_jb_screen(
    input [12:0] pixel_index,
    input [1:0] encouragement_state,
    output [15:0] pixel_data
);

    localparam ENC_NONE      = 2'd0;
    localparam ENC_TRY_AGAIN = 2'd1;
    localparam ENC_KEEP_ITUP = 2'd2;
    localparam ENC_ON_FIRE   = 2'd3;

    localparam BLACK = 16'h0000;

    // ---------------------------------------------------------
    // Layout
    // ---------------------------------------------------------
    localparam TITLE_X = 12;
    localparam TITLE_Y = 2;
    localparam TITLE_W = 72;
    localparam TITLE_H = 16;

    localparam ICON_X  = 40;
    localparam ICON_Y  = 24;
    localparam ICON_W  = 16;
    localparam ICON_H  = 16;

    localparam MSG_X   = 12;
    localparam MSG_Y   = 46;
    localparam MSG_W   = 72;
    localparam MSG_H   = 16;

    wire [6:0] x;
    wire [5:0] y;

    assign x = pixel_index % 96;
    assign y = pixel_index / 96;

    // ---------------------------------------------------------
    // Title bitmap (always shown)
    // Placeholder file name
    // ---------------------------------------------------------
    wire [15:0] title_pixel;
    wire title_on;
    bitmap_rgb565_rom #(.W(TITLE_W), .H(TITLE_H), .FILE("3piano_hero_72x16.mem")) u_title (.x(x - TITLE_X), .y(y - TITLE_Y), .pixel_data(title_pixel), .pixel_on(title_on));

    // ---------------------------------------------------------
    // Encouragement message bitmaps
    // Placeholder file names
    // ---------------------------------------------------------
    wire [15:0] try_again_pixel;
    wire try_again_on;
    bitmap_rgb565_rom #(.W(MSG_W), .H(MSG_H), .FILE("try_again_72x16.mem")) u_try_again (.x(x - MSG_X), .y(y - MSG_Y), .pixel_data(try_again_pixel), .pixel_on(try_again_on));

    wire [15:0] keep_it_up_pixel;
    wire keep_it_up_on;
    bitmap_rgb565_rom #(.W(MSG_W), .H(MSG_H), .FILE("keep_it_up_72x16.mem")) u_keep_it_up (.x(x - MSG_X), .y(y - MSG_Y), .pixel_data(keep_it_up_pixel), .pixel_on(keep_it_up_on));

    wire [15:0] on_fire_pixel;
    wire on_fire_on;
    bitmap_rgb565_rom #(.W(MSG_W), .H(MSG_H), .FILE("on_fire_72x16.mem")) u_on_fire (.x(x - MSG_X), .y(y - MSG_Y), .pixel_data(on_fire_pixel), .pixel_on(on_fire_on));

    // ---------------------------------------------------------
    // Encouragement icon bitmaps
    // Placeholder file names
    // ---------------------------------------------------------
    wire [15:0] cross_pixel;
    wire cross_on;
    bitmap_rgb565_rom #(.W(ICON_W), .H(ICON_H), .FILE("cross_icon_16x16.mem")) u_cross_icon (.x(x - ICON_X), .y(y - ICON_Y), .pixel_data(cross_pixel), .pixel_on(cross_on));

    wire [15:0] tick_pixel;
    wire tick_on;
    bitmap_rgb565_rom #(.W(ICON_W), .H(ICON_H), .FILE("tick_icon_16x16.mem")) u_tick_icon (.x(x - ICON_X), .y(y - ICON_Y), .pixel_data(tick_pixel), .pixel_on(tick_on));

    wire [15:0] fire_pixel;
    wire fire_on;
    bitmap_rgb565_rom #(.W(ICON_W), .H(ICON_H), .FILE("fire_icon_16x16.mem")) u_fire_icon (.x(x - ICON_X), .y(y - ICON_Y), .pixel_data(fire_pixel), .pixel_on(fire_on));

    // ---------------------------------------------------------
    // Select which encouragement assets are active
    // ---------------------------------------------------------
    wire [15:0] selected_msg_pixel;
    wire selected_msg_on;
    wire [15:0] selected_icon_pixel;
    wire selected_icon_on;

    assign selected_msg_pixel =
        (encouragement_state == ENC_TRY_AGAIN) ? try_again_pixel :
        (encouragement_state == ENC_KEEP_ITUP) ? keep_it_up_pixel :
        (encouragement_state == ENC_ON_FIRE)   ? on_fire_pixel :
        BLACK;

    assign selected_msg_on =
        (encouragement_state == ENC_TRY_AGAIN) ? try_again_on :
        (encouragement_state == ENC_KEEP_ITUP) ? keep_it_up_on :
        (encouragement_state == ENC_ON_FIRE)   ? on_fire_on :
        1'b0;

    assign selected_icon_pixel =
        (encouragement_state == ENC_TRY_AGAIN) ? cross_pixel :
        (encouragement_state == ENC_KEEP_ITUP) ? tick_pixel :
        (encouragement_state == ENC_ON_FIRE)   ? fire_pixel :
        BLACK;

    assign selected_icon_on =
        (encouragement_state == ENC_TRY_AGAIN) ? cross_on :
        (encouragement_state == ENC_KEEP_ITUP) ? tick_on :
        (encouragement_state == ENC_ON_FIRE)   ? fire_on :
        1'b0;

    // ---------------------------------------------------------
    // Layer priority:
    // 1. title
    // 2. icon
    // 3. message
    // ---------------------------------------------------------
    assign pixel_data =
        selected_msg_on  ? selected_msg_pixel  :
        selected_icon_on ? selected_icon_pixel :
        title_on         ? title_pixel         :
        BLACK;

endmodule
