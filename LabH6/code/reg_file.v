module  reg_file(
    input  clk,		//时钟
    input [4:0]  ra0, ra1, ra2,	//读地址
    output [31:0] rd0, rd1, rd2,	//读数据
    input [4:0]  wa,		//写地址
    input [31:0] wd,	//写数据
    input we		//写使能
);
reg [31:0] rf [0:31]; 	//寄存器堆
integer i;
initial begin
    for(i=0;i<=31;i=i+1) begin
        rf[i] = 8'b0;
    end
end
/*
always@(ra1, ra2, ra0)
    rf[0] = 0;*
*/

always  @(posedge  clk)
begin
    if (we && wa != 0)  rf[wa]  <=  wd;   //写操作
end

    assign rd1 = (ra1 == wa && we && wa != 0) ? wd : ((ra1 == 0) ? 0 : rf[ra1]);  
    assign rd2 = (ra2 == wa && we && wa != 0) ? wd : ((ra2 == 0) ? 0 : rf[ra2]);  
    assign rd0 = (ra0 == wa && we && wa != 0) ? wd : ((ra0 == 0) ? 0 : rf[ra0]);  
endmodule

