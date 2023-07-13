module control(
        input [6:0] opcode,
        input [2:0] funct3,
        input [6:0] funct7,
        output reg [2:0] reg_sel,
        output reg [2:0] pc_sel,
        output reg mem_write,
        output reg alu_src,
        output [2:0] alu_op,
        output reg reg_write
    );
    parameter R_TYPE = 7'b0110011; // ADD, SUB, AND, OR, XOR
    parameter I_TYPE = 7'b0010011; // ADDI, SLLI, SRLI, SRAI
    parameter I_LOAD = 7'b0000011; // LW
    parameter S_TYPE = 7'b0100011; // SW
    parameter I_JALR = 7'b1100111; // JALR
    parameter B_TYPE = 7'b1100011; // BEQ, BLT, BLTU
    parameter U_LUI = 7'b0110111; // LUI
    parameter U_AUIPC = 7'b0010111; //AUIPC
    parameter J_JAL  = 7'b1101111; // JAL

    parameter FALSE = 1'b0;
    parameter TRUE = 1'b1;

    parameter rf_rd2 = 1'b0;
    parameter ext_imm = 1'b1;

    parameter next_pc = 3'b000;
    parameter mem_out = 3'b001;
    parameter alu_out = 3'b010;
    parameter imm_pc = 3'b011;
    parameter imm_only = 3'b100;
    always @(*) begin
        case(opcode)
            R_TYPE: begin
                reg_sel = alu_out; // alu
                pc_sel = next_pc; // pc + 4
                mem_write = FALSE; 
                alu_src = rf_rd2; //rf_rd2
                reg_write = TRUE;
            end
            I_TYPE: begin
                reg_sel = alu_out; // alu
                pc_sel = next_pc; // pc + 4
                mem_write = FALSE;
                alu_src = ext_imm; //ext_imm
                reg_write = TRUE;
            end
            I_LOAD: begin
                reg_sel = mem_out; // mem
                pc_sel = next_pc; // pc + 4
                mem_write = FALSE;
                alu_src = ext_imm; //ext_imm
                reg_write = TRUE;
            end
            I_JALR: begin
                reg_sel = next_pc; // pc + 4
                pc_sel = alu_out; // alu_out, rs1 + imm
                mem_write = FALSE;
                alu_src = ext_imm; //ext_imm
                reg_write = TRUE;
            end
            S_TYPE: begin
                //reg_sel = 0; // mem
                pc_sel = next_pc; // pc + 4
                mem_write = TRUE;
                alu_src = ext_imm; 
                reg_write = FALSE;
            end
            B_TYPE: begin
                //reg_sel = 0; // alu
                pc_sel = imm_pc;
                mem_write = FALSE;
                alu_src = rf_rd2; //-> cc -> branch
                reg_write = FALSE;
            end
            U_LUI: begin
                reg_sel = imm_only; // pc + imm
                pc_sel = next_pc; // pc + 4
                mem_write = FALSE;
                alu_src = ext_imm;
                reg_write = TRUE;
            end
            U_AUIPC: begin
                reg_sel = imm_pc; // pc + imm
                pc_sel = next_pc; // pc + 4
                mem_write = FALSE;
                alu_src = ext_imm;
                reg_write = TRUE;
            end
            J_JAL: begin
                reg_sel = next_pc; // pc + 4
                pc_sel = imm_pc; // pc + imm
                mem_write = FALSE;
                //alu_src = 0;
                reg_write = TRUE;
            end
            default: begin
                reg_sel = 0;
                pc_sel = 0;
                mem_write = 0;
                alu_src = 0;
                reg_write = 0;
            end
        endcase
    end
    alu_control alu_control_inst(opcode, funct3, funct7,  alu_op);

endmodule