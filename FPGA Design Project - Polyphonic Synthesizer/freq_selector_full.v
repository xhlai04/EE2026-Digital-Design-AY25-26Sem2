`timescale 1ns / 1ps
module freq_selector_full(
    input        note_on,
    input  [4:0] note_index,
    output reg [31:0] phase_inc        // widened from 24 to 32 bits
);
    // Recalculated: M = (Freq * 2^32) / 48828
    localparam C4  = 32'd22992207,  Cs4 = 32'd24360792;
    localparam D4  = 32'd25809568,  Ds4 = 32'd27340775;
    localparam E4  = 32'd28960015,  F4  = 32'd30671457;
    localparam Fs4 = 32'd32479813,  G4  = 32'd34390380;
    localparam Gs4 = 32'd36409157,  A4  = 32'd38542650;
    localparam As4 = 32'd40796872,  B4  = 32'd43178365;
    localparam C5  = 32'd45984414,  Cs5 = 32'd48721584;
    localparam D5  = 32'd51619136,  Ds5 = 32'd54681550;
    localparam E5  = 32'd57920030,  F5  = 32'd61342914;
    localparam Fs5 = 32'd64959626,  G5  = 32'd68780760;
    localparam Gs5 = 32'd72818314,  A5  = 32'd77085300;
    localparam As5 = 32'd81593744,  B5  = 32'd86356730;
    localparam C6  = 32'd91968828;

    always @(*) begin
        if (!note_on) phase_inc = 32'd0;
        else begin
            case(note_index)
                5'd0:  phase_inc = C4;   5'd1:  phase_inc = Cs4;
                5'd2:  phase_inc = D4;   5'd3:  phase_inc = Ds4;
                5'd4:  phase_inc = E4;   5'd5:  phase_inc = F4;
                5'd6:  phase_inc = Fs4;  5'd7:  phase_inc = G4;
                5'd8:  phase_inc = Gs4;  5'd9:  phase_inc = A4;
                5'd10: phase_inc = As4;  5'd11: phase_inc = B4;
                5'd12: phase_inc = C5;   5'd13: phase_inc = Cs5;
                5'd14: phase_inc = D5;   5'd15: phase_inc = Ds5;
                5'd16: phase_inc = E5;   5'd17: phase_inc = F5;
                5'd18: phase_inc = Fs5;  5'd19: phase_inc = G5;
                5'd20: phase_inc = Gs5;  5'd21: phase_inc = A5;
                5'd22: phase_inc = As5;  5'd23: phase_inc = B5;
                5'd24: phase_inc = C6;
                default: phase_inc = C4;
            endcase
        end
    end
endmodule