`timescale 1ns / 1ps
module digit_draw(
    input  [6:0] x,
    input  [5:0] y,
    input  [6:0] x0,
    input  [5:0] y0,
    input  [3:0] digit,
    input  [6:0] w,
    input  [5:0] h,
    input  [3:0] t,
    output       pixel_on
);
    // Pre-compute all segment boundaries as wide wires to prevent overflow
    wire [7:0] x1      = x0 + w;        // right edge
    wire [7:0] xlt     = x0 + t;        // left bar right edge
    wire [7:0] xrl     = x0 + w - t;    // right bar left edge

    wire [7:0] y1      = y0 + h;        // bottom edge
    wire [7:0] yt      = y0 + t;        // top bar bottom edge
    wire [7:0] ymid    = y0 + h/2;      // vertical midpoint
    wire [7:0] yml     = ymid - t/2;    // mid bar top edge
    wire [7:0] ymh     = ymid + t/2;    // mid bar bottom edge
    wire [7:0] ybl     = y1 - t;        // bottom bar top edge

    // Horizontal segments
    wire seg_top = (y >= y0)  && (y < yt)   && (x >= x0) && (x < x1);
    wire seg_mid = (y >= yml) && (y < ymh)  && (x >= x0) && (x < x1);
    wire seg_bot = (y >= ybl) && (y < y1)   && (x >= x0) && (x < x1);

    // Vertical segments
    wire seg_tl  = (x >= x0)  && (x < xlt) && (y >= y0)   && (y < ymid); // top-left
    wire seg_bl  = (x >= x0)  && (x < xlt) && (y >= ymid) && (y < y1);   // bot-left
    wire seg_tr  = (x >= xrl) && (x < x1)  && (y >= y0)   && (y < ymid); // top-right
    wire seg_br  = (x >= xrl) && (x < x1)  && (y >= ymid) && (y < y1);   // bot-right

    // 7-segment truth table
    //        seg: top mid bot  tl  bl  tr  br
    // 0:           1   0   1   1   1   1   1
    // 1:           0   0   0   0   0   1   1
    // 2:           1   1   1   0   1   1   0
    // 3:           1   1   1   0   0   1   1
    // 4:           0   1   0   1   0   1   1
    // 5:           1   1   1   1   0   0   1
    // 6:           1   1   1   1   1   0   1
    // 7:           1   0   0   0   0   1   1
    // 8:           1   1   1   1   1   1   1
    // 9:           1   1   1   1   0   1   1

    reg pixel_on_r;
    always @(*) begin
        case (digit)
            4'd0: pixel_on_r = seg_top |            seg_bot | seg_tl | seg_bl | seg_tr | seg_br;
            4'd1: pixel_on_r =                                                   seg_tr | seg_br;
            4'd2: pixel_on_r = seg_top | seg_mid | seg_bot |          seg_bl | seg_tr;
            4'd3: pixel_on_r = seg_top | seg_mid | seg_bot |                   seg_tr | seg_br;
            4'd4: pixel_on_r =           seg_mid |           seg_tl |           seg_tr | seg_br;
            4'd5: pixel_on_r = seg_top | seg_mid | seg_bot | seg_tl |                   seg_br;
            4'd6: pixel_on_r = seg_top | seg_mid | seg_bot | seg_tl | seg_bl |          seg_br;
            4'd7: pixel_on_r = seg_top |                                        seg_tr | seg_br;
            4'd8: pixel_on_r = seg_top | seg_mid | seg_bot | seg_tl | seg_bl | seg_tr | seg_br;
            4'd9: pixel_on_r = seg_top | seg_mid | seg_bot | seg_tl |           seg_tr | seg_br;
            default: pixel_on_r = 0;
        endcase
    end

    assign pixel_on = pixel_on_r;

endmodule