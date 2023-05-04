`timescale 1ns / 1ps
`include "display.v"
`include "depth_sensor.v"


module top(
    input CLK100MHZ,
    input SENSOR_ECHO,
        
    output reg LED17_B,
    output reg LED17_G,
    output reg LED17_R,
    
    output reg LED16_B,
    output reg LED16_G,
    output reg LED16_R,
    
    output reg LED[0:15],
    
    output reg[0:7] CT,
    output reg AN[7:0],
    
    output reg SENSOR_TRIG
    );
    
    int unsigned depth;
    
    display DISPLAY(
        .CLK100MHZ(CLK100MHZ),
        .N(depth),
        .CT(CT),
        .AN(AN)
    );
    
    depth_sensor DEPTH_SENSOR(
        .CLK100MHZ(CLK100MHZ),
        .LED16_B(LED16_B),
        .LED16_G(LED16_G),
        .LED16_R(LED16_R),
        .LED17_B(LED17_B),
        .SENSOR_ECHO(SENSOR_ECHO),
        .SENSOR_TRIG(SENSOR_TRIG),
        .depth(depth)
    );
    
    byte unsigned count = 0;
    int unsigned count_inner = 0;
        
    always @ (posedge CLK100MHZ) begin
        
        count_inner += 1;
        
        // 100 -> 1MHz
        // 000 -> 1KHz
        // 00 -> 10Hz
        if (count_inner % 100_000_00 == 0) begin
            count += 1;
            
            if (count_inner > 100_000_00) begin
                count_inner = 0;
            end
        end
                
        if (count > 16)
            count = 0;
                    
        for (int i = 0; i < 16; i++)
            LED[i] <= (depth >= i) ? 1 : 0;
            
    end

endmodule
