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
        else if (cnt < 16'h20)
            cnt <= cnt + 1;
        en1 <= cnt[5];
        en2 <= en1;
    end
    assign out = en1 & ~en2;
endmodule
