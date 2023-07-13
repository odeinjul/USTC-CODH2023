module IF_ID_reg (
    input rstn,
    input clk,
    input stall,
    input flush,
    input [31:0] pcd,
    input [31:0] ir,
    output reg [31:0] _pcd,
    output reg [4:0] _ra1, _ra2,
    output reg [31:0] _ir,
    output reg [4:0] _ire
);
always @ (posedge clk) begin
    if(!rstn) begin
        _pcd <= 0;
        _ir <= 0;
        _ra1 <= 0;
        _ra2 <= 0;
        _ire <= 0;
    end
    else begin
        if (!stall) begin
            if (flush) begin
                _pcd <= 0;
                _ir <= 0;
                _ra1 <= 0;
                _ra2 <= 0;
                _ire <= 0;
            end
            else begin
                _pcd <= pcd;
                _ir <= ir;
                _ra1 <= ir[19:15];
                _ra2 <= ir[24:20];
                _ire <= ir[11:7]; 
            end
        end
    end
end
endmodule

module ID_EX_reg (
    input rstn,
    input clk,
    input stall,
    input flush,
    input [31:0] ir,
    //EX
    input alu_src,
    input [2:0] alu_op,
    input [2:0] pc_sel,
    //M
    input w_valid, r_valid,
    //WB
    input reg_write,
    input [2:0] reg_sel,
    
    input [4:0] rs1, rs2,
    input [31:0] pce,
    input [31:0] a, b,
    input [31:0] imm,
    input [4:0] ire,
    //EX
    output reg [6:0] _EX,
    //M
    output reg _w_valid, _r_valid,
    //WB
    output reg [3:0] _WB,

    output reg [4:0] _rs1, _rs2,
    output reg [31:0] _pce,
    output reg [31:0] _a, _b,
    output reg [31:0] _imm,
    output reg [4:0] _ire,
    output reg [31:0] _ir
);
always @ (posedge clk) begin
    if (!rstn) begin
        _EX <= 0;
        _w_valid <= 0;
        _r_valid <= 0;
        _WB <= 0;
        _rs1 <= 0;
        _rs2 <= 0;
        _pce <= 0;
        _a <= 0;
        _b <= 0;
        _imm <= 0;
        _ire <= 0;
        _ir <= 0;
    end
    else begin
        if (!stall) begin
            if (flush) begin
            _EX <= 0;
            _w_valid <= 0;
            _r_valid <= 0;
            _WB <= 0;
            _rs1 <= 0;
            _rs2 <= 0;
            _pce <= 0;
            _a <= 0;
            _b <= 0;
            _imm <= 0;
            _ire <= 0;
            _ir <= 0;
            end
            else begin
            _EX <= {alu_src, alu_op, pc_sel};
            _w_valid <= w_valid;
            _r_valid <= r_valid;
            _WB <= {reg_write, reg_sel};
            _pce <= pce;
            _a <= a;
            _b <= b;
            _imm <= imm;
            _ire <= ire;
            _rs1 <= rs1;
            _rs2 <= rs2;
            _ir <= ir;
            end
        end
    end
end
endmodule

module EX_MEM_reg (
    input rstn,
    input clk,
    input stall,
    //M
    input w_valid, r_valid,
    //WB
    input [3:0] WB,

    input [31:0] pcm,
    input [31:0] y,
    input [31:0] mdw,
    input [31:0] imm,
    input [4:0] irm,
    input [31:0] ir,
    input [6:0] opcode,
    //M
    output reg _w_valid, _r_valid,
    //WB
    output reg [3:0] _WB,

    output reg [31:0] _pcm,
    output reg [31:0] _y,
    output reg [31:0] _mdw,
    output reg [4:0] _irm,
    output reg [31:0] _imm,
    output reg [31:0] _ir,
    output reg [6:0] _opcode
);
always @ (posedge clk) begin
    if (!rstn) begin
        _w_valid <= 0;
        _r_valid <= 0;
        _WB <= 0;
        _pcm <= 0;
        _y <= 0;
        _mdw <= 0;
        _irm <= 0;
        _imm <= 0;
        _ir <= 0;
        _opcode <= 0;
    end
    else if(!stall) begin
    _w_valid <= w_valid;
    _r_valid <= r_valid;
    _WB <= WB;
    _y <= y;
    _mdw <= mdw;
    _irm <= irm;
    _imm <= imm;
    _pcm <= pcm;
    _ir <= ir;
    _opcode <= opcode;
    end
end
endmodule

module MEM_WB_reg (
    input clk,
    input rstn,
    input stall,
    //WB
    input [3:0] WB,

    input [31:0] pcw,
    input [31:0] mdr,
    input [31:0] vw,
    input [4:0] irw,
    input [31:0] _imm,
    input [31:0] ir,
    input [6:0] opcode,

    output reg [31:0] _pcw,
    output reg _reg_write,
    output reg [2:0] _reg_sel,

    output reg [31:0] _mdr,
    output reg [31:0] _vw,
    output reg [4:0] _irw,
    output reg [31:0] __imm,
    output reg [31:0] _ir,
    output reg [6:0] _opcode
);
always @ (posedge clk) begin
    if(!rstn) begin
        _pcw <= 0;
        _reg_write <= 0;
        _reg_sel <= 0;
        _mdr <= 0;
        _vw <= 0;
        _irw <= 0;
        __imm <= 0;
        _ir <= 0;
        _opcode <= 0;
    end
    else if(!stall) begin
    _reg_write <= WB[3];
    _reg_sel <= WB[2:0];
    _mdr <= mdr;
    _vw <= vw;
    _irw <= irw;
    __imm <= _imm;
    _pcw <= pcw;
    _ir <= ir;
    _opcode <= opcode;
    end
end
endmodule