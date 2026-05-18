module sample_player(
    input CLOCK_100MHZ,
    input reset,
    input start,
    input [4:0] TOTAL_NOTES,
    output reg [31:0] phase_inc_out,   // to DDS ? audio
    output reg [4:0]  note_id_out,     // which piano key ? to tile module  
    output reg        note_trigger,    // pulses when new note starts
    output reg        playing,          // 1 when song is running
    output reg isDone=0,
    output [15:0] LED
);
    
    // -------------------------------------------------------
    // TUNE THESE REGISTERS
    // -------------------------------------------------------
    // How fast tile falls: 64 pixels in 1 second
    // 1 second = 100_000_000 cycles, 64 pixels ? 1 pixel every 1_562_500 cycles
    localparam FALL_RATE_CYCLES = 32'd1_562_500;  // 1 pixel per 15.6ms
    


    // Total notes in your melody
    //localparam TOTAL_NOTES = 14;
    // -------------------------------------------------------

    reg [3:0]  note_counter   = 0;    // which note we are on (0 to TOTAL_NOTES-1)
    reg [31:0] duration_counter = 0;  // counts cycles for current note duration
    reg [31:0] current_duration = 0;  // latched duration in cycles for current note
    reg        load_next      = 0;    // wait 1 cycle for BRAM latency
    reg        running        = 0;

    // BRAM outputs
    wire [31:0] bram_phase_inc;
    wire [31:0] bram_duration;   // duration in ms, we convert to cycles below

    // Notes ROM: stores phase_inc values (e.g. 32'h015E864F for C4)
    piano_note_sample sample_note_inst (
        .clka(CLOCK_100MHZ),
        .ena(1'b1),
        .addra(note_counter),
        .douta(bram_phase_inc)
    );

    // Duration ROM: stores duration in ms (e.g. 500 for 0.5s, 1000 for 1s)
    melody_duration_sample sample_duration_inst (
        .clka(CLOCK_100MHZ),
        .ena(1'b1),
        .addra(note_counter),
        .douta(bram_duration)
    );

    // Convert ms ? clock cycles: 1ms = 100_000 cycles at 100MHz
    wire [31:0] duration_in_cycles = bram_duration * 32'd100_000;
    //wire [31:0] duration_in_cycles = bram_duration * 32'd1;

    always @(posedge CLOCK_100MHZ or posedge reset) begin
        if (reset) begin
            note_counter     <= 0;
            duration_counter <= 0;
            current_duration <= 0;
            running          <= 0;
            playing          <= 0;
            note_trigger     <= 0;
            phase_inc_out    <= 0;
            note_id_out      <= 0;
            load_next        <= 0;
            isDone <= 0;

        end else begin
            note_trigger <= 0;  // default low, only pulse for 1 cycle

            // Start song on start pulse
            if (start && !running) begin
                running      <= 1;
                playing      <= 1;
                note_counter <= 0;
                load_next    <= 1;  // trigger first BRAM read
            end

            // 1 cycle after address set, BRAM output is valid - latch it
            if (load_next) begin
                load_next        <= 0;
                current_duration <= duration_in_cycles;
                phase_inc_out    <= bram_phase_inc;
                note_id_out      <= note_counter;   // or use a separate note_id ROM
                note_trigger     <= 1;              // tell tile module to spawn
                duration_counter <= 0;
            end

            // Count duration of current note
            if (running && !load_next) begin
                if (duration_counter >= current_duration - 1) begin

                    if (note_counter == TOTAL_NOTES - 1) begin
                        // Song finished
                        running       <= 0;
                        playing       <= 0;
                        phase_inc_out <= 0;
                        note_counter  <= 0;
                        isDone <=1;
                    end else begin
                        // Advance to next note
                        note_counter <= note_counter + 1;
                        load_next    <= 1;  // wait 1 cycle for BRAM
                    end

                end else begin
                    duration_counter <= duration_counter + 1;
                end
            end
        end
    end

    assign LED= 16'b0 | (1'b1 << note_id_out);

endmodule
