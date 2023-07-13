module  register_file #(
    parameter AWidth = 5,	//地址宽度
    parameter DWidth = 32	//数据宽度
)(
    input  clk,		//时钟
    input [AWidth - 1:0]  ra1, ra2,	//读地址
    output [DWidth - 1:0]  rd1, rd2,	//读数据
    input [AWidth - 1:0]  wa,		//写地址
    input [DWidth - 1:0]  wd,	//写数据
    input we		//写使能
);
reg [DWidth - 1:0]  rf [0: (1 << AWidth) - 1]; 	//寄存器堆

always@(ra1, ra2)
    rf[0] = 0;

always  @(posedge  clk)
begin
    if (we && wa != 0)  rf[wa]  <=  wd;   //写操作
end

assign rd1 = (ra1 == wa && we == 1 && wa != 0) ? wd : rf[ra1];  //写优先的读操作1
assign rd2 = (ra2 == wa && we == 1 && wa != 0) ? wd : rf[ra2];  //写优先的读操作2
endmodule

