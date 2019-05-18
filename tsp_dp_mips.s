.data
  dist: .space 196
  memo: .space 3556
  city: .word 0, 0, 8, 6, 2, 4, 6, 7, 1, 3, 9, 4, 2, 3

.text
  main:
    la $s1, dist            # $s1 = addr of dist[0][0]
    add $s2, $zero, $zero   # $s2 = i = 0
    la $s4, city            # $s4 = addr of city[0][0]
    la $s5, memo            # $s5 = addr of memo[0][0]

  for1tst:
    slti $t0, $s2, 7        # if ($s2 = i) < 7, $t0 = 1
    beq $t0, $zero, exit1   # if $t0 == 0, branch to exit1
    addi $s3, $s2, 1        # $s3 = j = i + 1

  for2tst:
    slti $t0, $s3, 7        # if ($s3 = j) < 7, $t0 = 1
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
    j for2tst

  exit1:
    add $a0, $zero, $zero   # arg1 = 0
    addi $a1, $zero, 1      # arg2 = 1
    jal gMC0                # call getMinCost(0, 1)

  exit2:
    addi $s2, $s2, 1        # ($s2 = i) += 1
    j for1tst

  # test fin

  gMC0:
    addi $sp, $sp, -12      # move sp to save 3 values
    sw $ra, 8($sp)          # save return addr
    sw $a1, 4($sp)          # save arg2
    sw $a0, 0($sp)          # save arg1

    addi $t0, $zero, 1      # $t0 = 1
    sll $t0, $t0, 7         # $t0 = 1 << 7
    subi $t0, $t0, 1        # $t0 = (1 << 7) - 1
    bne $a1, $t0, gMC1      # if visitMask != $t0, branch to gMC1

    addi $t0, $zero, 7      # $t0 = 7
    mul $t0, $t0, $a0       # $t0 = ($a0 = i) * 7
    sll $t0, $t0, 2         # $t0 = ($a0 = i) * 7 * 4
    add $t1, $t0, $s1       # $t1 = addr of dist[i][0]

    sll $t2, $a1, 2         # $t2 = ($a1 = visitMask) * 4
    add $t2, $t2, $t0       # $t2 = i * 7 * 4 + visitMask * 4
    add $t3, $t2, $s5       # $t3 = addr of memo[i][visitMask]

    l.s $f3, 0($t1)         # $f3 = dist[i][0]
    s.s $f3, 0($t3)         # memo[i][visitMask] = $f3

    addi.s $f0, $f3, $zero  # $f0 = dist[i][0] (return value)
    addi $sp, $sp, 12       # move sp to pop 3 values
    jr $ra                  # return

  gMC1:
    addi $t0, $zero, 7      # $t0 = 7
    mul $t0, $t0, $a0       # $t0 = ($a0 = i) * 7
    add $t0, $t0, $a1       # $t0 = i * 7 + visitMask
    sll $t0, $t0, 2         # $t0 = (i * 7 + visitMask) * 4
    add $t1, $t0, $s5       # $t1 = addr of memo[i][visitMask]
    l.s $f3, 0($t1)         # $f3 = memo[i][visitMask]

    c.eq.s $f3, $zero       # if $f3 == 0, condition-code = 1
    bc1t gMC2               # if condition-code == 1, branch to getMinCost2

    addi.s $f0, $f3, $zero  # $f0 = memo[i][visitMask] (return value)
    addi $sp, $sp, 12       # move sp to pop 3 values
    jr $ra                  # return

  gMC2:
    addi.s $f1, $zero, 9999 # ($f1 = tempMinCost) = 9999
    add $s3, $zero, $zero   # ($s3 = j) = 0

  gMC2_for:
    slti $t0, $s3, 7        # if ($s3 = j) < 7, $t0 = 1
    beq $t0, $zero, gMC2_exit # if $t0 == 0, branch to gMC2_exit

    beq $a0, $s3, gMC2_incj # if i == j, continue

    addi $t0, $zero, 1      # $t0 = 1
    sll $t0, $t0, $s3       # $t0 = 1 << j
    and $t1, $t0, $a1       # $t1 = visitMask & (1 << j)
    bne $t1, $zero, gMC2_incj # if $t1 != 0, continue

    or $t1, $t0, $a1        # $t1 = visitMask | (1 << j)
    add $a0, $s3, $zero     # $a0 = arg1 = j
    add $a1, $t1, $zero     # $a1 = arg2 = visitMask | (1 << j)
    jal gMC0                # recursive call

    lw $ra, 8($sp)          # restore return addr
    lw $a1, 4($sp)          # restore arg2
    lw $a0, 0($sp)          # restore arg1
    addi $sp, $sp, 12       # move sp to pop 3 values

    addi $t0, $zero, 7      # $t0 = 7
    mul $t0, $t0, $a0       # $t0 = ($a0 = i) * 7
    add $t0, $t0, $s3       # $t0 = i * 7 + j
    sll $t1, $t0, 2         # $t1 = (i * 7 + j) * 4
    add $t1, $t1, $s1       # $t1 = addr of dist[i][j]
    l.s $f3, 0($t1)         # $f3 = dist[i][j]

    add.s $f2, $f3, $f0     # tempCost = dist[i][j] + getMinCost()
    c.lt.s $f2, $f1         # if $f2 < $f1, condition-code = 1
    bc1f gMC2_incj          # if condition-code == 0, continue

    add $f1, $f2, $zero     # tempMinCost = tempCost

  gMC2_incj:
    addi $s3, $s3, 1        # ($s3 = j) += 1
    j gMC2_for              # continue the loop

  gMC2_exit:
    addi $t0, $zero, 7      # $t0 = 7
    mul $t0, $t0, $a0       # $t0 = ($a0 = i) * 7
    add $t0, $t0, $a1       # $t0 = i * 7 + visitMask
    sll $t1, $t0, 2         # $t1 = (i * 7 + visitMask) * 4
    add $t1, $t1, $s5       # $t1 = addr of memo[i][visitMask]
    s.s $f1, 0($t1)         # memo[i][visitMask] = tempMinCost

    add $f0, $f1, $zero     # $f0 = tempMinCost (return value)