module dirty (
    input clk, rstn,
    input [4:0] index,
    
    input hit1, hit2,
    input dty_write,

    input way_sel,
    input [1:0] dty_clear,
    
    output dirty
);
reg [1:0] dirty_reg [0:31];
integer i;

always@(posedge clk)
begin
    if(~rstn) begin
        for (i = 0; i < 32; i = i + 1) begin
            dirty_reg[i] <= 2'b0;
        end
    end
    else begin
        if(dty_write) begin
            if(hit1)
                dirty_reg[index] <= dirty_reg[index] | 2'b01;
            else if(hit2)
                dirty_reg[index] <= dirty_reg[index] | 2'b10;
        end
        else if(dty_clear == 1) begin
            case(way_sel)
                0: dirty_reg[index] <= dirty_reg[index] & 2'b10;
                1: dirty_reg[index] <= dirty_reg[index] & 2'b01;
            endcase
        end
        else if(dty_clear == 2) begin
            case(way_sel)
                0: dirty_reg[index] <= dirty_reg[index] | 2'b01;
                1: dirty_reg[index] <= dirty_reg[index] | 2'b10;
            endcase
        end
    end
end

assign dirty = dirty_reg[index][way_sel];

endmodule