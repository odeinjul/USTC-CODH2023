module cpu (
        input clk, rstn, 
        // SDU
        input [4:0] rra0,
        input  [31:0] dra0,
        
        output [31:0] drd0, rrd0,
        output [31:0] ctr_debug1, ctr_debug2, ctr_debug3,
        output [31:0] _npc, _pc, _ir,
        output [31:0] _pc_id, _ir_id,
        output [31:0] _pc_ex, _ir_ex, _rrd1, _rrd2, _imm,
        output [31:0] _ir_mem, _res, _dwd,
        output [31:0] _ir_wb, _drd, _res_wb,
        output [31:0] _rwd,

        //mio
        input [15:0] sw,
        input BTNC, BTNU, BTNL, BTNR, BTND,
        output [15:0] led,
        output [7:0] AN,
        output [6:0] seg
    );
    wire stall, flush, cache_stall;
    wire flag;
    wire branch;
    wire [31:0] a_forward, b_forward;
    //IF varibles
    reg [31:0] IF_pc;
    wire [31:0] IF_ir;
    wire [31:0] IF_npc_temp;
    wire [31:0] IF_npc;

    //ID varibles
    //data
    wire [4:0] ID_rf_rs1, ID_rf_rs2, ID_rf_rd;
    wire [31:0] ID_pc, ID_ir;
    wire [31:0] ID_rf_rd1, ID_rf_rd2;
    //wire [31:0] ID_rf_wd; //Not current instruction
    wire [31:0] ID_imm;
    //info
    wire [6:0] ID_opcode;
    wire [2:0] ID_funct3;
    wire [6:0] ID_funct7;
    //control
    wire [2:0] ID_reg_sel;
    wire [2:0] ID_pc_sel, ID_alu_op;
    wire ID_w_valid, ID_r_valid;
    wire ID_alu_src;
    wire ID_reg_write;

    //EX varibles
    //data
    wire [31:0] EX_a, EX_b, EX_imm;
    wire [31:0] EX_pc, EX_ir;
    wire [4:0] EX_rf_rs1, EX_rf_rs2, EX_rf_rd;
    //control
    wire [6:0] EX_EX;
    wire EX_w_valid, EX_r_valid;
    wire [3:0] EX_WB;
    wire [31:0] EX_alu_in1, EX_alu_in2, EX_alu_out;
    wire [2:0] EX_alu_flag;
    wire [2:0] EX_alu_op, EX_pc_sel;
    wire EX_alu_src;
    //info
    wire [6:0] EX_opcode;
    wire [2:0] EX_funct3;

    //MEM varibles
    //control
    wire MEM_w_valid, MEM_r_valid, MEM_IOU_r_ready, MEM_r_ready, MEM_w_ready; 
    wire [3:0] MEM_WB;
    //data
    wire [31:0] MEM_d, MEM_dm_rd;
    wire [4:0] MEM_rf_rd;
    wire [31:0]  MEM_addr;
    wire [31:0] MEM_pc, MEM_imm, MEM_y, MEM_ir;
    wire [6:0] MEM_opcode;

    //WB varibles
    //data
    wire [4:0] WB_rf_rd;
    wire [31:0] WB_vw, WB_data, WB_rf_wd;
    wire [31:0] WB_pc, WB_imm, WB_ir;
    wire [6:0] WB_opcode;
    //control
    wire WB_reg_write;
    wire [2:0] WB_reg_sel;
    

    assign _npc = IF_npc;
    assign _pc = IF_pc;
    assign _ir = IF_ir;

    assign _pc_id = ID_pc;
    assign _ir_id = ID_ir;

    assign _pc_ex = EX_pc;
    assign _ir_ex = EX_ir;
    assign _rrd1 = EX_alu_in1;
    assign _rrd2 = EX_alu_in2;
    assign _imm = EX_imm;

    assign _ir_mem = MEM_ir;
    assign _res = MEM_addr;
    assign _dwd = MEM_d;

    assign _ir_wb = WB_ir;
    assign _drd = WB_data;
    assign _res_wb = WB_rf_wd;
    // IF STAGE START
    //assign flag = debug;
    assign IF_npc = rstn ? IF_npc_temp : 0;
    
    always@(posedge clk) begin
        if (~rstn) begin
            IF_pc <= 0;
        end
        else if(!stall) begin
            IF_pc <= IF_npc;
        end
    end

    //ID assign
    assign ID_opcode = ID_ir[6:0];
    assign ID_funct3 = ID_ir[14:12];
    assign ID_funct7 = ID_ir[31:25];
    stall_flush stall_flush_inst(
        .branch(branch),
        .opcode(EX_opcode),
        .addr(EX_alu_out),
        .MEM_addr(MEM_addr),
        .ire(EX_rf_rd),
        .rf_rs1(ID_rf_rs1),
        .rf_rs2(ID_rf_rs2),
        .r_valid(MEM_r_valid),
        .w_valid(MEM_w_valid),
        .r_ready(MEM_r_ready),
        .w_ready(MEM_w_ready),
        .stall(stall),
        .flush(flush),
        .cache_stall(cache_stall)
    );
    
    inst_mem inst_mem_inst(
        .a(IF_pc[11:2]), 
        .spo(IF_ir)
    );
    // IF STAGE END


    // ID STAGE START
    IF_ID_reg IF_ID_reg_inst(
        .clk(clk), 
        .rstn(rstn),
        .stall(stall | cache_stall),
        .flush(flush),
        .pcd(IF_pc), 
        .ir(IF_ir), 
        ._pcd(ID_pc), 
        ._ir(ID_ir), 
        ._ra1(ID_rf_rs1), 
        ._ra2(ID_rf_rs2), 
        ._ire(ID_rf_rd)
    );
    reg_file rf_inst(
        .clk(clk), 
        .ra0(rra0),      //SDU
        .ra1(ID_rf_rs1), 
        .ra2(ID_rf_rs2), 
        .rd0(rrd0),     //SDU
        .rd1(ID_rf_rd1), 
        .rd2(ID_rf_rd2), 
        .wa(WB_rf_rd),      
        .wd(WB_rf_wd), 
        .we(WB_reg_write)     
    );

    imm_gen imm_gen_inst(
        .raw(ID_ir), 
        .opcode(ID_opcode), 
        .funct3(ID_funct3), 
        .ext_imm(ID_imm)
    );
    control control_isnt(
        .opcode(ID_opcode), 
        .funct3(ID_funct3), 
        .funct7(ID_funct7), 
        .reg_sel(ID_reg_sel), 
        .pc_sel(ID_pc_sel), 
        .w_valid(ID_w_valid), 
        .r_valid(ID_r_valid),
        .alu_src(ID_alu_src), 
        .alu_op(ID_alu_op), 
        .reg_write(ID_reg_write)
    );
    // ID STAGE END


    // EX STAGE START
    //EX assign
    assign EX_opcode = EX_ir[6:0];
    assign EX_funct3 = EX_ir[14:12];
    assign EX_alu_src = EX_EX[6];
    assign EX_alu_op = EX_EX[5:3];
    assign EX_pc_sel = EX_EX[2:0];

    ID_EX_reg ID_EX_reg_inst(
        //input - ID
        .clk(clk), 
        .rstn(rstn),
        .stall(stall | cache_stall),
        .flush(flush),
        .alu_src(ID_alu_src), 
        .alu_op(ID_alu_op),
        .pc_sel(ID_pc_sel),
        .w_valid(ID_w_valid),
        .r_valid(ID_r_valid),
        .reg_write(ID_reg_write),
        .reg_sel(ID_reg_sel),
        .pce(ID_pc),
        .ir(ID_ir),
        .a(ID_rf_rd1),
        .b(ID_rf_rd2),
        .rs1(ID_rf_rs1),
        .rs2(ID_rf_rs2),
        .imm(ID_imm),
        .ire(ID_rf_rd),
        //output - EX
        ._EX(EX_EX),
        ._w_valid(EX_w_valid),
        ._r_valid(EX_r_valid),
        ._WB(EX_WB),
        ._pce(EX_pc),
        ._ir(EX_ir),
        ._a(EX_a),
        ._b(EX_b),
        ._imm(EX_imm),
        ._ire(EX_rf_rd),
        ._rs1(EX_rf_rs1),
        ._rs2(EX_rf_rs2)
    );
    assign EX_alu_in1 = a_forward;
    assign EX_alu_in2 = EX_alu_src ? EX_imm : b_forward;
    alu alu_inst(
        .a(EX_alu_in1), 
        .b(EX_alu_in2), 
        .f(EX_alu_op), 
        .y(EX_alu_out), 
        .t(EX_alu_flag)
    );
    branch_control branch_control_inst(
        .opcode(EX_opcode), 
        .cc(EX_alu_flag), 
        .funct3(EX_funct3), 
        .branch(branch)
    );
    next_pc_sel npc_sel_inst(
        .pc_sel(EX_pc_sel), 
        .branch(branch),
        .cache_stall(cache_stall),
        .opcode(EX_opcode),
        .alu_out(EX_alu_out), 
        .pc(IF_pc), 
        .ext_imm(EX_imm), 
        .npc(IF_npc_temp) // -> IF
    );
    // EX STAGE END


    // MEM STAGE START
    EX_MEM_reg EX_MEM_reg_inst (
        //----INPUT----
        .clk(clk),
        .rstn(rstn),
        .stall(cache_stall),
        .w_valid(EX_w_valid),
        .r_valid(EX_r_valid),
        .WB(EX_WB),
        .imm(EX_imm),
        .pcm(EX_pc),
        .y(EX_alu_out),
        .mdw(b_forward),
        .irm(EX_rf_rd),
        .ir(EX_ir),
        .opcode(EX_opcode),
        //----OUTPUT----
        //control
        ._w_valid(MEM_w_valid),
        ._r_valid(MEM_r_valid),
        ._WB(MEM_WB),
        //data
        ._y(MEM_addr),
        ._pcm(MEM_pc),
        ._imm(MEM_imm),
        ._mdw(MEM_d),
        ._irm(MEM_rf_rd),
        ._ir(MEM_ir),
        ._opcode(MEM_opcode)
    );

    /*
    data_mem data_mem_inst(
        .a(MEM_addr[11:2]), // 32 bit 
        .d(MEM_d), 
        .dpra(dra0), 
        .clk(clk), 
        .we(MEM_w_valid), 
        .spo(MEM_dm_rd), 
        .dpo(drd0)
    );**/

    wire [31:0] io_din, io_dout;
    wire [7:0] io_addr;
    wire io_we, io_rd;

    cache_mmio cm_inst(
        .clk(clk),
        .rstn(rstn),
        .addr(MEM_addr),
        .w_data(MEM_d),
        .r_valid(MEM_r_valid),
        .w_valid(MEM_w_valid),
        .r_ready(MEM_r_ready),
        .w_ready(MEM_w_ready),
        .r_data(MEM_dm_rd),

        .io_addr(io_addr),
        .io_dout(io_dout),
        .io_din(io_din),
        .io_we(io_we),
        .io_rd(io_rd)
    );
   
     //assign ctr_debug1 = seg_rd;
     assign ctr_debug2 = MEM_dm_rd;
     //assign ctr_debug3 = (MEM_addr[31: 8] == 24'h000000);
   //assign ctr_debug3 = io_addr;
    IOU IOU_inst (
        .clk(clk),
        .rstn(rstn),
         .sw(sw),
        .BTNC(BTNC),
        .BTNU(BTNU),
        .BTNL(BTNL),
        .BTNR(BTNR),
        .BTND(BTND),
 
        .io_addr(io_addr),
        .io_dout(io_dout),
        .io_din(io_din),
        .io_we(io_we),
        .io_rd(io_rd),
        
        .led(led),
        .AN(AN),
        .seg(seg),
        .ctr_debug1(ctr_debug1),
        //.ctr_debug2(ctr_debug2),
        .ctr_debug3(ctr_debug3)
    );

    // MEM STAGE END


    //WB STAGE START
    MEM_WB_reg MEM_WB_reg_inst(
        //----INPUT----
        .clk(clk),
        .rstn(rstn),
        .WB(MEM_WB),
        .stall(cache_stall),
        ._imm(MEM_imm),
        .pcw(MEM_pc),
        .mdr(MEM_dm_rd),
        .vw(MEM_addr),
        .irw(MEM_rf_rd),
        .ir(MEM_ir),
        .opcode(MEM_opcode),
        //----OUTPUT----
        //control
        ._reg_write(WB_reg_write),
        ._reg_sel(WB_reg_sel),
        //data
        ._mdr(WB_data),
        ._vw(WB_vw),
        ._irw(WB_rf_rd),
        ._pcw(WB_pc),
        .__imm(WB_imm),
        ._ir(WB_ir),
        ._opcode(WB_opcode)
    );
    reg_file_sel rf_sel_inst(
        .reg_sel(WB_reg_sel), 
        .alu_out(WB_vw),
        .pc(WB_pc), 
        .dm_rd(WB_data), 
        .ext_imm(WB_imm), 
        .rf_wd(WB_rf_wd)
    );
    //WB STAGE END


    forward forward_inst(
        .EX_rs1(EX_rf_rs1),
        .EX_rs2(EX_rf_rs2),
        .MEM_rd(MEM_rf_rd),
        .WB_rd(WB_rf_rd),
        .MEM_reg_write(MEM_WB[3]),
        .WB_reg_write(WB_reg_write),
        .MEM_reg_sel(MEM_WB[2:0]),
        .WB_reg_sel(WB_reg_sel),
        .EX_a(EX_a),
        .EX_b(EX_b),
        .MEM_alu_out(MEM_addr),
        .WB_rf_wd(WB_rf_wd),
        .alu_in1(a_forward),
        .alu_in2(b_forward),
        .MEM_pc(MEM_pc),
        .MEM_dm_rd(MEM_dm_rd),
        .MEM_imm(MEM_imm)
    );
    


endmodule