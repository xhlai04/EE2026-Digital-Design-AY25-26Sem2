`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: 
//  STUDENT B NAME:
//  STUDENT C NAME: 
//  STUDENT D NAME:  
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Student (input CLK, input[4:0] btn, input[15:0] sw,
                    output[7:0] JX, output[6:0] seg, output [3:0] an, output dp);
                    
    //CLK = clk100m
    
    wire clk6p25m;
    wire RST;
    reg[15:0] oled_data;
    wire[15:0] oled_data_S;
    wire[15:0] oled_data_P;
    wire[15:0] oled_data_Q;
    wire[15:0] oled_data_R;
    wire[12:0] pixel_index;
    wire sample_pixel;
    
    assign JX[2] = 0;
    
    clk6p25m fa0 (CLK, clk6p25m);
    oled_data_S fa1 (pixel_index, btn[2], btn[3], clk6p25m, oled_data_S);
    oled_data_P fa2 (pixel_index, btn[1], clk6p25m, CLK, oled_data_P);
    oled_data_Q fa3 (pixel_index, CLK, btn[4], oled_data_Q);
    oled_data_R fa4 (pixel_index, sw, clk6p25m, CLK, sample_pixel, oled_data_R);
    
    segment_display fa6 (CLK, an, seg, dp);
    
    Oled_Display fa5 (clk6p25m, RST, , , sample_pixel ,pixel_index, oled_data, 
                      JX[0], JX[1], JX[3], JX[4], JX[5], JX[6], JX[7]);   
                      
 always @(*) begin 
                      
                                  if (sw[15]) begin 
                                      oled_data = oled_data_S;
                                  end 
                                  else if (sw[14]) begin            
                                      oled_data = oled_data_R;
                                  end 
                                  else if (sw[13]) begin           
                                      oled_data = oled_data_Q;
                                  end
                                    else if (sw[12]) begin           
                                      oled_data = oled_data_P;
                                  end
                                  else  begin
                                      oled_data = 16'h0000;
                                  end
                              end
    
endmodule