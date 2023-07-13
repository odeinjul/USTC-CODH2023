module reg_sim();
    reg clk;
    reg we;
    reg [4:0] ra1, ra2;
    reg [4:0] wa;
    reg [31:0] wd;
    wire [31:0] rd1, rd2;

    register_file reg_inst (
        .clk(clk),
        .ra1(ra1),
        .ra2(ra2),
        .rd1(rd1),
        .rd2(rd2),
        .wa(wa),
        .wd(wd),
        .we(we)
    );



    initial
    begin
        clk = 0;
        forever
            #5 clk = ~clk;
    end

    initial
    begin
            we = 0;
            forever
            #10 we = ~we;
    end

   initial
    begin
        ra1 = 5'o0;
        ra2 = 5'o3;
        #50 ra1 = 5'o4; ra2 = 5'o5;

        #50 $finish;
    end

    initial
    begin
        wa = 5'o0;
        wd = 31'o1;
        #10 wd = 31'o3; wa = 5'o3;
        #20 wd = 31'o4; wa = 5'o4;
        #20 wd = 31'o5; wa = 5'o5;
        #50 $finish;
    end
endmodule
