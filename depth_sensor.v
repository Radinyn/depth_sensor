`timescale 1ns / 1ps

module depth_sensor(
    input CLK100MHZ,
    input SENSOR_ECHO,
    output reg SENSOR_TRIG,

    output reg LED17_B,

    output reg LED16_B,
    output reg LED16_G,
    output reg LED16_R,

    output int unsigned depth
    );
    
    int unsigned count = 0;
    int unsigned sending_count = 0;
    int unsigned depth_count = 0;
    int unsigned waiting_count = 0;
    int unsigned pending_count = 0;
     
    enum {WAITING, SENDING, PENDING, READING} state;
    
    always @ (posedge CLK100MHZ) begin
        count++;
        
        LED17_B <= (depth > 100);
        
        // 100 1MHz -> tick each us (10^-6s)
        if (count == 100) begin
                        
            LED16_B <= state == SENDING;
            LED16_G <= state == PENDING;
            LED16_R <= state == READING;    
                
            SENSOR_TRIG <= (state != SENDING);
            
            case (state)
                WAITING: begin
                    waiting_count++;
                    if (waiting_count > 100000) begin
                        waiting_count = 0;
                        state = state.next();
                    end
                end
            
                SENDING: begin
                                                
                        sending_count++;
                        
                        if (sending_count > 9) begin
                            sending_count = 0;
                            state = state.next();
                        end
                        
                    end
                    
                PENDING: begin
                        pending_count++;
                        if (SENSOR_ECHO == 1) begin
                            pending_count = 0;
                            state = state.next();
                        end else if (pending_count > 1000000) begin
                            pending_count = 0;
                            state = WAITING;
                        end 
                        
                    end
                
                READING: begin
                
                        if (SENSOR_ECHO == 0) begin
                        
                            depth = (depth_count * 34) / 2000;   
                            depth_count = 0;
                            state = state.next();                       
                        end else begin
                            depth_count += 1;
                        end
                    end
            endcase

            count = 0; 
        end 
            
    end    
    
endmodule
