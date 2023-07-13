module IOU (
    input clk, rstn,
    input [15:0] sw,
    input BTNC, BTNU, BTNL, BTNR, BTND,
    
    input [7:0] io_addr,  // output addr
    input [31:0] io_dout, // output data
    output reg [31:0] io_din,  // input data
    input io_we,          // device write enable
    input io_rd,           // device read control

    output [15:0] led, //；led
    output [7:0] AN,  //seg
    output [6:0] seg,  //seg
    output [31:0] ctr_debug1, ctr_debug3//, ctr_debug3
);

parameter LED_DATA = 8'h00; // led: output 
parameter SWT_DATA = 8'h04; // switch: input
parameter SEG_REDY = 8'h08; // segment ready: input
parameter SEG_DATA = 8'h0C; // segment data: output
parameter SWX_REDY = 8'h10; // switch ready: input
parameter SWX_DATA = 8'h14; // switch data: input
parameter CNT_DATA = 8'h18; // counter data: input & output

wire [31:0] tmp;
reg [31:0] swx_data;
reg [31:0] cnt_data;
reg [15:0] led_data;
reg [31:0] seg_data;
wire BTNC_P, BTNU_P, BTNL_P, BTNR_P, BTND_P;
//swt_data = {BTNC_P, BTNU_P, BTNL_P, BTNR_P, BTND_P, sw[15:0]}
reg seg_rdy, swx_vld;


    always @(posedge clk) begin    //CPU输出
        if (~rstn) begin
            led_data <= 16'hFFFF;
            seg_data <= 32'h12345678;
        end
        else if (io_we) begin
            case (io_addr)
                8'h00:
                    led_data <= io_dout;
                8'h0C:
                    seg_data <= io_dout;
                default: ;
            endcase
        end
    end


    always @(posedge clk) begin
        if (~rstn)
            seg_rdy <= 1;
        else if (io_we & (io_addr == 8'h0C))
            seg_rdy <= 0;
        else if (BTNU_P || BTNL_P || BTND_P)
            seg_rdy <= 1;
    end


    always @(posedge clk) begin
        if (~rstn)
            swx_vld <= 0;
        else if (BTNC_P & ~swx_vld) begin
            swx_data <= tmp;
            swx_vld <= 1;
        end
        else if (io_rd & (io_addr == 8'h14))
            swx_vld <= 0;
    end

    always@(posedge clk) begin
        if(~rstn)
            cnt_data <= 32'h0;
        else
            cnt_data <= cnt_data + 32'h1;
    end

    always @(*) begin  
        case (io_addr)
            8'h04:
                io_din = {{11{1'b0}}, BTNC_P, BTNU_P, BTNL_P, BTNR_P, BTND_P, sw};
            8'h08:
                io_din = {{31{1'b0}}, seg_rdy};
            8'h10:
                io_din = {{31{1'b0}}, swx_vld};
            8'h14:
                io_din = swx_data;
            8'h18:
                io_din = cnt_data;
            default:
                io_din = 32'h0;
        endcase
    end


/* BTN edge fix*/
fix_edge edge_inst1 (
    .clk(clk),
    .en(BTNC),
    .out(BTNC_P)
);

fix_edge edge_inst2 (
    .clk(clk),
    .en(BTNU),
    .out(BTNU_P)
);

fix_edge edge_inst3 (
    .clk(clk),
    .en(BTNL),
    .out(BTNL_P)
);

fix_edge edge_inst4 (
    .clk(clk),
    .en(BTNR),
    .out(BTNR_P)
);

fix_edge edge_inst5 (
    .clk(clk),
    .en(BTND),
    .out(BTND_P)
);

wire [3:0] h;
wire p;
/* switch edge fix and encode */
switch sw_inst1 (
    .clk(clk),
    .rstn(rstn),
    .sw(sw),
    .h(h),
    .p(p)
);

switch_data swd_inst (
    .clk(clk),
    .rstn(rstn),
    .h(h),
    .p(p),
    .btnr(BTNR_P),
    .btnc(BTNC_P),
    .tmp(tmp)
);

wire [31:0] disp_data;
assign disp_data = seg_rdy ? tmp : seg_data;
assign led = led_data;

disp disp_inst (
    .clk(clk),
    .rstn(rstn),
    .disp_data(disp_data),
    .seg(seg),
    .AN(AN)
);
assign ctr_debug1 = seg_rdy;
//assign ctr_debug2 = io_we;
assign ctr_debug3 = cnt_data;
endmodule