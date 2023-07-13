module mav_top (
    input  clk, 
    input  rstn, 
    input  en,
    input  [15:0]  d,
    output [15:0]  m,
    output [7:0] AN,
    output CA, CB, CC, CD, CE, CF, CG
);
    wire out;
    integer t = 0;
    reg [7:0] in_temp, AN_temp;
    fix_edge edge_inst1(clk, en, out);
    mav mav_inst1(clk, rstn, out, d, m);

    encode encode_inst(
        .in(in_temp),
        .out1(CA),
        .out2(CB),
        .out3(CC),
        .out4(CD),
        .out5(CE),
        .out6(CF),
        .out7(CG)
    );
    
    always @ (posedge clk)
    begin
        if(t % 100000 == 0)
        begin
            t = 0;
            case(AN)
                8'b11111110: begin AN_temp = 8'b11111101; in_temp = m[7:4]; end
                8'b11111101: begin AN_temp = 8'b11111011; in_temp = m[11:8]; end
                8'b11111011: begin AN_temp = 8'b11110111; in_temp = m[15:12]; end
                default: begin AN_temp = 8'b11111110; in_temp = m[3:0]; end
           endcase
        end
        t = t + 1;
    end
    assign AN = AN_temp;
endmodule