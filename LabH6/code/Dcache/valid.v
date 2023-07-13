module valid (
    input clk, rstn,
    input [4:0] index,
    input way_sel, valid_write,
    output [1:0] valid
);
reg [1:0] valid_reg [0:31];

integer i;
always@(posedge clk)
begin
    if(~rstn) begin
        for(i = 0; i < 32; i = i + 1) begin
            valid_reg[i] <= 2'b0;
        end
    end
    else begin
        if(valid_write) begin
            if(way_sel) 
                valid_reg[index] <= valid_reg[index] | 2'b10;
            else 
                valid_reg[index] <= valid_reg[index] | 2'b01;
        end
    end
end

assign valid = valid_reg[index];
endmodule