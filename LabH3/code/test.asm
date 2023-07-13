.data
arg0:     .word   5
arg1:     .word   7
arg2:     .word   39
arg3:     .word   -2
ans_add:  .word   12
ans_sub:  .word   -2
ans_addi: .word   25
ans_auipc:.word   0x10000154 # 0x00000154 + 0x10000000 #need to be modified after assemble
ans_lui:  .word   0x10000000
ans_and:  .word   5      # #5 & #39 = #5
ans_or:   .word   39     # #5 | #39 = #39
ans_xor:  .word   34     # #5 ^ #39 = #34
ans_slli: .word   0x1400 #  0x5 << 10 = 0x1400
ans_srli: .word   0x4    #  #39 >> 3 = 0x4
ans_srai: .word   -0x1   #  0x-2 >> 3 = 0x-1
ans_lw:   .word   39     #  arg2
ans_sw:   .word   260817 #  0x-2 >> 3 = 0x-1
sw_str:   .word   0x00000000
str_add:  .string "[ ADD   ]"
str_addi: .string "[ ADDI  ]"
str_sub:  .string "[ SUB   ]"
str_auipc:.string "[ AUIPC ]"
str_lui:  .string "[ LUI   ]"
str_and:  .string "[ AND   ]"
str_or:   .string "[ OR    ]"
str_xor:  .string "[ XOR   ]"
str_slli: .string "[ SLLI  ]"
str_srli: .string "[ SRLI  ]"
str_srai: .string "[ SRAI  ]"
str_lw:   .string "[ LW    ]"
str_sw:   .string "[ SW    ]"
str_beq:  .string "[ BEQ   ]"
str_blt:  .string "[ BLT   ]"
str_bltu: .string "[ BLTU  ]"
str_jal:  .string "[ JAL   ]"
str_jalr: .string "[ JALR  ]"

str1:     .string "Expected: "
str2:     .string " , Actual: "
str3:     .string ".\nTest of "
str3_:     .string "Test of "
str4:     .string " is "
str_pass: .string "passed.\n\n"
str_fail: .string "failed.\n\n"

.text
main:
        jal ra, test_add
        jal ra, printResult
        jal ra, test_sub
        jal ra, printResult
        jal ra, test_addi
        jal ra, printResult
        jal ra, test_auipc
        jal ra, printResult
        jal ra, test_lui
        jal ra, printResult
        jal ra, test_and
        jal ra, printResult
        jal ra, test_or
        jal ra, printResult
        jal ra, test_xor
        jal ra, printResult
        jal ra, test_slli
        jal ra, printResult
        jal ra, test_srli
        jal ra, printResult
        jal ra, test_srai
        jal ra, printResult
        jal ra, test_sw
        jal ra, printResult
        jal ra, test_lw
        jal ra, printResult
        jal ra, test_beq
        jal ra, printResult_alter
        jal ra, test_blt
        jal ra, printResult_alter
        jal ra, test_bltu
        jal ra, printResult_alter
        jal ra, test_jal
        jal ra, printResult_alter
        jal ra, test_jalr
        jal ra, printResult_alter

        # Exit program
        li a7, 10
        ecall

# auto-test add, addi, sub ,auipc, lui
test_add:
        la a1, str_add
        lw a2, arg0
        lw a3, arg1
        lw a4, ans_add
        add a5, a2, a3
        la a0, str_pass
        beq a4, a5, add_pass
        la a0, str_fail
add_pass:
        ret

test_sub:
        la a1, str_sub
        lw a2, arg0
        lw a3, arg1
        lw a4, ans_sub
        sub a5, a2, a3
        la a0, str_pass
        beq a4, a5, sub_pass
        la a0, str_fail
sub_pass:
        ret

test_addi:
        la a1, str_addi
        lw a2, arg0
        lw a4, ans_addi
        addi a5, a2, 20
        la a0, str_pass
        beq a4, a5, addi_pass
        la a0, str_fail
addi_pass:
        ret
        
test_auipc:
        la a1, str_auipc
        lw a4, ans_auipc
        auipc a5, 0x10000
        la a0, str_pass
        beq a4, a5, auipc_pass
        la a0, str_fail
