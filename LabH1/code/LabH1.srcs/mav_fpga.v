module  mav_fpga (
    input  clk, 
    input  rstn, 
    input  en,
    input  [7:0]  d,
    output reg [7:0]  m
);
    reg [2:0] ns;
    reg [2:0] cs;
    wire [7:0] temp1, temp2, res;
    reg [7:0] m0, m1, m2, m3, sum;
    wire [2:0] a,b,c;
    alu #(.WIDTH(8)) alu_inst1(sum, d, 3'b001, temp1,a);
    alu #(.WIDTH(8)) alu_inst2(temp1, m3, 3'b000, temp2, b);
    alu #(.WIDTH(8)) alu_inst3(temp2, 8'o2, 3'b111, res, c);
    always@(posedge clk or negedge rstn)
    begin
        if(~rstn)
            cs <= 3'b000;
        else
            cs <= ns;
    end
    //复位后m=0，前3次en有效时，m依次输出m0、m1和m2 (= d) 
    //随后en有效时，m依次输出：mi = (d+mi-1+mi-2+mi-3)/4,  i≥3
    always@(*)
    begin
        ns = cs;
        case(cs)
        3'b000: 
        begin
            if(en)
                ns = 3'b001;
        end
        3'b001: 
        begin
            if(en)
                ns = 3'b010;
        end
        3'b010: 
        begin
            if(en)
                ns = 3'b011;
        end
        3'b011: 
        begin
            if(en)
                ns = 3'b100;
        end
        3'b100: 
        begin
            if(en)
                ns = 3'b101;
        end
        endcase
    end

    always@(posedge clk or negedge rstn)
    begin
        if(~rstn)
            begin
                m0 <= 8'b0;
                m1 <= 8'b0;
                m2 <= 8'b0;
                m3 <= 8'b0;
                sum <= 8'b0;
                m <= 8'b0;
            end
        else
            if(en)
            begin
            case(ns)
            3'b000: 
            begin
                m0 <= 8'b0;
                m1 <= 8'b0;
                m2 <= 8'b0;
                m3 <= 8'b0;
                sum <= 8'b0;
                m <= 8'b0;
            end
            3'b001: 
            begin
                m0 <= d;
                sum <= temp1;
                m <= d;
            end
            3'b010: 
            begin
                m0 <= d;
                m1 <= m0;
                sum <= temp1;
                m <= d;
            end
            3'b011: 
            begin
                m0 <= d;
                m1 <= m0;
                m2 <= m1;
                sum <= temp1;
                m <= d;
            end
            3'b100: 
            begin
                m0 <= d;
                m1 <= m0;
                m2 <= m1;
                m3 <= m2;
                sum <= temp1;
                m <= res;
            end
            3'b101: 
            begin
                m0 <= d;
                m1 <= m0;
                m2 <= m1;
                m3 <= m2;
                sum <= temp2;
                m <= res;
            end
            default: 
            begin
                m0 <= 8'b0;
                m1 <= 8'b0;
                m2 <= 8'b0;
                sum <= 8'b0;
                m <= 8'b0;
            end
            endcase
            end
    end
endmodule