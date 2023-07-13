.data
arg0:   .word 0x10
arg1:   .word 0x10
space1: .word 0x0
space2: .word 0x0
arg3:   .word 1
arg4:   .word 2
arg5:   .word -1
arg6:   .word 0x80000000
addr:   .word 0x00000008
ans_auipc: .word 0x10000118 # 0x10000118 = 0x10000000 + 0x118
ans_lui:   .word 0x10000000
ans_srai:  .word 0xc0000000
mmio_addr .word 0x00007f00
.text

main:
    lw a3, mmio_addr
    sw zero, (a3)
    addi a6, zero, 1
    
jal_test:
    jal a3, beq_test
    slli a6, a6, 1
    jal wrong

beq_test:
    beq zero, zero, lw_test
    slli a6, a6, 2
    jal wrong

lw_test:
    lw a0, arg0
    lw a1, arg1
    beq a0, a1, jal_r_test
    slli a6, a6, 3
    jal wrong

jal_r_test:
    lw a5, addr
    beq a3, a5, sw_test
    slli a6, a6, 4
    jal wrong

sw_test:
    sw a0, space1, a2
    sw a1, space2, a2
    lw a0, space1
    lw a1, space2
    beq a0, a1, blt_test
    slli a6, a6, 5
    jal wrong

blt_test: 
    lw a0, arg3
    lw a1, arg4
    blt a0, a1, bltu_test
    slli a6, a6, 6
    jal wrong

bltu_test:
    lw a0, arg5
    bltu a1, a0, add_test
    slli a6, a6, 7
    jal wrong

add_test:
    lw a0, arg4
    lw a1, arg5
    lw a2, arg3
    add a0, a0, a1
    beq a2, a0, addi_test
    slli a6, a6, 8
    jal wrong

addi_test:
    lw a0, arg5
    addi a0, a0, 3
    lw a1, arg4
    beq a0, a1, sub_test
    slli a6, a6, 9
    jal wrong

sub_test:
    lw a0, arg4
    lw a1, arg3
    lw a2, arg5
    sub a1, a1, a0
    beq a2, a1, auipc_test
    slli a6, a6, 10
    jal wrong

auipc_test:
    auipc a0, 0x10000
    lw a1, ans_auipc
    beq a0, a1, lui_test
    slli a6, a6, 11
    jal wrong

lui_test:
    lui a0, 0x10000
    lw a1, ans_lui
    beq a0, a1, and_test
    slli a6, a6, 12
    jal wrong

and_test:
    lw a0, arg3
    lw a1, arg4
    and a0, a0, a1
    beq a0, zero, or_test
    slli a6, a6, 13
    jal wrong

or_test:
    lw a0, arg3
    lw a1, arg4
    or a0, a0, a1
    addi a2, zero, 3
    beq a0, a2, xor_test
    slli a6, a6, 14
    jal wrong

xor_test:
    addi a0, zero, 0x34
    addi a1, zero, 0x12
    addi a2, zero, 0x26
    xor a0, a0, a1
    beq a0, a2, slli_test
    slli a6, a6, 15
    jal wrong

slli_test:
    addi a0, zero, 0x10
    slli a0, a0, 1
    addi a1, zero, 0x20
    beq a0, a1, srli_test
    slli a6, a6, 16
    jal wrong

srli_test:
    addi a0, zero, 0x20
    srli a0, a0, 1
    addi a1, zero, 0x10
    beq a0, a1, srai_test
    slli a6, a6, 17
    jal wrong

srai_test:
    lw a0, arg6
    srai a0, a0, 1
    lw a1, ans_srai
    beq a0, a1, jalr_test
    slli a6, a6, 18
    jal wrong

jalr_test:
    addi a0, zero, 0x208
    jalr a0
    jal wrong

wrong:
    lw a3, mmio_addr
    sw zero, (a3)
    jal wrong

right: 
    lw a3, mmio_addr
    addi a1, zero, 1
    sw a1, (a3)
    jal a3, right
