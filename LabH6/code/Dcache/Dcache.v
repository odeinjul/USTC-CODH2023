module Dcache (
    input clk,
    input rstn, 
    input [9:0] addr,
    input r_valid, w_valid,
    input [31:0] w_word,
    //input we,
    output r_ready, w_ready,
    output [31:0] r_word
);

wire [1:0] offset;
wire [4:0] index;
wire [2:0] tag;

parse parse_inst (
    .addr(addr),
    .offset(offset),
    .index(index),
    .tag(tag)
);

wire [127:0] w_data;

wire [127:0] r_data1, r_data2;
wire [2:0] r_tag1, r_tag2;
wire mem_we1, mem_we2, tag_we1, tag_we2;
wire [1:0] valid;
wire [127:0] r_data, mem_data, w_data_write, cache_data;


cache cache_inst1 (
    .a(index),
    .d(w_data_write),
    .we(mem_we1),
    .clk(clk),
    .spo(r_data1)
);

cache cache_inst2 (
    .a(index),
    .d(w_data_write),
    .we(mem_we2),
    .clk(clk),
    .spo(r_data2)
);

tag tag_inst1 (
    .a(index),
    .d(tag),
    .we(tag_we1),
    .clk(clk),
    .spo(r_tag1)
);

tag tag_inst2 (
    .a(index),
    .d(tag),
    .we(tag_we2),
    .clk(clk),
    .spo(r_tag2)
);

wire hit1, hit2;
wire way_sel;

wire LRU_change, LRU_update, dty_write, dirty, valid_write;
wire [1:0] dty_clear;

wire dr_valid, dw_valid, dr_ready, dw_ready;
wire data_from_mem, w_data_sel;

fsm fsm_inst (
    .clk(clk),
    .rstn(rstn),
    .hit1(hit1),
    .hit2(hit2),
    .r_valid(r_valid),   // with cpu
    .w_valid(w_valid),
    .dr_ready(dr_ready), //with d_mem
    .dw_ready(dw_ready),
    .addr(addr[9:2]),
    .way_sel(way_sel),
    .dirty(dirty),
    .valid(valid),

    .dr_valid(dr_valid), //with d_mem
    .dw_valid(dw_valid),

    .mem_we1(mem_we1),
    .mem_we2(mem_we2),
    .tag_we1(tag_we1),
    .tag_we2(tag_we2),

    .dty_write(dty_write),
    .dty_clear(dty_clear),
    .valid_write(valid_write),

    .LRU_change(LRU_change),
    .LRU_update(LRU_update),

    .data_from_mem(data_from_mem),
    .w_data_sel(w_data_sel),

    .w_ready(w_ready),  //with cpu
    .r_ready(r_ready)
);


LRU LRU_inst (
    .clk(clk),
    .rstn(rstn),
    .hit1(hit1),
    .hit2(hit2),
    .index(index),
    .LRU_change(LRU_change),
    .LRU_update(LRU_update),
    .way_sel(way_sel)
);

dirty dirty_inst (
    .clk(clk),
    .rstn(rstn),
    .index(index),
    .hit1(hit1),
    .hit2(hit2),
    .dty_write(dty_write),
    .way_sel(way_sel),
    .dty_clear(dty_clear),
    .dirty(dirty)
);

valid valid_inst (
    .clk(clk),
    .rstn(rstn),
    .index(index),
    .way_sel(way_sel),
    .valid_write(valid_write),
    .valid(valid)
);

assign hit1 = (r_tag1 == tag && valid[0]) ? 1 : 0;
assign hit2 = (r_tag2 == tag && valid[1]) ? 1 : 0;


rdata_mux rdmx_inst (
    .hit1(hit1),
    .hit2(hit2),
    .r_data1(r_data1),
    .r_data2(r_data2),
    .r_data(cache_data) //r_data = cache[index]
);
assign r_data = data_from_mem ? mem_data : cache_data;


assign w_data = w_data_sel ? mem_data : cache_data;

write_data wtdt_inst (
    .w_word(w_word),
    .w_valid(w_valid),
    .cache_data(w_data),
    .offset(offset),
    .w_data(w_data_write)
);


rword_sel rwsl_inst(
    .offset(offset),
    .r_data(r_data),
    .r_word(r_word)
);

wire [127:0] w_data_wb;
wire [7:0] w_addr;
assign w_data_wb = way_sel ? r_data2 : r_data1;
assign w_addr = way_sel ? {r_tag2, index} : {r_tag1, index};


DataMem Dmem_inst(
    .clk(clk),
    .rstn(rstn),

    .r_addr(addr[9:2]), 
    .w_addr(w_addr),
    .w_data(w_data_wb),
    .r_valid(dr_valid),
    .w_valid(dw_valid),

    .r_data(mem_data),
    .r_ready(dr_ready), 
    .w_ready(dw_ready)
);





endmodule

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
