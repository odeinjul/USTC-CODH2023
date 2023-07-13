module write_data (
    input [31:0] w_word,
    input [127:0] cache_data,
    input w_valid,
    input [1:0] offset,
    output reg [127:0] w_data
);
always@(*)
begin
    case(offset)
        2'b00: begin w_data = w_valid ? {cache_data[127:32], w_word} : cache_data; end
        2'b01: begin w_data = w_valid ? {cache_data[127:64], w_word, cache_data[31:0]} : cache_data; end
        2'b10: begin w_data = w_valid ? {cache_data[127:96], w_word, cache_data[63:0]} : cache_data; end
        2'b11: begin w_data = w_valid ? {w_word, cache_data[95:0]} : cache_data; end
    endcase
end
endmodule