module encode (
    input  [3:0]  in,
    output out1, out2, out3, out4, out5, out6, out7
);
    reg [6:0] out;
    always@(*)
    begin
        case (in)
        4'b0000: begin out = 7'b1000000; end
        4'b0001: begin out = 7'b1111001; end
        4'b0010: begin out = 7'b0100100; end
        4'b0011: begin out = 7'b0110000; end
        4'b0100: begin out = 7'b0011001; end
        4'b0101: begin out = 7'b0010010; end
        4'b0110: begin out = 7'b0000010; end
        4'b0111: begin out = 7'b1111000; end
        4'b1000: begin out = 7'b0000000; end
        4'b1001: begin out = 7'b0010000; end
        4'b1010: begin out = 7'b0001000; end
        4'b1011: begin out = 7'b0000011; end
        4'b1100: begin out = 7'b1000110; end
        4'b1101: begin out = 7'b0100001; end
        4'b1110: begin out = 7'b0000110; end
        4'b1111: begin out = 7'b0001110; end
        default: begin out = 7'b1111111; end
        endcase
    end
    
    assign {out7, out6, out5, out4, out3, out2, out1} = {out};
endmodule