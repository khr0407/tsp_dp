.data
  dist: .space 196
  memo: .space 3556
  city: .word 0, 0, 8, 6, 2, 4, 6, 7, 1, 3, 9, 4, 2, 3
  minPath: .word 0, 0, 0, 0, 0, 0, 0, 0
  f_max: .float 99999.0

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

    li $v0, 10              # Exit
    syscall

  exit2:
    addi $s2, $s2, 1        # ($s2 = i) += 1
    addi $s0, $zero, 2      # count # of instrunctions
    j for1tst

  # test fin

  gMC1:
    # Enter recursive function: save $ra, $a1, $a0
    addi $sp, $sp, -12      # move sp to save 3 values
    sw $ra, 8($sp)          # save return addr
    sw $a1, 4($sp)          # save arg2
    sw $a0, 0($sp)          # save arg1

    # Case 1: All cities are visited
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
    addi $s0, $zero, 11     # count # of instrunctions
    j gMC_rt

  # Case 2: There is memoed value
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
    addi $s0, $zero, 2      # count # of instrunctions
    j gMC_rt

  # Case 3: There is no memoed value
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
    addi $sp, $sp, -8       # move sp to save 2 values
    sw $s3, 4($sp)          # save j
    swc1 $f1, 0($sp)        # save tempMinCost
    addi $s0, $zero, 7      # count # of instrunctions
    jal gMC1                # recursive call

    lw $s3, 4($sp)          # restore j
    lwc1 $f1, 0($sp)        # restore tempMinCost
    addi $sp, $sp, 8        # move sp to pop 2 values

    lw $ra, 8($sp)          # restore return addr
    lw $a1, 4($sp)          # restore arg2
    lw $a0, 0($sp)          # restore arg1

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
    addi $s0, $zero, 7      # count # of instructions

  gMC_rt:
    addi $sp, $sp, 12       # move sp to pop 3 values
    jr $ra                  # return
