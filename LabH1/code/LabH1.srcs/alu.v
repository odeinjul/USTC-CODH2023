module alu #(
    parameter WIDTH = 32      //数据宽度
)(
    input [WIDTH-1:0] a, b,     //两操作数
    input [2:0] f,            //功能选择
    output reg [WIDTH-1:0] y,     //运算结果
    output reg [2:0] t            //比较标志
);

always @ (*)
begin
    t = 3'b000;
    case(f)
    3'b000: 
    //t[0] = 1 if a eq b
    //t[1] = 1 if a < b (signed)
    //t[2] = 1 if a < b (unsigned)
    begin
        y = a - b; 
        if(y == 0)
            t[0] = 1;
        if(a < b)
            t[2] = 1;
        if($signed(a) < $signed(b))
            t[1] = 1;
    end
    3'b001: y = a + b;
    3'b010: y = a & b;
    3'b011: y = a | b;
    3'b100: y = a ^ b;
    3'b101: y = a >> b;
    3'b110: y = a << b;
    3'b111: y = $signed(a) >>> b; 
    endcase
end

endmodule
