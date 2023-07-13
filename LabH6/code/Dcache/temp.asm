.text
main:

    call check_seg
    addi a0, zero, 1
    sw a0, 0x0c(zero)

    call check_swx
    lw a6, 0x14(zero)

    call check_seg
    addi a0, zero, 2
    sw a0, 0x0c(zero)

    call check_swx
    lw a7, 0x14(zero)
    mv t0, a6
    mv t1, a7
    # a6 - n, a7 - first num

    addi t5, zero, 2
    slli t5, t5, 12 # t5 = 0x2000

    sw t0, 0(t5)
    addi t5, t5, 4

loop: 
    beq t0, zero, sort_wait
    sw t1, 0(t5)

    addi t2, zero, 1 #t2 -> 0x1
    slli t2, t2, 9
    and t3, t1, t2    #t3 = t1[9]
    srli t3, t3, 9    #-> [0]

    # addi t2, zero, 0x1 //t2 -> 0x1
    srli t2, t2, 3
    and t4, t1, t2    # t4 = t1[6]
    srli t4, t4, 6    

    addi t2, zero, 1 
    sub t0, t0, t2
    xor t3, t3, t4
    xor t3, t3, t2   # t3 = t1[9] ^ t1[6] ^ 1
    slli t3, t3, 11

    srli t1, t1, 1
    add t1, t1, t3  # t1 = {t3, t1 >> 1}

    addi t5, t5, 4
    jal loop

sort_wait:
    call sort
    lw a0, 0x18(zero)
    call check_seg
    sw a0, 0x0c(zero)

sort:
    mv t0, a6
    addi a0, zero, 2
    slli a0, a0, 12 
    # t0 - n
    # a0 - 0x2000
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

check_seg:
    lw t0, 0x4(zero)
    addi t1, zero, 1
    beq t0, t1, return_from_check_seg
    jal check_seg
return_from_check_seg:
    ret

check_swx:
    lw t0, 0x10(zero)
    addi t1, zero, 1
    beq t0, t1, return_from_check_swx
    jal check_swx
return_from_check_swx:
    ret
