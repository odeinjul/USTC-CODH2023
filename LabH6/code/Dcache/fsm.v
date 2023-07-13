module fsm (
    input clk, rstn,
    input hit1, hit2,
    input r_valid, w_valid,
    input dr_ready, dw_ready,

    input [7:0] addr,
    input way_sel,
    input dirty, 
    input [1:0] valid,

    output reg dr_valid, dw_valid,
    output reg mem_we1, mem_we2,
    output reg tag_we1, tag_we2,

    output reg dty_write, valid_write,
    output reg [1:0] dty_clear,

    output reg LRU_update, LRU_change,

    output reg data_from_mem, w_data_sel,
    output reg r_ready, w_ready
);

parameter IDLE = 3'b000;
parameter WRITE_BACK = 3'b001;
parameter FETCH = 3'b010;
parameter FINISH = 3'b011;
parameter DELAY = 3'b100;


reg [2:0] state;

wire hit;
assign hit = hit1 || hit2;

always@(posedge clk)
begin
    if(~rstn)
    begin
        state <= IDLE;
        data_from_mem <= 0;
        w_data_sel <= 0;
        LRU_update <= 0;
        LRU_change <= 0;
        dty_clear <= 0;
        dty_write <= 0;
        valid_write <= 0;
        mem_we1 <= 0;
        mem_we2 <= 0;
        tag_we1 <= 0;
        tag_we2 <= 0;
    end
    else
    begin
        case (state) 
        IDLE: begin
            if (w_valid || r_valid) begin 
                if (hit) begin //stay IDLE
                    //更新 LRU
                    LRU_change <= 0;
                    LRU_update <= 1;
                    if(w_valid) begin
                        w_data_sel <= 0; // w_data_write = (w_word + r_data)
                        dty_write <= 1;
                        w_ready <= 1;
                        r_ready <= 0;
                        if(hit1) begin 
                            mem_we1 <= 1;
                            tag_we1 <= 0;
                        end
                        else if (hit2) begin 
                            mem_we2 <= 1;
                            tag_we2 <= 0;
                        end
                        state <= FINISH;
                    end
                    else if(r_valid) begin 
                        data_from_mem <= 0;
                        dty_write <= 0;
                        r_ready <= 1;
                        w_ready <= 0;
                        valid_write <= 0;
                        mem_we1 <= 0;
                        mem_we2 <= 0;
                        tag_we1 <= 0;
                        tag_we2 <= 0;
                        state <= IDLE;
                    end
                end
                else begin //miss
                    LRU_change <= 0;
                    LRU_update <= 0;
                    w_ready <= 0;
                    r_ready <= 0;
                    dty_clear <= 0;
                    dty_write <= 0;
                    valid_write <= 0;
                    mem_we1 <= 0;
                    mem_we2 <= 0;
                    tag_we1 <= 0;
                    tag_we2 <= 0;
                    if(dirty) begin
                        dw_valid <= 1;
                        dr_valid <= 0;
                        state <= WRITE_BACK;
                    end
                    else begin
                        dr_valid <= 1;
                        dw_valid <= 0;
                        state <= FETCH;
                    end
                end
            end
            else begin //stay IDLE
                LRU_change <= 0;
                LRU_update <= 0;
                w_ready <= 0;
                r_ready <= 0;
                state <= IDLE;
            end
        end
        WRITE_BACK: begin
            LRU_change <= 0;
            LRU_update <= 0;
            if(~dw_ready) begin
                dw_valid <= 1;
                dr_valid <= 0;
                state <= WRITE_BACK;
            end
            else begin
                dw_valid <= 0;
                dr_valid <= 1;
                state <= FETCH;
            end
        end
        FETCH: begin
            if(~dr_ready) begin
                dr_valid <= 1;
                dw_valid <= 0;
                state <= FETCH;
            end
            else begin//写入新的tag，data，dirty，LRU，读取完成
                if(valid[way_sel]) begin
                    LRU_change <= 1;
                    LRU_update <= 0;
                end
                else begin
                    LRU_change <= 0;
                    LRU_update <= 0;
                end
                dr_valid <= 0;
                dw_valid <= 0;

                w_data_sel <= 1;

                mem_we1 <= way_sel ? 0 : 1;
                mem_we2 <= way_sel ? 1 : 0;
                tag_we1 <= way_sel ? 0 : 1;
                tag_we2 <= way_sel ? 1 : 0;

                w_ready <= 1;
                r_ready <= 1;
                if (~w_valid) begin
                    dty_clear <= 1;
                    dty_write <= 0;
                end
                else  begin
                    dty_clear <= 2;
                    dty_write <= 0;
                end
                valid_write <= 1;
                data_from_mem <= 1;
                state <= FINISH;
            end
        end
        FINISH: begin
            data_from_mem <= 0;
        w_data_sel <= 0;
        LRU_update <= 0;
        LRU_change <= 0;
        dty_clear <= 0;
        dty_write <= 0;
        valid_write <= 0;
        mem_we1 <= 0;
        mem_we2 <= 0;
        tag_we1 <= 0;
        tag_we2 <= 0;
        w_ready <= 0;
        r_ready <= 0;
            state <= IDLE;
        end
        endcase
    end
end

endmodule