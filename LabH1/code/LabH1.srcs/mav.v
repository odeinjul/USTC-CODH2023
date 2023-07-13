module  mav (
    input  clk, 
    input  rstn, 
    input  en,
    input  [15:0]  d,
    output reg [15:0]  m
);
//CONST NAME for state
    parameter IDLE = 3'b000;
    parameter M1 = 3'b001;
    parameter M2 = 3'b010;
    parameter M3 = 3'b011;
    parameter M4 = 3'b100;
    reg [2:0] ns, cs;
    wire [15:0] temp1, temp2, temp3, res;
    reg [15:0] m0, m1, m2, m3;
    alu #(.WIDTH(16)) alu_inst1(d, m0, 3'b001, temp1);
    alu #(.WIDTH(16)) alu_inst2(m1, m2, 3'b001, temp2);
    alu #(.WIDTH(16)) alu_inst3(temp1, temp2, 3'b001, temp3);
    alu #(.WIDTH(16)) alu_inst4(temp3, 16'o2, 3'b111, res);
    //reg [17:0] m0;
    //assign su = sum;
    always@(posedge clk or negedge rstn) begin
        if(~rstn)
            cs <= 3'b000;
        else
            cs <= ns;
    end
    //复位后m=0，前3次en有效时，m依次输出m0、m1和m2 (= d) 
    //随后en有效时，m依次输出：mi = (d+mi-1+mi-2+mi-3)/4, i≥3
    always@(*) begin
        ns = cs;
        if(en) begin
            case(cs)
                IDLE: 
                begin
                    ns = M1;
                end
                M1: 
                begin
                    ns = M2;
                end
                M2: 
                begin
                    ns = M3;
                end
                M3: 
                begin
                    ns = M4;
                end
                M4: 
                begin
                    ns = M4;
                end
                default: 
                begin
                    ns = IDLE;
                end
        endcase
        end
    end

    always@(posedge clk or negedge rstn) begin
        if(~rstn) begin
                m0 <= 16'b0;
                m1 <= 16'b0;
                m2 <= 16'b0;
                m3 <= 16'b0;
                m <= 16'b0;
        end
        else if(en) begin
            m0 <= d;
            m1 <= m0;
            m2 <= m1;
            m3 <= m2;
            if(ns == 3'b100) begin
                m <= res;
            end
            else
                m <= d;
        end
    end
endmodule