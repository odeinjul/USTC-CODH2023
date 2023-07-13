module alu_control(
        input [6:0] opcode,
        input [2:0] funct3,
        input [6:0] funct7,
        output reg [2:0] alu_op);

    parameter R_TYPE = 7'b0110011; // ADD, SUB, AND, OR, XOR
    parameter I_TYPE = 7'b0010011; // ADDI, SLLI, SRLI, SRAI
    parameter I_LOAD = 7'b0000011; // LW
    parameter S_TYPE = 7'b0100011; // SW
    parameter I_JALR = 7'b1100111; // JALR
    parameter B_TYPE = 7'b1100011; // BEQ, BLT, BLTU
    parameter U_LUI = 7'b0110111; // LUI
    parameter U_AUIPC = 7'b0010111; //AUIPC
    parameter J_JAL  = 7'b1101111; // JAL

    parameter SUB = 3'b000;
    parameter ADD = 3'b001;
    parameter AND = 3'b010;
    parameter OR  = 3'b011;
    parameter XOR = 3'b100;
    parameter SRL = 3'b101;
    parameter SL = 3'b110;
    parameter SRA = 3'b111;

    always @(*) begin
        case(opcode)
            R_TYPE : begin
                case(funct3)
                    3'b000: alu_op = (funct7 == 0) ? ADD : SUB; //add, sub
                    3'b100: alu_op = XOR; //xor
                    3'b110: alu_op = OR; //or
                    3'b111: alu_op = AND; //and
                endcase
            end
            I_TYPE: begin
                case(funct3)
                    3'b000: alu_op = ADD;    // addi
                    3'b001: alu_op = SL;    // slli
                    3'b101: alu_op = (funct7 == 0) ? SRL : SRA; // srli, srai
                endcase
            end
            B_TYPE: alu_op = SUB;
            default: alu_op = ADD;
        endcase
    end
endmodule