`timescale 1ns / 1ps

module game_encouragement_tracker(
    input clk,
    input reset,
    input game_active,
    input game_start_pulse,
    input hit_event,
    input miss_event,
    output reg [1:0] encouragement_state
);

    localparam ENC_NONE      = 2'd0;
    localparam ENC_TRY_AGAIN = 2'd1;
    localparam ENC_KEEP_ITUP = 2'd2;
    localparam ENC_ON_FIRE   = 2'd3;

    localparam ONE_SEC_COUNT = 27'd100_000_000;

    reg [2:0] hit_streak;
    reg [1:0] miss_streak;
    reg [26:0] hold_counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            hit_streak <= 3'd0;
            miss_streak <= 2'd0;
            encouragement_state <= ENC_NONE;
            hold_counter <= 27'd0;
        end else if (game_start_pulse || !game_active) begin
            hit_streak <= 3'd0;
            miss_streak <= 2'd0;
            encouragement_state <= ENC_NONE;
            hold_counter <= 27'd0;
        end else begin
            if (hit_event) begin
                miss_streak <= 2'd0;

                if (hit_streak < 3'd7)
                    hit_streak <= hit_streak + 1'b1;
                else
                    hit_streak <= hit_streak;

                if ((hit_streak + 1'b1) >= 4) begin
                    encouragement_state <= ENC_ON_FIRE;
                    hold_counter <= ONE_SEC_COUNT - 1;
                end else if ((hit_streak + 1'b1) >= 2) begin
                    encouragement_state <= ENC_KEEP_ITUP;
                    hold_counter <= ONE_SEC_COUNT - 1;
                end
            end else if (miss_event) begin
                hit_streak <= 3'd0;

                if (miss_streak < 2'd3)
                    miss_streak <= miss_streak + 1'b1;
                else
                    miss_streak <= miss_streak;

                if ((miss_streak + 1'b1) >= 2) begin
                    encouragement_state <= ENC_TRY_AGAIN;
                    hold_counter <= ONE_SEC_COUNT - 1;
                end
            end else begin
                if (hold_counter != 0) begin
                    hold_counter <= hold_counter - 1'b1;
                end else begin
                    encouragement_state <= ENC_NONE;
                end
            end
        end
    end

endmodule