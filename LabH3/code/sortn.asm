.data 
n:      .word 0x10
array:  .word 0xf 0xe 0xd 0xc 0xb 0xa 0x9 0x8 0x7 0x6 0x5 0x4 0x3 0x2 0x1 0x0

.text 
main:
    la a0, array
    lw a1, n
    call sort
end:
    jal end
sort:
    mv t0, a1
    slli t0, t0, 0x2
    addi t6, zero, 0x8
outer_loop:
    addi t0, t0, -0x4
    addi t1, zero, 0
inner_loop: 
    add t2, a0, t1
    addi t1, t1, 0x4
    lw t3, 0(t2)
    lw t4, 0x4(t2)
    blt t3, t4, inner_loop_end
    sw t4, 0(t2)
    sw t3, 0x4(t2)
inner_loop_end:
    blt t1, t0, inner_loop
    blt t0, t6, srt_end
    jal zero, outer_loop
srt_end:
    ret



