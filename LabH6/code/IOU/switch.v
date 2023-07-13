module switch (
    input clk, rstn,
    input [15:0] sw,
    output reg [3:0] h,
    output reg p
);

reg [15:0] cnt;
reg en1, en2;
reg [15:0] in;
reg [15:0] tmp;
wire test;
assign test = tmp ^ sw;

//  every time a switch is changed, return its corresponding number and set p to valid
always@(posedge clk)
begin
    if (~rstn)begin
        cnt <= 0;
        en1 <= 0;
        en2 <= 0;
        tmp <= 0;
    end
    else begin
        if (tmp == sw)
            cnt <= 0;
        else if (cnt < 16'h20)
            cnt <= cnt + 1;
        en1 <= cnt[5];
        en2 <= en1;
        if (en1 & ~en2)
        begin
            tmp <= sw;
            in <= tmp^sw;
        end
        p <= en1 & ~en2;
    end
end



//  encode the switch number
always@(*)
begin
    case (in)
        16'b1000000000000000: h = 4'hf;
        16'b0100000000000000: h = 4'he;
        16'b0010000000000000: h = 4'hd;
        16'b0001000000000000: h = 4'hc;
        16'b0000100000000000: h = 4'hb;
        16'b0000010000000000: h = 4'ha;
        16'b0000001000000000: h = 4'h9;
        16'b0000000100000000: h = 4'h8;
        16'b0000000010000000: h = 4'h7;
        16'b0000000001000000: h = 4'h6;
        16'b0000000000100000: h = 4'h5;
        16'b0000000000010000: h = 4'h4;
        16'b0000000000001000: h = 4'h3;
        16'b0000000000000100: h = 4'h2;
        16'b0000000000000010: h = 4'h1;
        16'b0000000000000001: h = 4'h0;   
    endcase
end


endmodule