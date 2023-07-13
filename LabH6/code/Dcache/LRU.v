module LRU (
    input clk, rstn,
    input hit1, hit2,
    input [4:0] index,
    input LRU_update,
    input LRU_change,
    output way_sel
);

reg [4:0] rec1 [0:31];
reg [4:0] rec2 [0:31];

integer i;
always@(posedge clk)
begin
    if(~rstn) begin
        for (i = 0; i < 32; i = i + 1) begin
            rec1[i] <= 0;
            rec2[i] <= 0;
        end
    end
    else begin
    if(LRU_update) begin
        if (~LRU_change) begin
            if(hit2) begin
                if(rec1[index] != 5'b11111);
                    rec1[index] <= rec1[index] + 1;
            end
            else if (hit1) begin
                if(rec2[index] != 5'b11111);
                    rec2[index] <= rec2[index] + 1;
            end  
        end  
    end
    else if(LRU_change) begin
        if(rec1[index] >= rec2[index])
            rec1[index] <= 0;
        else 
            rec2[index] <= 0;
    end
    end
end

assign way_sel = (rec1[index] >= rec2[index]) ? 0 : 1;



endmodule