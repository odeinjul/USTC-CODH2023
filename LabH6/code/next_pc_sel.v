module next_pc_sel(
        input [2:0] pc_sel,
        input branch, cache_stall,
        input [31:0] alu_out,
        input [31:0] pc,
        input [31:0] ext_imm,
        input [6:0] opcode,
        output reg [31:0] npc
    );
    parameter B_TYPE = 7'b1100011; // BEQ, BLT, BLTU
    parameter J_JAL  = 7'b1101111; // JAL
    parameter NEXT_PC = 3'b000;
    parameter MEM_OUT = 3'b001;
    parameter ALU_OUT = 3'b010;
    parameter IMM_PC = 3'b011;
    parameter IMM_ONLY = 3'b100;

    always@(*) begin
        if(cache_stall)
            npc = pc;
        else begin
        case (pc_sel)
            ALU_OUT: npc = alu_out;
            NEXT_PC: npc = pc + 4;
            IMM_PC: begin
                if(opcode == B_TYPE)
                    npc = branch ? pc - 8 + ext_imm : pc + 4;
                else if (opcode == J_JAL)
                    npc = pc - 8 + ext_imm;
            end
            default: npc = pc + 4;
        endcase
        end
    end
endmodule