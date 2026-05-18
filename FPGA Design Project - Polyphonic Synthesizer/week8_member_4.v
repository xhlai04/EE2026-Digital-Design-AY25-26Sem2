module week8_member_4(
    input  CLOCK_100MHZ,
    input  BTNC, BTNU, BTNR, BTND, BTNL,
    input  PS2Clk,
    input  PS2Data,
    input  [15:0] SW,
    output [7:0] JA,   // Pmod DA2 (Audio Output)
    output [7:0] JB,   // Pmod OLED (UI/Status Display)
    output [7:0] JC,   // Pmod OLED (Waveform/Game Display)
    output [15:0] LED,
    output [7:0] SEG,
    output [3:0] AN
  );

  // =====================================================
  // 1. INTERNAL WIRES & PARAMETERS
  // =====================================================
  localparam PLAYBACKSPEED = 1;
  localparam [31:0] TILE_SPEED_VAL = 32'd1_562_500;

  // Audio & Recording Wires
  wire [11:0] wave_out;
  wire [10:0] write_ptr, read_ptr, max_read_ptr;
  wire buffer_full;
  wire [15:0] out_keycode;
  wire out_stroke;
  wire [7:0] pb_scancode;

  // UI & Control Wires
  wire [4:0]  current_fsm_state;
  wire [1:0]  instrument_mode;
  wire [31:0] SCALE_X_wire;
  reg  [31:0] SCALE_X = 10;

  // Game/Piano Wires
  wire [7:0]  piano_hero_scancode;
  wire [31:0] piano_hero_scancode_bus;
  wire [3:0]  piano_hero_note_bus;
  wire        piano_trigger_output;
  wire        pb_isDone;
  wire        game_done;   // NEW

  // OLED Interconnects
  wire        clk6_25mhz;
  wire [12:0] pixel_index_jb;
  wire [15:0] pixel_data_jb;
  wire [7:0]  JC_waveform_oled, JC_piano_tiles;

  wire [15:0] score_counter;
  wire [15:0] pianohero_score_input;
  assign pianohero_score_input = score_counter;

  wire key_released = (out_keycode[15:8] == 8'hF0);

  // LED Connections
  wire [15:0] synth_leds;
  wire hit_event;
  wire miss_event;
  wire [1:0] encouragement_state;

  // =====================================================
  // 2. INPUT PROCESSING (Debouncing & Logic)
  // =====================================================
  wire db_btnL, db_btnR, db_btnC, db_btnD, db_btnU, double_R_pulse;

  debouncer_button db_L (.clk(CLOCK_100MHZ), .btn_in(BTNL), .btn_pulse(db_btnL));
  debouncer_button db_R (.clk(CLOCK_100MHZ), .btn_in(BTNR), .btn_pulse(db_btnR));
  debouncer_button db_D (.clk(CLOCK_100MHZ), .btn_in(BTND), .btn_pulse(db_btnD));
  debouncer_button db_C (.clk(CLOCK_100MHZ), .btn_in(BTNC), .btn_pulse(db_btnC));

  double_press_detector dp_R (
                          .clk(CLOCK_100MHZ),
                          .btn_pulse(db_btnR),
                          .double_press(double_R_pulse)
                        );

  // =====================================================
  // 3. CORE AUDIO & FSM ENGINE
  // =====================================================
  music_top audio_inst(
              .clk(CLOCK_100MHZ),

              .btnC(db_btnC),
              .btnD(db_btnD),
              .btnL(db_btnL),
              .btnR(db_btnR),
              .double_press_R(double_R_pulse),
              .TILE_SPEED_VAL(TILE_SPEED_VAL),
              .PLAYBACKSPEED(PLAYBACKSPEED),
              .current_fsm_state_out(current_fsm_state),
              .piano_hero_score_counter(pianohero_score_input),
              .sw(SW),
              .PS2Clk(PS2Clk),
              .PS2Data(PS2Data),
              .game_done(game_done),   // NEW

              .JC(JC),
              .JA(JA),
              .led(synth_leds),
              .seg(SEG),
              .an(AN),
              .mixed_audio(wave_out),

              .buffer_full_out(buffer_full),
              .addra_out(write_ptr),
              .addrb_out(read_ptr),
              .max_ptr_out(max_read_ptr),

              .piano_hero_scancode_out(piano_hero_scancode),
              .piano_hero_scancode_bus_out(piano_hero_scancode_bus),
              .piano_hero_note_bus_out(piano_hero_note_bus),
              .piano_hero_trigger(piano_trigger_output),
              .pb_finished_wire(pb_isDone),
              .pb_scancode(pb_scancode),
              .out_stroke(out_stroke),
              .out_keycode(out_keycode)
            );

  // =====================================================
  // 4. DISPLAY UNIT JB (Status, Record, Playback UI)
  // =====================================================
  clk6p25m oled_clk_gen (
             .clk(CLOCK_100MHZ),
             .clk6p25m(clk6_25mhz)
           );

  display_controller main_display(
                       .clk(CLOCK_100MHZ),
                       .state(current_fsm_state),
                       .pixel_index(pixel_index_jb),
                       .write_ptr(write_ptr),
                       .read_ptr(read_ptr),
                       .max_read_ptr(max_read_ptr),
                       .buffer_full(buffer_full),
                       .encouragement_state(encouragement_state),
                       .pixel_data(pixel_data_jb)
                     );

  Oled_Display oled_driver_jb (
                 .clk(clk6_25mhz),
                 .reset(BTNC),
                 .pixel_index(pixel_index_jb),
                 .pixel_data(pixel_data_jb),
                 .cs(JB[0]), .sdin(JB[1]), .sclk(JB[3]), .d_cn(JB[4]),
                 .resn(JB[5]), .vccen(JB[6]), .pmoden(JB[7])
               );

  // =====================================================
  // 5. DISPLAY UNIT JC (Waveform vs Piano Hero Game)
  // =====================================================
  updated_waveform_oled waveform_disp(
                          .CLOCK_100MHZ(CLOCK_100MHZ),
                          .scale_x(SCALE_X),
                          .y_val(wave_out),
                          .JC(JC_waveform_oled)
                        );

  wire pianoGameStart_from;

  // Detect transition to state 8 for pulse generation
  reg [4:0] prev_fsm_state = 5'd0;
  reg pianoGameStart_pulse = 1'b0;

  always @(posedge CLOCK_100MHZ)
  begin
    prev_fsm_state <= current_fsm_state;
    pianoGameStart_pulse <= (current_fsm_state == 5'd8) && (prev_fsm_state != 5'd8);
  end

  assign pianoGameStart_from = pianoGameStart_pulse;

  // Screen B: Piano Hero Tiles
  piano_oled piano_hero_disp_inst(
               .CLOCK_100MHZ(CLOCK_100MHZ),
               .scancode_bus_in(piano_hero_scancode_bus),
               .note_on_bus_in(piano_hero_note_bus),
               .kb_scancode(out_keycode[7:0]),
               .out_stroke(out_stroke),
               .key_released(key_released),
               .isDone(pb_isDone),
               .note_trigger(piano_trigger_output),
               .tile_speed(TILE_SPEED_VAL),
               .pianoGameStart(pianoGameStart_from),
               .JC(JC_piano_tiles),
               .SCORE_COUNTER(score_counter),
               .hit_event(hit_event),
               .miss_event(miss_event),
               .game_done(game_done)   // NEW
             );

  game_encouragement_tracker encouragement_tracker_inst(
                               .clk(CLOCK_100MHZ),
                               .reset(BTNC),
                               .game_active(current_fsm_state == 5'd8),
                               .game_start_pulse(pianoGameStart_from),
                               .hit_event(hit_event),
                               .miss_event(miss_event),
                               .encouragement_state(encouragement_state)
                             );

  wire [7:0] JC_blackcolor_oled;

  default_black_oled_display default_black_oled_display_inst (
                               .CLOCK_100MHZ(CLOCK_100MHZ),
                               .JC(JC_blackcolor_oled)
                             );

  // Switch between Game and Instrument waveform based on FSM states
  assign JC = (current_fsm_state == 5'd8) ? JC_piano_tiles :
         ((current_fsm_state >= 5'd11) && (current_fsm_state <= 5'd20)) ? JC_waveform_oled :
         JC_blackcolor_oled;

  // =====================================================
  // 6. SYSTEM EXTRAS (LEDs & Boot Sequence)
  // =====================================================
  wire booting_active;

  startup_sequencer boot_up_display (
                      .clk(CLOCK_100MHZ),
                      .rst(BTNC),
                      .leds_from_music(synth_leds),
                      .led_out(LED),
                      .is_booting(booting_active)
                    );

  assign SEG[7] = 1'b1; // turn off the dp

endmodule
