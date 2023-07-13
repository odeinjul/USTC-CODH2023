module alu_sim();
    integer i;
    reg [31:0] a;
    reg [31:0] b;
    reg [2:0] s;
    wire [31:0] y;
    wire [2:0] f;
    alu alu_inst(a, b, s, y, f);

    initial 
    begin
        a = $random;
        b = $random;
        s = 0;
    end

    initial
    begin
        for(i=0; i<8; i=i+1)
        begin
            #5 s = s + 1;
        end
    $finish;
    end
endmodule
