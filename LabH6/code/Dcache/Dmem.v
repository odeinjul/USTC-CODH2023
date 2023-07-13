// 分布式存储器，总容量1KB
// 块大小：4 words (16 byte = 128 bits)
// 1024 / 16 = 64 块
// 32块 * 4words * 2
// 2路组相联


// [9:0] addr 
// word addr
// offset [1:0]
// index: [4:0]
// tag: [9:7]
module DataMem (
    input clk,
    input rstn,
    input [7:0] r_addr, w_addr,
    input [127:0] w_data,
    input r_valid, w_valid,
    output reg [127:0] r_data,
    output reg r_ready, w_ready
);

localparam IDLE = 3'b000;
localparam DELAY = 3'b001;
localparam WRITE = 3'b010;
localparam WT_RDY = 3'b011;
localparam READ = 3'b100;
localparam RD_RDY = 3'b101;
localparam FINISH = 3'b110;


reg [31:0] delay_cnt;
reg [31:0] offset_cnt;
localparam CYCLE = 16;
localparam WORD_SIZE = 4;

reg [2:0] state;

reg [9:0] rd_addr;   
wire [9:0] wt_addr;                                 
reg wt_en;

reg [31:0] wt_data;    

wire [9:0] addr;
assign addr = wt_en ? wt_addr : rd_addr;
wire [31:0] dout;

always@(*)
begin
    case(offset_cnt)
        2'b00: wt_data = w_data[31:0];
        2'b01: wt_data = w_data[63:32];
        2'b10: wt_data = w_data[95:64];
        2'b11: wt_data = w_data[127:96];
    endcase
end

assign wt_addr = {w_addr, offset_cnt[1:0]};

always@(posedge clk)
begin
    if(~rstn) begin
        state <= IDLE;
        r_ready <= 0;
        w_ready <= 0;
        delay_cnt <= 0;
        offset_cnt <= 0;
        wt_en <= 0;
    end
    else begin
        case(state)
            IDLE: begin
                if(w_valid || r_valid) begin
                    r_ready <= 0;
                    w_ready <= 0;
                    state <= DELAY;
                end
                else begin
                    r_ready <= 0;
                    w_ready <= 0;
                    state <= IDLE;
                end
            end
            DELAY: begin 
                if(delay_cnt < CYCLE) begin //wait 16 cycles
                    delay_cnt = delay_cnt + 1;
                    offset_cnt <= 0;
                end
                else begin
                    if(w_valid) begin
                        delay_cnt <= 0;
                        offset_cnt <= 0;
                        wt_en <= 1;
                        state <= WRITE;
                    end
                    else if(r_valid) begin
                        delay_cnt <= 0;
                        offset_cnt <= 1;
                        rd_addr <= {r_addr, offset_cnt[1:0]};
                        state <= READ;
                    end
                end
            end
            WRITE: begin
                if(offset_cnt < WORD_SIZE - 1)begin
                    //wt_data = ...
                    wt_en <= 1;
                    offset_cnt <= offset_cnt + 1;
                end
                else begin
                    offset_cnt <= 0;
                    wt_en <= 0;
                    state <= WT_RDY;
                end
            end
            WT_RDY: begin
                w_ready <= 1;
                state <= FINISH;
            end
            READ: begin
                wt_en <= 0;
                if(offset_cnt < WORD_SIZE) begin
                    rd_addr <= {r_addr, offset_cnt[1:0]};
                    r_data <= {dout, r_data[127:32]}; // 0, 
                    offset_cnt <= offset_cnt + 1;
                end
                else begin
                    r_data <= {dout, r_data[127:32]};
                    offset_cnt <= 0;
                    state <= RD_RDY;
                end
            end
            RD_RDY: begin
                r_ready <= 1;
                state <= FINISH;
            end
            FINISH: begin
                r_ready <= 0;
                w_ready <= 0;
                wt_en <= 0;
                state <= IDLE;
            end

        endcase
    end
end


D_mem D_mem_inst (
    .clk(clk),
    .a(addr),
    .d(wt_data),
    .we(wt_en),
    .spo(dout)
);

endmodule