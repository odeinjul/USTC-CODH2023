module parse(
    input [9:0] addr,
    output [1:0] offset,
    output [4:0] index,
    output [2:0] tag
);
    assign offset = addr[1:0];
    assign index = addr[6:2];
    assign tag = addr[9:7];
endmodule

// 分布式存储器，总容量1KB
// 块大小：4 words (16 byte = 128 bits)
// 1024 / 16 = 64 块
// 32块 * 4words * 2
// offset 
// 2路组相联

// [9:0] addr 
// word addr
// offset [1:0]
// index: [4:0]
// tag: [9:7]