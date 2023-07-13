module mav_fpga_top (
    input  clk, 
    //input  rstn, 
    input  en,
    input  [7:0]  d,
    output [7:0]  m
);
    wire out;
    fix_edge edge_inst1(clk, en, out);
    mav_fpga mav_inst1(clk, 1'b1, out, d, m);
endmodule