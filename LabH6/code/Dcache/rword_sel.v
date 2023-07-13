module rword_sel (
    input [1:0] offset,
    input [127:0] r_data,
    output reg [31:0] r_word
);
    always@(*)
    begin
        case (offset)
        2'b00: r_word = r_data[31:0];
        2'b01: r_word = r_data[63:32];
        2'b10: r_word = r_data[95:64];
        2'b11: r_word = r_data[127:96];
        endcase
    end
    //hit1 = 0, hit2 = 0 -> r_data = r_data2
endmodule