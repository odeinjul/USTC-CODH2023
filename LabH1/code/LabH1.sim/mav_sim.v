module mav_sim();
    reg clk;
    reg rstn;
    reg en;
    reg[15:0] d;
    wire[15:0] m;
    wire [2:0] cs;
    wire [15:0] sum; 
    mav mav_inst(clk, rstn, en, d, m);

    initial 
    begin
        rstn = 0;
        #7 rstn = ~rstn;
    end

    initial
    begin
        clk = 0;
        forever
            #5 clk = ~clk;
            #5 clk = ~clk;
            en = ~en;
    end
    initial
        begin
            en = 0;
            forever
                #10 en = ~en;
        end
    initial
    begin
        d = 31'o2;
        #20 d = 31'o3;
        #20 d = 31'o4;
        #20 d = 31'o5;
        #20 d = 31'o6;
        #30 $finish;
    end
endmodule
