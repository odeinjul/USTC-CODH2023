module branch_control(
        input [6:0] opcode,
        input [2:0] cc,
        input [2:0] funct3,
        output reg branch
    );
    parameter B_TYPE = 7'b1100011; // BEQ, BLT, BLTU
    always @(*) begin
        if(opcode != B_TYPE)
            branch = 0;
        else begin
            case(funct3)
                0: branch = cc[0]; // BEQ
                4: branch = cc[1]; // BLT
                6: branch = cc[2];
                default: branch = 0;
            endcase
        end
    end
endmodule