auipc_pass:
        ret

test_lui:
        la a1, str_lui
        lw a4, ans_lui
        lui a5, 0x10000
        la a0, str_pass
        beq a4, a5, lui_pass
        la a0, str_fail
lui_pass:
        ret

test_and:
        la a1, str_and
        lw a4, ans_and
        lw a2, arg0
        lw a3, arg2
        and a5, a2, a3
        la a0, str_pass
        beq a4, a5, and_pass
        la a0, str_fail
and_pass:
        ret

test_or:
        la a1, str_or
        lw a4, ans_or
        lw a2, arg0
        lw a3, arg2
        or a5, a2, a3
        la a0, str_pass
        beq a4, a5, or_pass
        la a0, str_fail
or_pass:
        ret

test_xor:
        la a1, str_xor
        lw a4, ans_xor
        lw a2, arg0
        lw a3, arg2
        xor a5, a2, a3
        la a0, str_pass
        beq a4, a5, xor_pass
        la a0, str_fail
xor_pass:
        ret

test_slli:
        la a1, str_slli
        lw a4, ans_slli
        lw a2, arg0
        slli a5, a2, 0xa
        la a0, str_pass
        beq a4, a5, slli_pass
        la a0, str_fail
slli_pass:
        ret

test_srli:
        la a1, str_srli
        lw a4, ans_srli
        lw a2, arg2
        srli a5, a2, 0x3
        la a0, str_pass
        beq a4, a5, srli_pass
        la a0, str_fail
srli_pass:
        ret

test_srai:
        la a1, str_srai
        lw a4, ans_srai
        lw a2, arg3
        srai a5, a2, 3
        la a0, str_pass
        beq a4, a5, srai_pass
        la a0, str_fail
srai_pass:
        ret

test_lw:
        la a1, str_lw
        lw a4, ans_lw
        lw a5, arg2
        la a0, str_pass
        beq a4, a5, lw_pass
        la a0, str_fail
lw_pass:
        ret

test_sw:
        la a1, str_sw
        lw a4, ans_sw
        la a2, sw_str
        sw a4, (a2)
        lw a5, sw_str
        la a0, str_pass
        beq a4, a5, sw_pass
        la a0, str_fail
sw_pass:
        ret

test_beq:
        la a1, str_beq
        lw a4, arg2
        lw a5, arg2
        la a0, str_pass
        beq a4, a5, beq_pass
        la a0, str_fail
beq_pass:
        ret

test_blt:
        la a1, str_blt
        lw a2, arg0
        lw a3, arg1
        la a0, str_pass
        blt a2, a3, blt_pass
        la a0, str_fail
blt_pass:
        ret

test_bltu:
        la a1, str_bltu
        lw a2, arg0
        lw a3, arg3
        la a0, str_pass
        bltu a2, a3, bltu_pass
        la a0, str_fail
bltu_pass:
        ret

test_jal:
        la a1, str_jal
        la a0, str_pass
        jal a2, jal_pass
        la a0, str_fail
        ret # failed if we get here, return

jal_pass:
        ret # return to main program

test_jalr:
        la a1, str_jalr
        la a0, str_pass
        la a3, jalr_pass
        jalr a2, a3, 0x8 # jump to ret directly
        la a0, str_fail
        ret # failed if we get here, return

jalr_pass:
        la a0, str_fail
        ret # return to main program

printResult:
        mv t0, a0
        mv t1, a1
        la a0, str1
        li a7, 4
        ecall
        mv a0, a4
        li a7, 1
        ecall
        la a0, str2
        li a7, 4
        ecall
        mv a0, a5
        li a7, 1
        ecall
        la a0, str3
        li a7, 4
        ecall
        mv a0, t1
        li a7, 4
        ecall
        la a0, str4
        li a7, 4
        ecall
        mv a0, t0
        li a7, 4
        ecall
        ret

printResult_alter:
        mv t0, a0
        mv t1, a1
        la a0, str3_
        li a7, 4
        ecall
        mv a0, t1
        li a7, 4
        ecall
        la a0, str4
        li a7, 4
        ecall
        mv a0, t0
        li a7, 4
        ecall
        ret