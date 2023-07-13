module fix_edge(
    input clk, en,
    output out
);
    reg [15:0] cnt;
    reg en1, en2;
    always@(posedge clk)
    begin
        if (en == 0)
            cnt <= 0;
        else if (cnt < 16'h8000)
            cnt <= cnt + 1;
        en1 <= cnt[15];
        en2 <= en1;
    end
    assign out = en1 & ~en2;
endmodule
