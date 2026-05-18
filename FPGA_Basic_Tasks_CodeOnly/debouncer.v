`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/10/2026 04:30:58 PM
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


module debouncer (
    input clock,
    input raw_press, //raw input; bouncing everywhere
    output reg crisp_press //lasts for one cycle only if 1 so long press as just one pres
);
    reg syning0, syning1;
    reg [24:0] counter = 0;
    reg previous_bstate = 0; //for comparing current button state to previous one to detect exact moment button is pushed down
    reg countingNOW = 0; //locking in on counting

    always @(posedge clock) begin
        syning0 <= raw_press;
        syning1 <= syning0;
        
        crisp_press <= 0;
        if (!countingNOW) begin //if not in any 200ms waiting period
            if (syning1 && !previous_bstate) begin
                crisp_press <= 1;    // Detect initial press
                countingNOW <= 1;  // Start counting of 200ms
                counter <= 0;
            end
        end else begin
            if (counter < 20000000) begin //focusing on counting 200ms
                counter <= counter + 1;
            end else if (!syning1) begin 
                countingNOW <= 0;  // reset only button not pressed and after 200ms waiting time 
            end
        end
        previous_bstate <= syning1;
    end
endmodule
