module imm_gen (
    input [31:0] raw,
    input [6:0] opcode,
    input [2:0] funct3,
    output reg [31:0] ext_imm
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

always @(*) begin
    case(opcode)
        R_TYPE: ext_imm = 0;
        I_TYPE: begin
            if (funct3)
                ext_imm = {{20{raw[24]}}, raw[24:20]};
            else 
                ext_imm = {{20{raw[31]}}, raw[31:20]};
        end
        I_JALR: ext_imm = {{20{raw[31]}}, raw[31:20]};
        I_LOAD: ext_imm = {{20{raw[31]}}, raw[31:20]};
        S_TYPE: ext_imm = {{20{raw[31]}}, raw[31:25], raw[11:7]};
        B_TYPE: ext_imm = {{19{raw[31]}}, raw[31], raw[7], raw[30:25], raw[11:8], {1'b0}};
        U_LUI: ext_imm = {raw[31:12], 12'b0};
        U_AUIPC: ext_imm = {raw[31:12], 12'b0};
        J_JAL: ext_imm = {{11{raw[31]}}, raw[31], raw[19:12], raw[20], raw[30:21], {1'b0}};
        default: ext_imm = 0;
    endcase
end
endmodule
