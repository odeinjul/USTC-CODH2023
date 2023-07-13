`timescale 1ns / 1ps
module MAIN(
    input       clk,rstn,
    input       rxd,
    output      txd,
    
    input [15:0] sw,
    input BTNC, BTNU, BTNL, BTNR, BTND,
    output [15:0] led,
    output [6:0] seg,
    output [7:0] AN
);
wire        clk_153600;
udf_FD fd(
    .k(32'h0000028b),
    .rstn(rstn),
    .clk(clk),
    .y(clk_153600)
);
wire [31:0]     ctr_debug1, ctr_debug2, ctr_debug3;
wire [31:0]     npc,pc,ir,
                pc_id,ir_id,pc_ex,ir_ex,rrd1,rrd2,imm,
                ir_mem,res,dwd,ir_wb,res_wb,drd,rwd;
wire            cpu_clk,cpu_rstn;
wire [31:0]     drd0,dra0,rrd0;
wire [4:0]      rra0;
////////////////////////////////////////////////////////
/* 可以在这里定义自己需要从CPU引出并由SDU输出的其他信号！！*/
wire [31:0]     my_signal;
wire temp;
assign temp = 1;
////////////////////////////////////////////////////////
SDU sdu(
    .clk(clk_153600),       // 波特率符合要求的时钟
    .rstn(temp),            // 复位信号
    .rxd(rxd),              // 用于输入
    .txd(txd),              // 用于输出
    // cpu控制时钟与置位信号
    .cpu_clk(cpu_clk),
    .cpu_rstn(cpu_rstn),
    // 以下是P指令的调试接口
    // 以下只有rra0即寄存器读地址位宽为5，其余均为32位
    .ctr_debug1(ctr_debug1),  // 3个32位的信号，可以自行定义语义
    .ctr_debug2(ctr_debug2),
    .ctr_debug3(ctr_debug3),
    .npc(npc),              // 在五级不含缓存的多周期CPU中由于其内容可由pc推断出，所以可以不设置
    .pc(pc),                // IF段前pc
    .ir(ir),                // IF段取出的指令码
    // IF/ID段间
    .pc_id(pc_id),          // IF段递给ID段的pc
    .ir_id(ir_id),          // IF段递给ID段的ir
    // ID/EX段间
    .pc_ex(pc_ex),          // ID段递给EX段的pc
    .ir_ex(ir_ex),          // ID段递给EX段的ir
    .rrd1(rrd1),            // 寄存器堆输出端1
    .rrd2(rrd2),            // 寄存器堆输出端2
    .imm(imm),              // ID阶段立即数计算结果
    // EX/MEM段间
    .ir_mem(ir_mem),        // EX段递给MEM段的ir
    .res(res),              // ALU output
    .dwd(dwd),              // 要写入数据存储器的数据
    // MEM/WB段间
    .ir_wb(ir_wb),          // MEM段递给WB段的ir
    .drd(drd),              // 数据存储器读出的数据
    .res_wb(res_wb),        // ALU的计算结果继续传递
    // WB段需要写回的数据
    .rwd(rwd),              // 需要写回到寄存器堆的数据
    // 用于D与R指令的调试接口
    .drd0(drd0),            // 数据存储器的输出
    .dra0(dra0),            // 数据存储器的输入地址
    .rrd0(rrd0),            // 寄存器堆的输出数据
    .rra0(rra0)             // 寄存器堆的输入地址，唯一的五位位宽
);
// 按照需求修改相应接口即可，接口定义详见SDU的说明
cpu cpu_inst(
    .clk(cpu_clk),      // 控制CPU运行的时钟
    .rstn(rstn),    // 控制CPU复位的信号
    /* ***以下根据需要修改*** */
    // 用于D与R指令的调试接口
    .dra0(dra0),            // 数据存储器的输入地址
    .drd0(drd0),            // 数据存储器的输出
    .rra0(rra0),            // 寄存器堆的输入地址，唯一的五位位宽
    .rrd0(rrd0),            // 寄存器堆的输出数据
    // 自由定义部分
    .ctr_debug1(ctr_debug1),
    .ctr_debug2(ctr_debug2),
    .ctr_debug3(ctr_debug3),
    // IF段
    ._npc(npc),              // 下一个pc值
    ._pc(pc),                // IF段前pc
    ._ir(ir),                // IF段取出的指令码
    // IF/ID段间
    ._pc_id(pc_id),          // IF段递给ID段的pc
    ._ir_id(ir_id),          // IF段递给ID段的ir
    // ID/EX段间
    ._pc_ex(pc_ex),          // ID段递给EX段的pc
    ._ir_ex(ir_ex),          // ID段递给EX段的ir
    ._rrd1(rrd1),            // 寄存器堆输出端1
    ._rrd2(rrd2),            // 寄存器堆输出端2
    ._imm(imm),
    // EX/MEM段间
    ._ir_mem(ir_mem),        // EX段递给MEM段的ir
    ._res(res),              // ALU output
    ._dwd(dwd),              // 要写入数据存储器的数据
    // MEM/WB段间
    ._ir_wb(ir_wb),          // MEM段递给WB段的ir
    ._drd(drd),              // 数据存储器读出的数据
    ._res_wb(res_wb),        // ALU的计算结果继续传递
    // WB段写回
    ._rwd(rwd),               // 需要写回到寄存器堆的数据
    .sw(sw),
    .BTNC(BTNC),
    .BTNU(BTNU),
    .BTNL(BTNL),
    .BTNR(BTNR),
    .BTND(BTND),
    .led(led),
    .AN(AN),
    .seg(seg)
);
endmodule
