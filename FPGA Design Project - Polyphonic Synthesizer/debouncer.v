`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2026 11:06:45 PM
// Design Name: 
// Module Name: debouncer
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


module debouncer_button(
    input clk,       // 100MHz clock
    input btn_in,    // Raw button input from hardware
    output btn_pulse // Single-cycle pulse output
);

    reg [19:0] count = 0;      // ~10ms delay at 100MHz
    reg btn_state = 0;         // Stable state of the button
    reg btn_prev = 0;          // Previous stable state for edge detection
    
    localparam THRESHOLD = 1_000_000; // 10ms @ 100MHz

    always @(posedge clk) begin
        // If the physical button matches our current stable state, reset counter
        if (btn_in == btn_state) begin
            count <= 0;
        end else begin
            // If it's different, start counting
            count <= count + 1;
            // If it stays different for 10ms, update our stable state
            if (count >= THRESHOLD) begin
                btn_state <= btn_in;
                count <= 0;
            end
        end
        
        // Save the previous state to detect the "Rising Edge"
        btn_prev <= btn_state;
    end

    // Output a pulse only when the stable state goes from 0 to 1
    assign btn_pulse = (btn_state == 1'b1 && btn_prev == 1'b0);

endmodule