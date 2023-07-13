module reg_file_sel(
        input [2:0] reg_sel,
        input [31:0] alu_out,
        input [31:0] pc,
        input [31:0] dm_rd,
        input [31:0] ext_imm,
        output reg [31:0] rf_wd
    );

    parameter NEXT_PC = 3'b000;
    parameter MEM_OUT = 3'b001;
    parameter ALU_OUT = 3'b010;
    parameter IMM_PC = 3'b011;
    parameter IMM_ONLY = 3'b100;

    always@(*) begin

        case (reg_sel)
            ALU_OUT: rf_wd = alu_out;
            NEXT_PC: rf_wd = pc + 4;
            MEM_OUT: rf_wd = dm_rd;
            IMM_PC: rf_wd = pc + ext_imm;
            IMM_ONLY: rf_wd = ext_imm;
            endcase
    end
endmodule