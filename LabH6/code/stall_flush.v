module stall_flush (
    input branch,
    input [6:0] opcode,
    input [31:0] addr, MEM_addr,
    input [4:0] ire, rf_rs1, rf_rs2,
    input w_valid, r_valid, w_ready, r_ready,
    output reg stall, flush, cache_stall
);
    parameter J_JAL = 7'b1101111; // JAL
    // parameter B_TYPE = 7'b1100011; // BEQ, BLT, BLTU
    parameter I_JALR = 7'b1100111; // JALR
    parameter I_LOAD = 7'b0000011; // LW

    always@(*) begin
        /*if (opcode == I_LOAD) // ((ire == rf_rs1) || (ire == rf_rs2) load -> stall
            if(addr[31: 8] == 24'h000000)
                stall = 1;
            else 
                stall = 0;
        else 
            */
        stall = 0;
        if ((w_valid && ~w_ready) || (r_valid && ~r_ready))
            if(MEM_addr[31: 8] != 24'h000000)
                cache_stall = 1;
            else 
                cache_stall = 0;
        else 
            cache_stall = 0;

        if (branch || (opcode == J_JAL) || (opcode == I_JALR)) begin
            flush = 1;
        end

        else begin
            flush = 0;
        end
    end
endmodule