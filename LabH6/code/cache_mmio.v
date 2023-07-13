module cache_mmio(
    input clk,
    input rstn,

    input  [31: 0] addr,
    input  [31: 0] w_data,
    input  w_valid,
    input  r_valid,
    output w_ready, r_ready,
    output [31: 0] r_data,

    input [31:0] io_din,        
    output [7:0] io_addr,      
    output [31:0] io_dout,       
    output io_we,        
    output  io_rd
);
    wire mmio;
    assign mmio = (addr[31: 8] == 24'h000000);
    wire [31:0] mem_data;

    wire cache_w_valid, cache_r_valid, cache_w_ready, cache_r_ready;
    assign cache_w_valid = w_valid & ~mmio;
    assign cache_r_valid = r_valid & ~mmio;
    Dcache Dcache_inst(
        .clk(clk),
        .rstn(rstn),
        .addr(addr[11:2]),
        .r_valid(cache_r_valid),
        .w_valid(cache_w_valid),
        .w_word(w_data),
        .r_ready(r_ready),
        .w_ready(w_ready),
        .r_word(mem_data)
    );
    assign r_data = mmio ? io_din : mem_data;
    assign io_addr = addr[7:0];
    assign io_dout = w_data;
    assign io_we = w_valid & mmio;
    assign io_rd = r_valid & mmio;
endmodule