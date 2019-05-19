.data
    dist: .space 196
    memo: .space 3556
    city: .word 0, 0, 8, 6, 2, 4, 6, 7, 1, 3, 9, 4, 2, 3
    minPath: .word 0, 0, 0, 0, 0, 0, 0, 0
    f_max: .float 99999.0
    str0: .asciiz "Minimum cost: "
    str1: .asciiz "\nMinimum path: "
    str2: .asciiz " "

.text
    main:
        la $s1, dist            # $s1 = addr of dist[0][0]
        add $s2, $zero, $zero   # $s2 = i = 0
        la $s4, city            # $s4 = addr of city[0][0]
        la $s5, memo            # $s5 = addr of memo[0][0]
        addi $s0, $zero, 4      # count # of instrunctions

    for1tst:
        slti $t0, $s2, 7        # if ($s2 = i) < 7, $t0 = 1
        addi $s0, $zero, 2      # count # of instrunctions
        beq $t0, $zero, exit1   # if $t0 == 0, branch to exit1
        addi $s3, $s2, 1        # $s3 = j = i + 1
        addi $s0, $zero, 1      # count # of instrunctions

    for2tst:
        slti $t0, $s3, 7        # if ($s3 = j) < 7, $t0 = 1
        addi $s0, $zero, 2      # count # of instrunctions
        beq $t0, $zero, exit2   # if $t0 == 0, branch to exit2

        sll $t0, $s2, 3         # $t0 = ($s2 = i) * 8
        add $t1, $t0, $s4       # $t1 = addr of city[i][0]
        lw $t6, 0($t1)          # $t6 = city[i][0]
        lw $t7, 4($t1)          # $t7 = city[i][1]

        sll $t0, $s3, 3         # $t0 = ($s3 = j) * 8
        add $t1, $t0, $s4       # $t1 = addr of city[j][0]
        lw $t8, 0($t1)          # $t8 = city[j][0]
        lw $t9, 4($t1)          # $t9 = city[j][1]

        sub $t0, $t6, $t8       # $t0 = city[i][0] - city[j][0]
        sub $t1, $t7, $t9       # $t1 = city[i][1] - city[j][1]
        mul $t2, $t0, $t0       # $t2 = ($t0)^2
        mul $t3, $t1, $t1       # $t3 = ($t1)^2
        add $t4, $t2, $t3       # $t4 = ($t0)^2 + ($t1)^2

        mtc1 $t4, $f1           # $f1 = $t4, move to coprocessor1
        cvt.s.w $f2, $f1        # convert int($f1) to single($f2)
        sqrt.s $f3, $f2         # $f3 = dist between city i and j

        addi $t0, $zero, 7      # $t0 = 7
        mul $t1, $s2, $t0       # $t1 = ($s2 = i) * 7
        add $t1, $t1, $s3       # $t1 = ($s2 = i) * 7 + ($s3 = j)
        sll $t1, $t1, 2         # $t1 = (i * 7 + j) * 4
        add $t2, $t1, $s1       # $t2 = addr of dist[i][j]
        s.s $f3, 0($t2)         # dist[i][j] = dist between city i and j

        mul $t1, $s3, $t0       # $t1 = ($s3 = j) * 7
        add $t1, $t1, $s2       # $t1 = ($s3 = j) * 7 + ($s2 = i)
        sll $t1, $t1, 2         # $t1 = (j * 7 + i) * 4
        add $t2, $t1, $s1       # $t2 = addr of dist[j][i]
        s.s $f3, 0($t2)         # dist[i][j] = dist between city i and j

        addi $s3, $s3, 1        # ($s3 = j) += 1
        addi $s0, $zero, 32     # count # of instrunctions
        j for2tst

    exit1:
        add $a0, $zero, $zero   # arg1 = 0
        addi $a1, $zero, 1      # arg2 = 1
        mtc1 $zero, $f4         # $f4 = 0.0 (constant zero)
        l.s $f6 f_max           # $f6 = 9999.0 (big enough number)
        addi $s0, $zero, 5      # count # of instrunctions
        jal gMC1                # call getMinCost(0, 1)

        li $v0, 4               # print "Minimum cost: "
        la $a0, str0
        syscall

        li $v0, 2               # print "%f", minCost
        mov.s $f12, $f0
        syscall

        li $v0, 4               # print "\nMinimum path: "
        la $a0, str1
        syscall

        jal gMP0                # call getMinPath(minCost)

        add $s2, $zero, $zero   # $s2 = i = 0


    pfor:
        slti $t0, $s2, 8        # if i < 8, $t0 = 1
        beq $t0, $zero, main2   # if $t0 == 0, branch to main2

        li $v0, 1               # print "%d", minPath[i]
        lw $a0, 0($s6)          # $a0 = minPath[i]
        addi $s6, $s6, 4        # $s6 = $s6 + 4
        syscall

        li $v0, 4               # print " "
        la $a0, str2
        syscall

        addi $s2, $s2, 1        # i = i + 1
        j pfor


    main2:
        li $v0, 10              # Exit
        syscall


    exit2:
        addi $s2, $s2, 1        # ($s2 = i) += 1
        addi $s0, $zero, 2      # count # of instrunctions
        j for1tst

        # test fin

    gMC1:
        addi $sp, $sp, -20      # move sp to save 5 values
        sw $ra, 16($sp)         # save return addr
        sw $a1, 12($sp)         # save arg2
        sw $a0, 8($sp)          # save arg1

        addi $t0, $zero, 127    # $t0 = (1 << 7) - 1 = 127
        addi $s0, $zero, 6      # count # of instrunctions
        bne $a1, $t0, gMC2      # if visitMask != $t0, branch to gMC2

        addi $t0, $zero, 7      # $t0 = 7
        mul $t0, $t0, $a0       # $t0 = ($a0 = i) * 7
        sll $t0, $t0, 2         # $t0 = i * 7 * 4
        add $t1, $t0, $s1       # $t1 = addr of dist[i][0]

        sll $t2, $a1, 2         # $t2 = ($a1 = visitMask) * 4
        add $t2, $t2, $t0       # $t2 = i * 7 * 4 + visitMask * 4
        add $t3, $t2, $s5       # $t3 = addr of memo[i][visitMask]

        l.s $f3, 0($t1)         # $f3 = dist[i][0]
        s.s $f3, 0($t3)         # memo[i][visitMask] = $f3

        mov.s $f0, $f3          # $f0 = dist[i][0] (return value)
        addi $sp, $sp, 20       # move sp to pop 5 values
        addi $s0, $zero, 12     # count # of instrunctions
        jr $ra                  # return

    gMC2:
        addi $t0, $zero, 7      # $t0 = 7
        mul $t0, $t0, $a0       # $t0 = ($a0 = i) * 7
        add $t0, $t0, $a1       # $t0 = i * 7 + visitMask
        sll $t0, $t0, 2         # $t0 = (i * 7 + visitMask) * 4
        add $t1, $t0, $s5       # $t1 = addr of memo[i][visitMask]
        l.s $f3, 0($t1)         # $f3 = memo[i][visitMask]

        c.eq.s $f3, $f4         # if $f3 == 0.0, condition-code = 1
        addi $s0, $zero, 8      # count # of instrunctions
        bc1t gMC3               # if condition-code == 1, branch to gMC3

        mov.s $f0, $f3          # $f0 = memo[i][visitMask] (return value)
        addi $sp, $sp, 20       # move sp to pop 5 values
        addi $s0, $zero, 3      # count # of instrunctions
        jr $ra                  # return

    gMC3:
        add.s $f1, $f4, $f6     # ($f1 = tempMinCost) = 9999.0
        add $s3, $zero, $zero   # ($s3 = j) = 0
        addi $s0, $zero, 2      # count # of instrunctions

    gMC3_for:
        slti $t0, $s3, 7        # if ($s3 = j) < 7, $t0 = 1
        addi $s0, $zero, 2      # count # of instrunctions
        beq $t0, $zero, gMC3_exit # if $t0 == 0, branch to gMC3_exit

        addi $s0, $zero, 1      # count # of instrunctions
        beq $a0, $s3, gMC3_incj # if i == j, continue

        addi $t0, $zero, 1      # $t0 = 1
        sll $t0, $t0, $s3       # $t0 = 1 << j
        and $t1, $t0, $a1       # $t1 = visitMask & (1 << j)
        addi $s0, $zero, 4      # count # of instrunctions
        bne $t1, $zero, gMC3_incj # if $t1 != 0, continue

        or $t1, $t0, $a1        # $t1 = visitMask | (1 << j)
        add $a0, $s3, $zero     # $a0 = arg1 = j
        add $a1, $t1, $zero     # $a1 = arg2 = visitMask | (1 << j)
        sw $s3, 4($sp)          # save j
        swc1 $f1, 0($sp)        # save tempMinCost
        addi $s0, $zero, 6      # count # of instrunctions
        jal gMC1                # recursive call

        lw $ra, 16($sp)         # restore return addr
        lw $a1, 12($sp)         # restore arg2
        lw $a0, 8($sp)          # restore arg1
        lw $s3, 4($sp)          # restore j
        lwc1 $f1, 0($sp)        # restore tempMinCost

        addi $t0, $zero, 7      # $t0 = 7
        mul $t0, $t0, $a0       # $t0 = ($a0 = i) * 7
        add $t0, $t0, $s3       # $t0 = i * 7 + j
        sll $t1, $t0, 2         # $t1 = (i * 7 + j) * 4
        add $t1, $t1, $s1       # $t1 = addr of dist[i][j]
        l.s $f3, 0($t1)         # $f3 = dist[i][j]

        add.s $f2, $f3, $f0     # tempCost = dist[i][j] + getMinCost()
        c.lt.s $f2, $f1         # if $f2 < $f1, condition-code = 1
        addi $s0, $zero, 14     # count # of instrunctions
        bc1f gMC3_incj          # if condition-code == 0, continue

        mov.s $f1, $f2          # tempMinCost = tempCost
        addi $s0, $zero, 1      # count # of instrunctions

    gMC3_incj:
        addi $s3, $s3, 1        # ($s3 = j) += 1
        addi $s0, $zero, 2      # count # of instrunctions
        j gMC3_for              # continue the loop

    gMC3_exit:
        addi $t0, $zero, 7      # $t0 = 7
        mul $t0, $t0, $a0       # $t0 = ($a0 = i) * 7
        add $t0, $t0, $a1       # $t0 = i * 7 + visitMask
        sll $t1, $t0, 2         # $t1 = (i * 7 + visitMask) * 4
        add $t1, $t1, $s5       # $t1 = addr of memo[i][visitMask]
        s.s $f1, 0($t1)         # memo[i][visitMask] = tempMinCost

        mov.s $f0, $f1          # $f0 = tempMinCost (return value)
        addi $sp, $sp, 20       # move sp to pop 5 values
        addi $s0, $zero, 9      # count # of instrunctions
        jr $ra                  # return



        # getMinPath 함수 추가
        # minCost $f0
        # minPath[0] $s6
        # visitMask $t8
        # cur $t9
    gMP0:
        addi $sp, $sp, -8   # move sp to save 2 values
        sw $ra, 4($sp)      # save return addr
        swc1 $f0, 0($sp)    # save arg minCost

        addi $t8, $zero, 1  # visitMask = $t8 = 1
        add $t9, $zero, $zero   # cur = $t9 = 0

        la $s6, minPath     # $s6 = addr of minPath[0]
        addi $t0, $zero, 1  # $t0 = 1
        sw $t0, 0($s6)      # minPath[0] = 1

        addi $t1, $zero, 28 # $t1 = 28
        addi $t2, $s6, $t1  # $t2 = addr of minPath[7]
        sw $t0, 0($t2)      # minPath[7] = 1

        addi $s2, $zero, 1  # $s2 = i = 1


    ifor:
        slti $t0, $s2, 7    # if ($s2 = i) < 7, $t0 = 1
        beq $t0, $zero, iexit   # if $t0 == 0, branch to iexit
        add $s3, $zero, $zero   # $s3 = j = 0

    jfor:
        slti $t0, $s3, 7    # if ($s3 = j) < 7, $t0 = 1
        beq $t0, $zero, jexit   # if $t0 == 0, branch to jexit

        addi $t0, $zero, 1  # $t0 = 1
        sll $t1, $t0, $s3   # $t1 = 1 << j
        and $t2, $t8, $t1   # $t2 = visitMask & (1 << j)
        bne $t2, $zero, jfor2   # if $t2 != 0, branch to jfor2

        or $t2, $t8, $t1    # $t2 = visitMask | (1 << j)
        addi $t3, $zero, 7  # $t3 = 7
        mul $t4, $s3, $t3   # $t4 = j * 7
        add $t5, $t4, $t2   # $t5 = j * 7 + (visitMask | (1 << j))
        sll $t6, $t5, 2     # $t6 = (j * 7 + (visitMask | (1 << j))) * 4
        add $t7, $t6, $s5   # $t7 = addr of memo[j][visitMask | (1 << j)]
        lw $t2, 0($t7)      # $t2 = memo[j][visitMask | (1 << j)]
        mtc1 $t2, $f4       # $f4 = $t2, move to coprocessor1

        mul $t4, $t9, $t3   # $t4 = cur * 7
        add $t5, $t4, $s3   # $t5 = cur * 7 + j
        sll $t6, $t5, 2     # $t6 = (cur * 7 + j) * 4
        add $t7, $t6, $s1   # $t7 = addr of dist[cur][j]
        lw $t4, 0($t7)      # $t4 = dist[cur][j]
        mtc1 $t4, $f2       # $f2 = $t4, move to coprocessor1
        sub.s $f3, $f0, $f2 # $f3 = minCost - dist[cur][j]

        c.eq.s $f3, $f4     # if $f3 == $f4, condition-code = 1
        bclf jfor2          # if condition-code == 0, branch to jfor2

        or $t8, $t8, $t1    # visitMask = visitMask | (1 << j)
        sub $f0, $f0, $f2   # minCost = minCost - dist[cur][j]
        add $t9, $s3, $zero # cur = j

        sll $t0, $s2, 2     # $t0 = i * 4
        add $t1, $t0, $s6   # $t1 = addr of minPath[i]
        addi $t2, $s3, 1    # $t2 = j + 1
        sw $t2, 0($t1)      # minPath[i] = j + 1

    jexit:
        addi $s2, $s2, 1    # i = i + 1
        j ifor


    jfor2:
        addi $s3, $s3, 1    # j = j + 1
        j jfor


    iexit:
        addi $sp, $sp, 8       # move sp to pop 2 values
        jr $ra                 # return to main