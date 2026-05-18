`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 24.03.2026 23:21:40
// Design Name:
// Module Name: test
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module test(
    input CLOCK_100MHZ,
    input BTNC,
    output [7:0] JC
  );

  wire [31:0] phase_inc_in;
  wire [4:0] note_id_out;
  wire note_trigger;
  wire playing;
  wire [15:0] LED;
  reg [4:0] TOTAL_NOTES = 14;
  wire isSampleDonePlaying;


  sample_player test_run (
                  .CLOCK_100MHZ(CLOCK_100MHZ),
                  .reset(BTNC),
                  .start(1),
                  .TOTAL_NOTES(TOTAL_NOTES),
                  .phase_inc_out(phase_inc_in),
                  .note_id_out(note_id_out),
                  .note_trigger(note_trigger),
                  .playing(playing),
                  .LED(LED),
                  .isDone(isSampleDonePlaying)
                );






  piano_oled piano_oled_inst (
               .CLOCK_100MHZ(CLOCK_100MHZ),
               .phase_inc_in(phase_inc_in),
               .isDone(isSampleDonePlaying),
               .note_trigger(note_trigger),
               .tile_speed(32'd1_562_500),     // 1 second to fall 64 pixels
               .JC(JC)

             );


   





endmodule
