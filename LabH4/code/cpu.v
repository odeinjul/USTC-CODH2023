module cpu (
        input clk, rstn, debug, 
        // SDU
        output [31:0] _pc_chk,
        output [31:0] _npc, _pc, _ir, _ctl, _a, _b, _imm, _y, _mdr,
        input [31:0] _r_addr,
        output [31:0] _dout_dm, _dout_im, _dout_rf,
        input [31:0] _w_addr,
        input [31:0] _din,
        input _we_im, _we_dm,
        input _clk_ld,
        output [31:0] cycles,
        output [1:0] state
        
    );
    // PC
    wire flag;
    assign flag = debug;
    reg [31:0] pc;
    wire [31:0] npc_temp;
    wire [31:0] npc;
    assign npc = flag ? 32'h00000000 : npc_temp;
    wire [31:0] ir;

    //INSTRUCTION
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [4:0] rf_rs1, rf_rs2, rf_rd;
    assign opcode = ir[6:0];
    assign rf_rd = ir[11:7];
    assign rf_rs1 = ir[19:15];
    assign rf_rs2 = ir[24:20];
    assign funct3 = ir[14:12];
    assign funct7 = ir[31:25];
    assign _pc_chk = pc;
    assign _pc = pc;
    assign _npc = npc;
    assign _ir = ir;
    assign _ctl = {branch, reg_sel, pc_sel, mem_write, alu_src, reg_write, alu_op};
    assign _a = alu_in1;
    assign _b = alu_in2;
    assign _y = alu_out;
    assign _imm = ext_imm;
    assign _mdr = dm_rd;

     //control
    wire branch;
    wire [2:0] reg_sel;
    wire [2:0] pc_sel;
    wire mem_write;
    wire alu_src;
    wire reg_write;

    //ALU
    wire [31:0] alu_in1, alu_in2, alu_out;
    wire [2:0] alu_flag;
    wire [2:0] alu_op;
    wire [31:0] ext_imm;
    wire [31:0] rf_rd1, rf_rd2, dm_rd, dm_d;
    imm_gen imm_gen_inst(.raw(ir), .opcode(opcode), .funct3(funct3), .ext_imm(ext_imm));
    assign alu_in1 = rf_rd1;
    assign alu_in2 = alu_src ? ext_imm : rf_rd2;
    alu alu_inst(.a(alu_in1), .b(alu_in2), .f(alu_op), .y(alu_out), .t(alu_flag));


    //DATA 
    wire dm_we, dm_clk;
    wire [31:0] dm_addr;
    assign dm_addr = ~flag ? alu_out[11:2] : _w_addr;
    assign dm_d = ~flag ? rf_rd2 : _din;
    assign dm_we = ~flag ? (mmio_flag ? 0 : mem_write) : _we_dm;
    assign dm_clk = ~flag ? clk : _clk_ld;
    wire [31:0] rf_wd;
    reg [31:0] led, clock;
    assign cycles = clock;
    assign state = led[1:0];
    reg mmio_flag;
    assign _dout_dm = dm_rd;
    

    control control_isnt(.opcode(opcode), .cc(alu_flag), .funct3(funct3), .funct7(funct7), .branch(branch), .reg_sel(reg_sel), .pc_sel(pc_sel), .mem_write(mem_write), .alu_src(alu_src), .alu_op(alu_op), .reg_write(reg_write));
    reg_file_sel rf_sel_inst(.reg_sel(reg_sel), .alu_out(alu_out), .pc(pc), .dm_rd(dm_rd), .ext_imm(ext_imm), .rf_wd(rf_wd));
    next_pc_sel npc_sel_inst(.pc_sel(pc_sel), .alu_out(alu_out), .pc(pc), .ext_imm(ext_imm), .npc(npc_temp));
    reg_file rf_inst(.clk(clk), .ra0(_r_addr), .ra1(rf_rs1), .ra2(rf_rs2), .rd0(_dout_rf), .rd1(rf_rd1), .rd2(rf_rd2), .wa(rf_rd), .wd(rf_wd), .we(reg_write));
    data_mem data_mem_inst(.a(dm_addr), .d(dm_d), .clk(dm_clk), .we(dm_we), .spo(dm_rd));
    inst_mem inst_mem_inst(.a(_r_addr), .d(_din), .dpra(pc[11:2]), .clk(dm_clk), .we(_we_im), .spo(_dout_im), .dpo(ir));

    //parameter IMPL = 2'b00;
    //parameter RUN = 2'b01;

    //state
    reg [1:0] ns, cs;

    always@(*) begin        
        if ((dm_addr == 16'h7f00) || (dm_addr == 16'h7f20)) begin
            mmio_flag = 1;
        end
        else begin
            mmio_flag = 0;
        end
    end
    
    always@(posedge clk) begin
        if (~rstn) begin
            clock <= 0;
            pc <= 0;
        end
        else begin
            clock <= clock + 1;
            pc <= npc;
        end
        if(mem_write) begin
            if (dm_addr == 16'h7f00) begin
                led <= dm_d;
            end
            if (dm_addr == 16'h7f20) begin
                clock <= dm_d;
            end
        end
    end

endmodule