module next_pc_sel(
        input [2:0] pc_sel,
        input [31:0] alu_out,
        input [31:0] pc,
        input [31:0] ext_imm,
        output reg [31:0] npc
    );

    parameter ALU_OUT = 3'b000;
    parameter MEM_OUT = 3'b001;
    parameter NEXT_PC = 3'b010;
    parameter IMM_PC = 3'b011;
    parameter IMM_ONLY = 3'b100;

    always@(*) begin
        case (pc_sel)
            ALU_OUT: npc = alu_out;
            NEXT_PC: npc = pc + 4;
            IMM_PC: npc = pc + ext_imm;
        endcase
    end
endmodule