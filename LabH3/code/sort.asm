.data 
n:      .word 0x10
array:  .word 0xf 0xe 0xd 0xc 0xb 0xa 0x9 0x8 0x7 0x6 0x5 0x4 0x3 0x2 0x1 0x0
bef: .string "Before Sort:\n"
aft: .string "After Sort:\n"
return: .string "\n"

.text 
main:
    la a0, bef
    li a7, 4
    ecall
    la a0, array
    lw a1, n
    call print

    la a0, array
    lw a1, n
    call sort

    la a0, aft
    li a7, 4
    ecall
    la a0, array
    lw a1, n
    call print
    # exit
    li a7, 10
    ecall

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
    bge t0, t6, outer_loop
    ret



print:
    mv t0, a0
    mv t1, a1 
    slli t1, t1, 2
    addi t2, zero, 0
loop:
    add t3, t0, t2
    lw a0, 0(t3)
    addi t2, t2, 0x4 
    li a7, 1
    ecall
    la a0, return
    li a7, 4
    ecall
    blt t2, t1, loop
    ret

