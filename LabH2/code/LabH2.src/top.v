module  top (
    input  clk, 		//时钟
    input  rstn, 		//复位
    input run,		//启动排序
    output done,		//排序结束标志
    output [15:0]  cycles,	//排序耗费时钟周期数
    input rxd,
    output txd
);

    wire [7:0] addr;
    wire [31:0] dout;
    wire [31:0] din;
    wire we;

    
    wire clk_ld;
    wire out;
    fix_edge fe_inst(
        .clk(clk),
        .en(run),
        .out(out)
    );

    sort_with_sdu srt_inst(
        .clk(clk),
        .rstn(rstn),
        .run(out),
        .done(done),
        .cycles(cycles),
        .addr(addr),
        .dout(dout),
        .din(din),
        .we(we),
        .clk_ld(clk_ld) 
    );
        
    sdu_dm sdu_inst(
        .clk(clk),
        .rstn(rstn),
        .rxd(rxd),
        .txd(txd),
        .addr(addr),
        .dout(dout),
        .din(din),
        .we(we),
        .clk_ld(clk_ld)
    );
endmodule