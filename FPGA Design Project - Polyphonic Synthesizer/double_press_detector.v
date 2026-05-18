`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2026 11:15:37 PM
// Design Name: 
// Module Name: double_press_detector
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


module double_press_detector (
    input clk,               // 100MHz
    input btn_pulse,         // Input from the DEBOUNCER pulse
    output reg double_press  // Output pulse on successful double click
);

    // Timer: 0.5 seconds at 100MHz = 50,000,000 cycles
    localparam TIMER_LIMIT = 50_000_000; 
    
    reg [25:0] timer = 0;
    reg [1:0] state = 0;
    
    localparam S_IDLE    = 2'd0,
               S_WAIT    = 2'd1,
               S_TRIGGER = 2'd2;

    always @(posedge clk) begin
        double_press <= 0; // Default: no pulse
        
        case (state)
            S_IDLE: begin
                timer <= 0;
                if (btn_pulse) state <= S_WAIT;
            end
            
            S_WAIT: begin
                if (timer < TIMER_LIMIT) begin
                    timer <= timer + 1;
                    if (btn_pulse) state <= S_TRIGGER;
                end else begin
                    state <= S_IDLE; // Timeout
                end
            end
            
            S_TRIGGER: begin
                double_press <= 1; // Send the double press pulse
                state <= S_IDLE;
            end
            
            default: state <= S_IDLE;
        endcase
    end
endmodule
