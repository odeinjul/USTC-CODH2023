module switch_data (
    input clk, rstn, 
    input [3:0] h,
    input p,
    input btnr, btnc,
    output reg [32:0] tmp
);
always@(posedge clk)
begin
    if(~rstn || btnc) 
    begin
        tmp <= 0;
    end
    else if(p && !btnr)
    begin
        tmp <= (tmp << 4) + h; 
    end
    else if(!p && btnr)
    begin
        tmp <= tmp >> 4;
    end
end

endmodule