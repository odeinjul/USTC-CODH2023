module top (
        input clk, rstn,
        output [15:0] cycles,
        output [1:0] led,
        // SDU  
        input rxd,
        output txd

);

cpu cpu_inst (
    .clk(clk_cpu),
    .rstn(rstn),
    .debug(debug),
    ._pc_chk(_pc_chk),
    ._npc(_npc),
    ._pc(_pc),
    ._ir(_ir),
    ._ctl(_ctl),
    ._a(_a),
    ._b(_b),
    ._imm(_imm),
    ._y(_y),
    ._mdr(_mdr),
    ._r_addr(_addr),
    ._dout_dm(_dout_dm), 
    ._dout_im(_dout_im), 
    ._dout_rf(_dout_rf),
    ._w_addr(_addr),
    ._din(_din),
    ._we_im(_we_im),
    ._we_dm(_we_dm),
    ._clk_ld(_clk_ld),
    .cycles(cycle),
    .state(led)
    
);
wire [31:0] cycle;
assign cycles = cycle;

wire clk_cpu;
wire [31:0] _pc_chk, _npc, _pc, _ir, _imm, _ctl, _a, _b, _y, _mdr, _addr, _dout_rf, _dout_dm, _dout_im, _din;
wire _we_dm, _we_im, _clk_ld, debug;

SDU SDU_inst(
    .clk(clk),
    .rstn(rstn),
    .rxd(rxd),
    .txd(txd),
    .clk_cpu(clk_cpu),
    .pc_chk(_pc_chk),

    .npc(_npc),
    .pc(_pc),
    .IR(_ir),
    .IMM(_imm),
    .CTL(_ctl),
    .A(_a),
    .B(_b),
    .Y(_y),
    .MDR(_mdr),

    .addr(_addr),
    .dout_dm(_dout_dm), 
    .dout_im(_dout_im), 
    .dout_rf(_dout_rf),
    .din(_din),
    .we_im(_we_im),
    .we_dm(_we_dm),
    .clk_ld(_clk_ld),
    .debug(debug)
);
endmodule