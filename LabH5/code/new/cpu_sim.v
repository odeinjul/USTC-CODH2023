module cpu_sim();
    reg clk, rstn;
    initial begin
        clk = 0;
        rstn = 0;
        forever
            #5 clk = ~clk;
    end

    initial begin
        rstn = 0;
        #10 rstn = 1;
    end
    cpu cpu_inst(.clk(clk), .rstn(rstn));
endmodule