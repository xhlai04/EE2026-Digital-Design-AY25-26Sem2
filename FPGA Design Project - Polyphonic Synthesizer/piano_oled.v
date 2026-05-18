`timescale 1ns / 1ps

module piano_oled(
    input CLOCK_100MHZ,
    input [31:0] scancode_bus_in,
    input [3:0] note_on_bus_in,
    input [7:0] kb_scancode,
    input out_stroke,
    input key_released,
    input isDone,
    input note_trigger,
    input [31:0] tile_speed,
    input pianoGameStart,
    output [7:0] JC,
    output reg [15:0] SCORE_COUNTER,
    output reg hit_event,
    output reg miss_event,
    output game_done
  );

  localparam OLED_W    = 96;
  localparam OLED_H    = 64;
  localparam KEY_W     = 12;
  localparam KEY_H     = 30;
  localparam KEY_Y     = 54;
  localparam TILE_W    = 10;
  localparam TILE_H    = 5;
  localparam NUM_TILES = 8;

  localparam JUST_RIGHT_THRESHOLD = 4;

  localparam T_IDLE  = 2'd0;
  localparam T_EARLY = 2'd1;
  localparam T_JUST  = 2'd2;
  localparam T_LATE  = 2'd3;

  localparam [15:0] COLOR_BLACK    = 16'h0000;
  localparam [15:0] COLOR_BORDER   = 16'h4228;
  localparam [15:0] COLOR_KEY_FILL = 16'hAD55;
  localparam [15:0] COLOR_TILE     = 16'hFC00;

  localparam [15:0] COLOR_IDLE    = 16'hAD55;
  localparam [15:0] COLOR_EARLY_C = 16'hFFE0;
  localparam [15:0] COLOR_JUST_C  = 16'h07E0;
  localparam [15:0] COLOR_LATE_C  = 16'hF800;

  localparam FLASH_CYCLES = 32'd50_000_000;

  wire clk625mhz;
  wire frame_begin;
  wire sending_pixels;
  wire sample_pixel;
  wire [12:0] pixel_index;
  wire [15:0] pixel_data;

  wire [6:0] x = pixel_index % OLED_W;
  wire [5:0] y = pixel_index / OLED_W;

  reg [5:0] tile_y [0:NUM_TILES-1];
  reg [2:0] tile_key_r [0:NUM_TILES-1];
  reg tile_active [0:NUM_TILES-1];
  reg [31:0] fall_cnt [0:NUM_TILES-1];
  reg [1:0] tile_timing [0:NUM_TILES-1];
  reg [31:0] flash_cnt [0:NUM_TILES-1];
  reg flashing [0:NUM_TILES-1];
  reg [2:0] spawn_idx;
  reg out_stroke_d;
  integer spawn_ptr;
  reg [7:0] spawn_scancode;

  integer best_idx;
  reg [5:0] best_y;

  integer i;

reg [31:0] debounce_cnt    = 0;
reg        debounce_armed  = 1;
reg        stroke_pulse    = 0;
reg        out_stroke_prev = 0;

  slow_clock clock_6_25mhz(.CLOCK(CLOCK_100MHZ), .n_cycles(8), .OUTPUT_CLOCK(clk625mhz));

  Oled_Display oled_inst(.clk(clk625mhz), .reset(1'b0), .frame_begin(frame_begin), .sending_pixels(sending_pixels), .sample_pixel(sample_pixel), .pixel_index(pixel_index), .pixel_data(pixel_data), .cs(JC[0]), .sdin(JC[1]), .sclk(JC[3]), .d_cn(JC[4]), .resn(JC[5]), .vccen(JC[6]), .pmoden(JC[7]));

  function automatic [2:0] scancode_to_key;
    input [7:0] sc;
    begin
      case (sc)
        8'h1C:
          scancode_to_key = 3'd0;
        8'h1B:
          scancode_to_key = 3'd1;
        8'h23:
          scancode_to_key = 3'd2;
        8'h2B:
          scancode_to_key = 3'd3;
        8'h34:
          scancode_to_key = 3'd4;
        8'h33:
          scancode_to_key = 3'd5;
        8'h3B:
          scancode_to_key = 3'd6;
        8'h42:
          scancode_to_key = 3'd7;
        default:
          scancode_to_key = 3'd0;
      endcase
    end
  endfunction

  reg [2:0] kb_key;
  always @(*)
  begin
    case (kb_scancode)
      8'h1C:
        kb_key = 3'd0;
      8'h1B:
        kb_key = 3'd1;
      8'h23:
        kb_key = 3'd2;
      8'h2B:
        kb_key = 3'd3;
      8'h34:
        kb_key = 3'd4;
      8'h33:
        kb_key = 3'd5;
      8'h3B:
        kb_key = 3'd6;
      8'h42:
        kb_key = 3'd7;
      default:
        kb_key = 3'd0;
    endcase
  end

  function automatic [15:0] timing_color;
    input [1:0] t;
    begin
      case (t)
        T_IDLE:
          timing_color = COLOR_IDLE;
        T_EARLY:
          timing_color = COLOR_EARLY_C;
        T_JUST:
          timing_color = COLOR_JUST_C;
        T_LATE:
          timing_color = COLOR_LATE_C;
        default:
          timing_color = COLOR_IDLE;
      endcase
    end
  endfunction

  function automatic [6:0] get_tile_x;
    input [2:0] k;
    begin
      get_tile_x = (k * KEY_W) + 1;
    end
  endfunction

  always @(posedge CLOCK_100MHZ)
  begin
    hit_event  <= 1'b0;
    miss_event <= 1'b0;
    out_stroke_d <= out_stroke;

    if (pianoGameStart)
    begin
      SCORE_COUNTER <= 16'd0;
      spawn_idx     <= 3'd0;
      out_stroke_d  <= 1'b0;
      for (i = 0; i < NUM_TILES; i = i + 1)
      begin
        tile_y[i]      <= 6'd0;
        tile_key_r[i]  <= 3'd0;
        tile_active[i] <= 1'b0;
        fall_cnt[i]    <= 32'd0;
        tile_timing[i] <= T_IDLE;
        flash_cnt[i]   <= 32'd0;
        flashing[i]    <= 1'b0;
      end

    end
    else
    begin

      // === FALL + FLASH (for loops are safe here, no conflict) ===
      for (i = 0; i < NUM_TILES; i = i + 1)
      begin
        if (tile_active[i])
        begin
          if (fall_cnt[i] >= tile_speed - 1)
          begin
            fall_cnt[i] <= 32'd0;
            if (tile_y[i] >= OLED_H - TILE_H)
            begin
              tile_active[i] <= 1'b0;
              tile_timing[i] <= T_LATE;
              flashing[i]    <= 1'b1;
              flash_cnt[i]   <= 32'd0;
              miss_event     <= 1'b1;
            end
            else
            begin
              tile_y[i] <= tile_y[i] + 1'b1;
            end
          end
          else
          begin
            fall_cnt[i] <= fall_cnt[i] + 1'b1;
          end
        end
      end

      for (i = 0; i < NUM_TILES; i = i + 1)
      begin
        if (flashing[i])
        begin
          if (flash_cnt[i] >= FLASH_CYCLES)
          begin
            flashing[i]    <= 1'b0;
            tile_timing[i] <= T_IDLE;
          end
          else
          begin
            flash_cnt[i] <= flash_cnt[i] + 1'b1;
          end
        end
      end

      // === SPAWN ===
      if (!isDone && note_trigger)
      begin
        spawn_ptr = spawn_idx;

        if (note_on_bus_in[0])
        begin
          spawn_scancode = scancode_bus_in[7:0];
          tile_y[spawn_ptr[2:0]]      <= 6'd0;
          tile_key_r[spawn_ptr[2:0]]  <= scancode_to_key(spawn_scancode);
          tile_active[spawn_ptr[2:0]] <= 1'b1;
          fall_cnt[spawn_ptr[2:0]]    <= 32'd0;
          tile_timing[spawn_ptr[2:0]] <= T_IDLE;
          flashing[spawn_ptr[2:0]]    <= 1'b0;
          flash_cnt[spawn_ptr[2:0]]   <= 32'd0;
          spawn_ptr = spawn_ptr + 1;
        end

        if (note_on_bus_in[1])
        begin
          spawn_scancode = scancode_bus_in[15:8];
          tile_y[spawn_ptr[2:0]]      <= 6'd0;
          tile_key_r[spawn_ptr[2:0]]  <= scancode_to_key(spawn_scancode);
          tile_active[spawn_ptr[2:0]] <= 1'b1;
          fall_cnt[spawn_ptr[2:0]]    <= 32'd0;
          tile_timing[spawn_ptr[2:0]] <= T_IDLE;
          flashing[spawn_ptr[2:0]]    <= 1'b0;
          flash_cnt[spawn_ptr[2:0]]   <= 32'd0;
          spawn_ptr = spawn_ptr + 1;
        end

        if (note_on_bus_in[2])
        begin
          spawn_scancode = scancode_bus_in[23:16];
          tile_y[spawn_ptr[2:0]]      <= 6'd0;
          tile_key_r[spawn_ptr[2:0]]  <= scancode_to_key(spawn_scancode);
          tile_active[spawn_ptr[2:0]] <= 1'b1;
          fall_cnt[spawn_ptr[2:0]]    <= 32'd0;
          tile_timing[spawn_ptr[2:0]] <= T_IDLE;
          flashing[spawn_ptr[2:0]]    <= 1'b0;
          flash_cnt[spawn_ptr[2:0]]   <= 32'd0;
          spawn_ptr = spawn_ptr + 1;
        end

        if (note_on_bus_in[3])
        begin
          spawn_scancode = scancode_bus_in[31:24];
          tile_y[spawn_ptr[2:0]]      <= 6'd0;
          tile_key_r[spawn_ptr[2:0]]  <= scancode_to_key(spawn_scancode);
          tile_active[spawn_ptr[2:0]] <= 1'b1;
          fall_cnt[spawn_ptr[2:0]]    <= 32'd0;
          tile_timing[spawn_ptr[2:0]] <= T_IDLE;
          flashing[spawn_ptr[2:0]]    <= 1'b0;
          flash_cnt[spawn_ptr[2:0]]   <= 32'd0;
          spawn_ptr = spawn_ptr + 1;
        end

        spawn_idx <= spawn_ptr[2:0];
      end

      // Trigger only on the rising edge of out_stroke.
      // Then choose the lowest (largest y) active tile in the pressed lane.
      if (out_stroke && !key_released && !out_stroke_d)
      begin
        best_idx = -1;
        best_y   = 6'd0;

        for (i = 0; i < NUM_TILES; i = i + 1)
        begin
          if (tile_active[i] && tile_key_r[i] == kb_key)
          begin
            if (best_idx < 0 || tile_y[i] > best_y)
            begin
              best_idx = i;
              best_y   = tile_y[i];
            end
          end
        end

        if (best_idx >= 0)
        begin
          tile_active[best_idx] <= 1'b0;
          flashing[best_idx]    <= 1'b1;
          flash_cnt[best_idx]   <= 32'd0;

          if (tile_y[best_idx] < KEY_Y - JUST_RIGHT_THRESHOLD)
          begin
            tile_timing[best_idx] <= T_EARLY;
            SCORE_COUNTER          <= SCORE_COUNTER + 16'd1;
            hit_event              <= 1'b1;
          end
          else if (tile_y[best_idx] <= KEY_Y + KEY_H)
          begin
            tile_timing[best_idx] <= T_JUST;
            SCORE_COUNTER          <= SCORE_COUNTER + 16'd3;
            hit_event              <= 1'b1;
          end
          else
          begin
            tile_timing[best_idx] <= T_LATE;
            miss_event             <= 1'b1;
          end
        end
      end
    end
  end

  wire in_any_key = (y >= KEY_Y) && (y < KEY_Y + KEY_H);
  wire on_divider = in_any_key && (x % KEY_W == 0);
  wire [2:0] cur_key = x / KEY_W;

  wire in_tile =
       (tile_active[0] && x >= get_tile_x(tile_key_r[0]) && x < get_tile_x(tile_key_r[0]) + TILE_W && y >= tile_y[0] && y < tile_y[0] + TILE_H) |
       (tile_active[1] && x >= get_tile_x(tile_key_r[1]) && x < get_tile_x(tile_key_r[1]) + TILE_W && y >= tile_y[1] && y < tile_y[1] + TILE_H) |
       (tile_active[2] && x >= get_tile_x(tile_key_r[2]) && x < get_tile_x(tile_key_r[2]) + TILE_W && y >= tile_y[2] && y < tile_y[2] + TILE_H) |
       (tile_active[3] && x >= get_tile_x(tile_key_r[3]) && x < get_tile_x(tile_key_r[3]) + TILE_W && y >= tile_y[3] && y < tile_y[3] + TILE_H) |
       (tile_active[4] && x >= get_tile_x(tile_key_r[4]) && x < get_tile_x(tile_key_r[4]) + TILE_W && y >= tile_y[4] && y < tile_y[4] + TILE_H) |
       (tile_active[5] && x >= get_tile_x(tile_key_r[5]) && x < get_tile_x(tile_key_r[5]) + TILE_W && y >= tile_y[5] && y < tile_y[5] + TILE_H) |
       (tile_active[6] && x >= get_tile_x(tile_key_r[6]) && x < get_tile_x(tile_key_r[6]) + TILE_W && y >= tile_y[6] && y < tile_y[6] + TILE_H) |
       (tile_active[7] && x >= get_tile_x(tile_key_r[7]) && x < get_tile_x(tile_key_r[7]) + TILE_W && y >= tile_y[7] && y < tile_y[7] + TILE_H);

  wire key_flash_0 = flashing[0] && cur_key == tile_key_r[0] && in_any_key;
  wire key_flash_1 = flashing[1] && cur_key == tile_key_r[1] && in_any_key;
  wire key_flash_2 = flashing[2] && cur_key == tile_key_r[2] && in_any_key;
  wire key_flash_3 = flashing[3] && cur_key == tile_key_r[3] && in_any_key;
  wire key_flash_4 = flashing[4] && cur_key == tile_key_r[4] && in_any_key;
  wire key_flash_5 = flashing[5] && cur_key == tile_key_r[5] && in_any_key;
  wire key_flash_6 = flashing[6] && cur_key == tile_key_r[6] && in_any_key;
  wire key_flash_7 = flashing[7] && cur_key == tile_key_r[7] && in_any_key;

  wire any_flash = key_flash_0 | key_flash_1 | key_flash_2 | key_flash_3 | key_flash_4 | key_flash_5 | key_flash_6 | key_flash_7;

  wire [15:0] flash_color =
       key_flash_0 ? timing_color(tile_timing[0]) :
       key_flash_1 ? timing_color(tile_timing[1]) :
       key_flash_2 ? timing_color(tile_timing[2]) :
       key_flash_3 ? timing_color(tile_timing[3]) :
       key_flash_4 ? timing_color(tile_timing[4]) :
       key_flash_5 ? timing_color(tile_timing[5]) :
       key_flash_6 ? timing_color(tile_timing[6]) :
       key_flash_7 ? timing_color(tile_timing[7]) :
       COLOR_KEY_FILL;


  assign pixel_data = in_tile ? COLOR_TILE : on_divider ? COLOR_BORDER : any_flash ? flash_color : in_any_key ? COLOR_KEY_FILL : COLOR_BLACK;
  wire any_tile_active;

  assign any_tile_active = tile_active[0] | tile_active[1] | tile_active[2] | tile_active[3] |
         tile_active[4] | tile_active[5] | tile_active[6] | tile_active[7];

  assign game_done = isDone && !any_tile_active;
endmodule
