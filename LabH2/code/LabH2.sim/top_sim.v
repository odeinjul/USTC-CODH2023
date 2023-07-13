module top_sim();
    reg clk;
    reg rstn;
    reg run;
    wire done;
    wire [15:0] cycles;
    wire txd, rxd;

    top top_inst (
        .clk(clk),
        .rstn(rstn),
        .run(run),
        .done(done),
        .cycles(cycles),
        .txd(txd),
        .rxd(rxd)
    );



    initial
    begin
        clk = 0;
        forever
            #2 clk = ~clk;
    end

    initial
    begin
            run = 0; rstn = 1;
            #2 run = ~run; rstn = ~rstn;
            #2 rstn = ~ rstn;
    end
endmodule
