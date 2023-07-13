module  sort_with_sdu (
    input  clk, 		//时钟
    input  rstn, 		//复位
    input run,		    //启动排序
    output  done,		//排序结束标志
    output [15:0]  cycles,	//排序耗费时钟周期数
    //SDU_DM接口
    input [7:0] addr,	//读/写地址
    output [31:0] dout,	//读取数据
    input [31:0] din,	//写入数据
    input we,		    //写使能
    input clk_ld		//写时钟
);
reg we_srt;
reg [7:0] a;
reg [31:0] d;
wire [31:0] spo;
wire [31:0] dpo;
wire [7:0] dpra;

reg [15:0] cnt; //cycles

wire larger;
wire [31:0] real_spo;

reg swaped;
reg finish;
reg [31:0] temp; //for swap
reg [31:0] i, n;


wire clk_me;
wire [7:0] a_me;
wire [31:0] d_me;
wire we_me;
reg flag;
assign clk_me = flag ? clk : clk_ld;
assign a_me = flag ? a : addr;
assign d_me = flag ? d : din;
assign we_me = flag ? we_srt : we;
assign dout = spo;

assign cycles = cnt;
assign done = finish;



dist_mem_gen_0 mem_inst(
    .a(a_me),
    .dpra(dpra),
    .d(d_me),
    .clk(clk_me),
    .we(we_me),
    .spo(spo),
    .dpo(dpo)
);

reg [3:0] ns, cs; 
assign state = ns;
parameter IDLE = 3'b000;
parameter M1 = 3'b001;
parameter M2 = 3'b010;
parameter M3 = 3'b011;
parameter M4 = 3'b100;
parameter M5 = 3'b101;


// 状态转移
always@(posedge clk or negedge rstn) begin
    if (~rstn)
        cs <= IDLE;
    else
        cs <= ns;
end

// 次态切换
always@(*) begin
    ns = cs;
    case (cs)
        IDLE: begin
            if (run) begin
                ns = M1;
            end
        end
        M1:
            ns = M2;
        M2: begin
            if (i == n + 1 | ~swaped)
                ns = M5;
            else
                ns = M3;
        end
        M3: begin
            if (a == n - i + 2)
                ns = M2;
            else if (larger)
                ns = M4;
            else
                ns = M3;
        end
        M4: begin
            ns = M3;
        end
        M5: begin   //finish, display cycles
            ns = M5;
        end
    endcase
end


/* 
for (int i = 1; i <= n; i++)
for (int j = 1; j <= n - i + 1; j++)
if(M[j] > M[j+1]) temp = M[j], M[j] = M[j+1], M[j+1] = temp
*/
assign dpra = a + 1; //dpra = j+1, a = j, spo=M[j], dpo=M[j+1]
assign real_spo = we_srt ? d : spo;  //write first
assign larger = (real_spo <= dpo) ? 0 : 1; //larger -> swap

always@(posedge clk or negedge rstn)
begin
    if(~rstn)
    begin // default state for sdu
        a <= 0; //For MEM[0]
        finish <= 1;
        swaped <= 0;
        flag <= 0;
        cnt <= 0;
        n <= 0;
        i <= 1;
        cnt <= 0;
        we_srt <= 0;
        temp <= 0;
        d <= 0;
    end
    else
    case (cs)
    IDLE: begin // default state for sdu
        a <= 0; //For MEM[0]
        finish <= 1;
        swaped <= 0;
        flag <= 0;
        cnt <= 0;
        n <= 0;
        i <= 1;
        cnt <= 0;
        we_srt <= 0;
        temp <= 0;
        d <= 0;
    end

    M1: begin // init
        finish <= 0;
        n <= spo;
        i <= 1;
        swaped <= 1;
        flag <= 1;
        cnt <= cnt + 1;
    end

    M2: begin // check
        we_srt <= 0;
        a <= 1;
        swaped <= 0;
        cnt <= cnt + 1;
    end

    M3: begin // swap
        if(a != n - i + 2 && larger) begin //-> M4 -> M3 to swap, M[j] = M[j+1], temp = M[j]
            swaped <= 1;
            d <= dpo;
            we_srt <= 1;
            temp <= real_spo;
        end
        else if(a == n - i + 2)begin // -> M2
            a <= 1; //a = j =1 
            we_srt <= 0;
            i <= i + 1; //i = i + 1
            swaped <= 1;
        end
        else begin //-> M4, a = j = j + 1
            we_srt <= 0;
            a <= a + 1;
        end
        cnt <= cnt + 1;
    end

    M4: begin 
        a <= a + 1; // M[j+1] = temp = M[j], j = j + 1
        d <= temp;
        we_srt <= 1;
        cnt <= cnt + 1;
    end

    M5: begin
        finish <= 1;
        flag <= 0;
    end

endcase
end

endmodule 
