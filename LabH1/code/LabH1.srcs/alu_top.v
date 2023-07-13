module alu_top(
        input [15:0] sw,
        output [15:13] ledf,
        output [5:0] ledy
    );
    alu #(.WIDTH(6)) alu_inst(.a(sw[11:6]), .b(sw[5:0]), .s(sw[15:13]), .y(ledy), .f(ledf));
endmodule