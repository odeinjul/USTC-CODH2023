module stall_flush (
    input branch,
    input [6:0] opcode,
    input [4:0] ire, rf_rs1, rf_rs2,
    output reg stall, flush
);
    parameter J_JAL = 7'b1101111; // JAL
    // parameter B_TYPE = 7'b1100011; // BEQ, BLT, BLTU
    parameter I_JALR = 7'b1100111; // JALR
    parameter I_LOAD = 7'b0000011; // LW

    always@(*) begin
        if ((opcode == I_LOAD) && ((ire == rf_rs1) || (ire == rf_rs2)))
            stall = 1;
        else
            stall = 0;

        if (branch || (opcode == J_JAL) || (opcode == I_JALR)) begin
            flush = 1;
        end

        else begin
            flush = 0;
        end
    end
endmodule