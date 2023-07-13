module rdata_mux (
    input hit1, hit2,
    input [127:0] r_data1, r_data2,
    output [127:0] r_data
);
    assign r_data = hit1 ? r_data1 : r_data2;
    //hit1 = 0, hit2 = 0 -> r_data = r_data2
endmodule