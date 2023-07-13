module forward (
    input [4:0] EX_rs1, EX_rs2, MEM_rd, WB_rd,
    input MEM_reg_write, WB_reg_write,
    input [2:0] MEM_reg_sel, WB_reg_sel,
    input [31:0] EX_a, EX_b, MEM_alu_out, WB_rf_wd, MEM_pc, MEM_dm_rd, MEM_imm,
    output reg [31:0] alu_in1, alu_in2
);

    parameter NEXT_PC = 3'b000;
    parameter MEM_OUT = 3'b001;
    parameter ALU_OUT = 3'b010;
    parameter IMM_PC = 3'b011;
    parameter IMM_ONLY = 3'b100;
    always@(*) begin
        if (MEM_rd == EX_rs1 && (MEM_rd != 0) && MEM_reg_write) begin
            case (MEM_reg_sel)
                ALU_OUT: alu_in1 = MEM_alu_out;
                NEXT_PC: alu_in1 = MEM_pc + 4;
                MEM_OUT: alu_in1 = MEM_dm_rd;
                IMM_PC: alu_in1 = MEM_pc + MEM_imm;
                IMM_ONLY: alu_in1 = MEM_imm;
            endcase
        end
        else if (WB_rd == EX_rs1 && (WB_rd != 0) && WB_reg_write) begin
            alu_in1 = WB_rf_wd;
        end
        else
            alu_in1 = EX_a;
            
        if (MEM_rd == EX_rs2 && (MEM_rd != 0) && MEM_reg_write) begin
            case (MEM_reg_sel)
                ALU_OUT: alu_in2 = MEM_alu_out;
                NEXT_PC: alu_in2 = MEM_pc + 4;
                MEM_OUT: alu_in2 = MEM_dm_rd;
                IMM_PC: alu_in2 = MEM_pc + MEM_imm;
                IMM_ONLY: alu_in2 = MEM_imm;
            endcase
        end
        else if (WB_rd == EX_rs2 && (WB_rd != 0) && WB_reg_write) begin
            alu_in2 = WB_rf_wd;
        end 
        else
            alu_in2 = EX_b;
    end
endmodule