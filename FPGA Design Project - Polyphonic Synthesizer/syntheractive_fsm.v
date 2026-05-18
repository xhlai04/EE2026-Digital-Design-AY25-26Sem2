`timescale 1ns / 1ps

module syntheractive_fsm(
    input clk,
    input reset,
    input btnL_pulse,
    input btnR_pulse,
    input double_press_R,
    input out_stroke,
    input key_released,
    input [7:0] kb_scancode,
    input [10:0] captured_write_ptr,
    input pb_done,       // instrument playback done
    input game_done,     // piano hero game done

    output reg [4:0] state,
    output in_game_mode,
    output reg [1:0] in_instrument_mode
);

    localparam S_STARTUP                    = 5'd0,
               S_CHOOSE_MODE                = 5'd1,
               S_GAME_INFO                  = 5'd2,
               S_GAME_SWITCH_INFO           = 5'd3,
               S_COUNTDOWN_3                = 5'd4,
               S_COUNTDOWN_2                = 5'd5,
               S_COUNTDOWN_1                = 5'd6,
               S_GAME_START                 = 5'd7,
               S_GAME_PLAY                  = 5'd8,
               S_INSTRUMENT_INFO            = 5'd9,
               S_INSTRUMENT_SWITCH_INFO     = 5'd10,
               S_INSTRUMENT_IDLE            = 5'd11,
               S_INSTRUMENT_RECORD          = 5'd12,
               S_INSTRUMENT_NO_REC          = 5'd13,
               S_INSTRUMENT_REC_PAUSE       = 5'd14,
               S_INSTRUMENT_REC_DONE        = 5'd15,
               S_INSTRUMENT_PLAYBACK        = 5'd16,
               S_INSTRUMENT_PB_PAUSE        = 5'd17,
               S_INSTRUMENT_PB_DONE         = 5'd18,
               S_INSTRUMENT_CONFIRM_NEW_REC = 5'd19,
               S_INSTRUMENT_PB_REWIND       = 5'd20,
               S_GAME_OVER                  = 5'd21;

    localparam rec_button  = 8'h69, // numpad 1
               pb_button   = 8'h72, // numpad 2
               done_button = 8'h7A; // numpad 3

    localparam ONE_SEC_COUNT   = 29'd99_999_999;
    localparam THREE_SEC_COUNT = 29'd299_999_999;

    reg [4:0] next_state;
    reg [28:0] timer_count;

    wire one_sec_done;
    wire three_sec_done;

    assign one_sec_done   = (timer_count == ONE_SEC_COUNT);
    assign three_sec_done = (timer_count == THREE_SEC_COUNT);

    assign in_game_mode = (state == S_GAME_PLAY);

    // =========================================================
    // State register
    // =========================================================
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= S_STARTUP;
        else
            state <= next_state;
    end

    // =========================================================
    // Timer
    // Reset timer immediately when changing state
    // =========================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            timer_count <= 29'd0;
        end else if (next_state != state) begin
            timer_count <= 29'd0;
        end else begin
            case (state)
                // 3-second timed states
                S_STARTUP,
                S_GAME_INFO,
                S_GAME_SWITCH_INFO,
                S_GAME_OVER,
                S_INSTRUMENT_INFO,
                S_INSTRUMENT_SWITCH_INFO,
                S_INSTRUMENT_NO_REC: begin
                    if (!three_sec_done)
                        timer_count <= timer_count + 1'b1;
                end

                // 1-second timed states
                S_COUNTDOWN_3,
                S_COUNTDOWN_2,
                S_COUNTDOWN_1,
                S_GAME_START,
                S_INSTRUMENT_REC_DONE,
                S_INSTRUMENT_PB_DONE,
                S_INSTRUMENT_PB_REWIND: begin
                    if (!one_sec_done)
                        timer_count <= timer_count + 1'b1;
                end

                default: begin
                    timer_count <= 29'd0;
                end
            endcase
        end
    end

    // =========================================================
    // Instrument mode output
    // 00 = not in instrument mode
    // 01 = instrument live/record mode
    // 10 = instrument playback mode
    // =========================================================
    always @(*) begin
        in_instrument_mode = 2'b00;

        if (state == S_INSTRUMENT_IDLE || state == S_INSTRUMENT_RECORD || state == S_INSTRUMENT_REC_PAUSE)
            in_instrument_mode = 2'b01;
        else if (state == S_INSTRUMENT_PLAYBACK || state == S_INSTRUMENT_PB_PAUSE)
            in_instrument_mode = 2'b10;
    end

    // =========================================================
    // Next-state logic
    // =========================================================
    always @(*) begin
        next_state = state;

        case (state)
            S_STARTUP: begin
                if (three_sec_done)
                    next_state = S_CHOOSE_MODE;
            end

            S_CHOOSE_MODE: begin
                if (btnL_pulse)
                    next_state = S_GAME_INFO;
                else if (btnR_pulse)
                    next_state = S_INSTRUMENT_INFO;
            end

            S_GAME_INFO: begin
                if (three_sec_done)
                    next_state = S_GAME_SWITCH_INFO;
            end

            S_GAME_SWITCH_INFO: begin
                if (three_sec_done)
                    next_state = S_COUNTDOWN_3;
            end

            S_COUNTDOWN_3: begin
                if (one_sec_done)
                    next_state = S_COUNTDOWN_2;
            end

            S_COUNTDOWN_2: begin
                if (one_sec_done)
                    next_state = S_COUNTDOWN_1;
            end

            S_COUNTDOWN_1: begin
                if (one_sec_done)
                    next_state = S_GAME_START;
            end

            S_GAME_START: begin
                if (one_sec_done)
                    next_state = S_GAME_PLAY;
            end

            S_GAME_PLAY: begin
                if (game_done)
                    next_state = S_GAME_OVER;
                else if (double_press_R)
                    next_state = S_CHOOSE_MODE;
            end

            S_GAME_OVER: begin
                if (three_sec_done)
                    next_state = S_CHOOSE_MODE;
            end

            S_INSTRUMENT_INFO: begin
                if (three_sec_done)
                    next_state = S_INSTRUMENT_SWITCH_INFO;
            end

            S_INSTRUMENT_SWITCH_INFO: begin
                if (three_sec_done)
                    next_state = S_INSTRUMENT_IDLE;
            end

            S_INSTRUMENT_IDLE: begin
                if (double_press_R)
                    next_state = S_CHOOSE_MODE;
                else if (out_stroke && !key_released && kb_scancode == rec_button) begin
                    if (captured_write_ptr > 0)
                        next_state = S_INSTRUMENT_CONFIRM_NEW_REC;
                    else
                        next_state = S_INSTRUMENT_RECORD;
                end else if (out_stroke && !key_released && kb_scancode == pb_button) begin
                    if (captured_write_ptr == 0)
                        next_state = S_INSTRUMENT_NO_REC;
                    else
                        next_state = S_INSTRUMENT_PLAYBACK;
                end
            end

            S_INSTRUMENT_NO_REC: begin
                if (three_sec_done)
                    next_state = S_INSTRUMENT_IDLE;
            end

            S_INSTRUMENT_CONFIRM_NEW_REC: begin
                if (out_stroke && !key_released && kb_scancode == rec_button)
                    next_state = S_INSTRUMENT_RECORD;
                else if (out_stroke && !key_released && kb_scancode == done_button)
                    next_state = S_INSTRUMENT_IDLE;
            end

            S_INSTRUMENT_RECORD: begin
                if (out_stroke && !key_released && kb_scancode == rec_button)
                    next_state = S_INSTRUMENT_REC_PAUSE;
                else if (out_stroke && !key_released && kb_scancode == done_button)
                    next_state = S_INSTRUMENT_REC_DONE;
            end

            S_INSTRUMENT_REC_PAUSE: begin
                if (out_stroke && !key_released && kb_scancode == rec_button)
                    next_state = S_INSTRUMENT_RECORD;
                else if (out_stroke && !key_released && kb_scancode == done_button)
                    next_state = S_INSTRUMENT_REC_DONE;
            end

            S_INSTRUMENT_REC_DONE: begin
                if (one_sec_done)
                    next_state = S_INSTRUMENT_IDLE;
            end

            S_INSTRUMENT_PLAYBACK: begin
                if (pb_done)
                    next_state = S_INSTRUMENT_PB_DONE;
                else if (out_stroke && !key_released && kb_scancode == pb_button)
                    next_state = S_INSTRUMENT_PB_PAUSE;
                else if (out_stroke && !key_released && kb_scancode == done_button)
                    next_state = S_INSTRUMENT_PB_DONE;
            end

            S_INSTRUMENT_PB_PAUSE: begin
                if (out_stroke && !key_released && kb_scancode == pb_button)
                    next_state = S_INSTRUMENT_PLAYBACK;
                else if (out_stroke && !key_released && kb_scancode == done_button)
                    next_state = S_INSTRUMENT_PB_REWIND;
            end

            S_INSTRUMENT_PB_REWIND: begin
                if (one_sec_done)
                    next_state = S_INSTRUMENT_PLAYBACK;
            end

            S_INSTRUMENT_PB_DONE: begin
                if (one_sec_done)
                    next_state = S_INSTRUMENT_IDLE;
            end

            default: begin
                next_state = S_STARTUP;
            end
        endcase
    end

endmodule