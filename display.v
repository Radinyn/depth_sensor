`timescale 1ns / 1ps

module display(
    input CLK100MHZ,
    input int unsigned N,
    output reg[0:7] CT,
    output reg AN[7:0]
    );
        
    byte unsigned digit_index = 0;
    
    int unsigned count = 0;

    const byte ERR = 10;
    logic[7:0][7:0] text = '{ERR, ERR, ERR, ERR, ERR, ERR, ERR, ERR};
                
    function logic[7:0][7:0] num_to_digits(input int unsigned num);
        automatic logic[7:0][7:0] out = '{ERR, ERR, ERR, ERR, ERR, ERR, ERR, ERR};
        
        for (int i = 0; i < 8; i++) begin
            if (num > 0) begin
                out[i] = num % 10;
                num /= 10;
            end else begin
                out[i] = ERR;
            end
        end
        
        return out;
    endfunction
    
    function logic[7:0] digit_to_7seg(input byte unsigned digit);
        case (digit)
            0: return 8'b00000011;
            1: return 8'b10011111;
            2: return 8'b00100101;
            3: return 8'b00001101;
            4: return 8'b10011001;
            5: return 8'b01001001;
            6: return 8'b01000001;
            7: return 8'b00011111;
            8: return 8'b00000001;
            9: return 8'b00001001;
            default: return 8'b11111111;
        endcase
    endfunction
    
    always @ (posedge CLK100MHZ) begin
        count += 1;
                
        if (count == 10000) begin
            text = num_to_digits(N);
            digit_index = (digit_index + 1)%8;
            count = 0; 
        end 
            
        AN[(digit_index-1+8)%8] = 1;
        CT = digit_to_7seg(text[digit_index%8]);
        AN[digit_index] = 0;
            
    end

    
endmodule
