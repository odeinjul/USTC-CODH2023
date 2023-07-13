module disp (
    //display to 8 7-segment display
    input clk, rstn,
    input [31:0] disp_data,
    output [6:0] seg,
    output reg [7:0] AN
);
reg [3:0] disp_temp;
encode encode_inst(
        .in(disp_temp),
        .out1(seg[0]),
        .out2(seg[1]),
        .out3(seg[2]),
        .out4(seg[3]),
        .out5(seg[4]),
        .out6(seg[5]),
        .out7(seg[6])
);
integer t;
    always @ (posedge clk)
    begin
    if(~rstn)
    t = 0;
    else begin
        if(t % 10 == 0)
        begin
            t = 0;
            case(AN)
                8'b11111110: begin AN <= 8'b11111101; disp_temp <= disp_data[7:4]; end
                8'b11111101: begin AN <= 8'b11111011; disp_temp <= disp_data[11:8]; end
                8'b11111011: begin AN <= 8'b11110111; disp_temp <= disp_data[15:12]; end
                8'b11110111: begin AN <= 8'b11101111; disp_temp <= disp_data[19:16]; end
                8'b11101111: begin AN <= 8'b11011111; disp_temp <= disp_data[23:20]; end
                8'b11011111: begin AN <= 8'b10111111; disp_temp <= disp_data[27:24]; end
                8'b10111111: begin AN <= 8'b01111111; disp_temp <= disp_data[31:28]; end
                8'b01111111: begin AN <= 8'b11111110; disp_temp <= disp_data[3:0]; end
                default: begin AN <= 8'b11111110; disp_temp <= disp_data[3:0]; end
           endcase
        end
        t = t + 1;
    end
    end
endmodule