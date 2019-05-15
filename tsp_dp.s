# $s0: #instructions

.data
	dist: .space 196
	memo: .space 3556
	minPath: .word 0, 0, 0, 0, 0, 0, 0, 0
	city: .word 0, 0, 8, 6, 2, 4, 6, 7, 1, 3, 9, 4, 2, 3
	str0: .asciiz "Minimum cost: "
	str1: .asciiz "\nMinimum path: "
	str2: .asciiz " "

.text
	main:
		la $s1, dist				# $s1 = address of dist[0][0]
		add $s2, $zero, $zero		# i($s2) = 0
		la $s4, city				# $s4 = address of city[0][0]
		la $s5, memo				# $s5 = address of memo[0][0]
		addi $s0, $zero, 4			# count #instructions


	ifor:
		slti $t0, $s2, 7			# If i($s2) < 7, $t0 = 1. Else, $t0 = 0.
		addi $s0, $s0, 2			# count #instructions
		beq $t0, $zero, main2		# If $t0 = 0, go to main2

		addi $s3, $s2, 1			# j($s3) = i($s2) + 1
		addi $s0, $s0, 1			# count #instructions


	jfor:
		slti $t0, $s3, 7			# If j($s3) < 7, $t0 = 1. Else, $t0 = 0.
		addi $s0, $s0, 2			# count #instructions
		beq $t0, $zero, exit		# If $t0 = 0, go to exit

		sll $t0, $s2, 3				# $t0 = i($s2) * 8
		add $t1, $t0, $s4			# $t1 = address of city[i][0]
		lw $t6, 0($t1)				# $t6 = city[i][0]
		lw $t7, 4($t1)				# $t7 = city[i][1]

		sll $t0, $s3, 3				# $t0 = j($s3) * 8
		add $t1, $t0, $s4			# $t1 = address of city[j][0]
		lw $t8, 0($t1)				# $t8 = city[j][0]
		lw $t9, 4($t1)				# $t9 = city[j][1]

		sub $t0, $t6, $t8			# $t0 = city[i][0]($t6) - city[j][0]($t8)
		sub $t1, $t7, $t9			# $t1 = city[i][1]($t7) - city[j][1]($t9)
		mul $t2, $t0, $t0			# $t2 = pow(city[i][0] - city[j][0], 2)
		mul $t3, $t1, $t1			# $t3 = pow(city[i][1] - city[j][1], 2)
		add $t4, $t2, $t3			# $t4 = pow(city[i][0] - city[j][0], 2) + pow(city[i][1] - city[j][1], 2)

		mtc1 $t4, $f1				# $f1 = $t4, move to coprocessor1
		cvt.s.w $f2, $f1			# convert from integer($f1) to single($f2)
		sprt.s $f3, $f2				# $f3 = sqrt(pow(city[i][0] - city[j][0], 2) + pow(city[i][1] - city[j][1], 2))

		addi $t0, $zero, 7			# $t0 = 7
		mul $t1, $s2, $t0			# $t1 = i($s2) * 7($t0)
		sll $t2, $t1, 2				# $t2 = (i * 7) * 4
		add $t0, $s3, $zero			# $t0 = j($s3)
		sll $t1, $t0, 2				# $t1 = j * 4
		add $t3, $t2, $t1			# $t3 = (i*7)*4 + j*4
		add $t4, $t3, $s1			# $t4 = address of dist[i][j]
		swc1 $f3, 0($t4)			# dist[i][j] = sqrt(pow(city[i][0] - city[j][0], 2) + pow(city[i][1] - city[j][1], 2))

		addi $t0, $zero, 7			# $t0 = 7
		mul $t1, $s3, $t0			# $t1 = j($s3) * 7($t0)
		sll $t2, $t1, 2				# $t2 = (j * 7) * 4
		add $t0, $s2, $zero			# $t0 = i($s2)
		sll $t1, $t0, 2				# $t1 = i * 4
		add $t3, $t2, $t1			# $t3 = (j*7)*4 + i*4
		add $t4, $t3, $s1 			# $t4 = address of dist[j][i]
		swc1 $f3, 0($t4)			# dist[j][i] = sqrt(pow(city[i][0] - city[j][0], 2) + pow(city[i][1] - city[j][1], 2))

		addi $s3, $s3, 1			# j = j + 1
		addi $s0, $s0, 34			# count #instructions
		j jfor						# inner loop


	exit:
		addi $s2, $s2, 1			# i = i + 1
		addi $s0, $s0, 2			# count #instructions
		j ifor						# outer loop


	main2:
		add $a0, $zero, $zero		# argument1(i) = 0
		addi $a1, $zero, 1			# argument2(visitMask) = 1
		addi $s0, $s0, 3			# count #instructions
		jal getMinCost0				# call getMinCost(0, 1)
									# $f0 = minCost (return value of getMinCost(0, 1))
		li $v0, 4					# print "Minimum cost: "
		la $a0, str0
		syscall

		li $v0, 2					# print "%f", minCost
		mov.s $f12, $f0
		syscall

		li $v0, 4					# print "\nMinimum path: "
		la $a0, str1
		syscall

		#???????????????????????? print count?????????? pfor count??????
		addi $s0, $s0, 2			# count #instructions (mov.s, jal)
		jal getMinPath				# call getMinPath(minCost($f12))

		add $s2, $zero, $zero		# i($s2) = 0
		la $s3, minPath				# $s3 = address of minPath[0]
	

	pfor:
		slti $t0, $s2, 8			# If i < 8, $t0 = 1. Else, $t0 = 0.
		beq $t0, $zero, return		# If $t0 == 0, go to return

		li $v0, 1					# print "%d", minPath[i]
		lw $a0, 0($s3)				# $a0 = minPath[i]
		addi $s3, $s3, 4			# $s3 = $s3 + 4
		syscall

		li $v0, 4					# print " "
		la $a0, str2
		syscall

		addi $s2, $s2, 1			# i = i + 1
		j pfor						# loop


	return: #어떻게 끝내지???????????????????



	# return value of getMinCost: $f0
	# $f2 = tempCost, $f1 = tempMinCost
	getMinCost0:
		addi $sp, $sp, -12			# move stack pointer to save 3 values
		sw $ra, 8($sp)				# save return address on stack
		sw $a1, 4($sp)				# save argument2 visitMask($a1) on stack
		sw $a0, 0($sp)				# save argument1 i($a0) on stack

		#????????????????????????
		mtc1 $zero, $f2 			# $f2 = 0.0
		addi.s $f1, $f2, 99999999999# tempMinCost($f1) = 99999999999.0

		addi $t0, $zero, 1			# $t0 = 1
		sll $t1, $t0, 7				# $t1 = 1 << 7
		subi $t0, $t1, 1			# $t0 = (1 << 7) - 1
		addi $s0, $s0, 10			# count #instructions
		bne $a1, $t0, getMinCost1	# if visitMask($a1) != (1<<7)-1, go to getMinCost1

		addi $t0, $zero, 7			# $t0 = 7
		mul $t1, $a0, $t0			# $t1 = i($a0) * 7($t0)
		sll $t2, $t1, 2				# $t2 = (i * 7) * 4
		add $t3, $t2, $s1 			# $t3 = address of dist[i][0]

		sll $t0, $a1, 2				# $t0 = visitMask($a1) * 4
		add $t1, $t2, $t0			# $t1 = (i*7)*4 + visitMask*4
		add $t4, $t1, $s5 			# $t4 = address of memo[i][visitMask]

		lwc1 $f3, 0($t3)			# $f3 = dist[i][0]
		swc1 $f3, 0($t4)			# memo[i][visitMask] = $f3

		#리턴하기
		addi.s $f0, $f3, $zero		# $f0 = dist[i][0] (return value)
# 첫 return에서만 return 전에 sp 옮기고, jr $ra 후에
# 옮긴 sp서 argument, ra 꺼내고 바로 sp 옮긴다. 후엔 return 전에는
# 아무것도 안해도 된다. 
# ex) fact()
# 맞으면 첫 return은 어디서? 항상 거기서?
# sp 옮기고 arugment 꺼내오는 방법은 많긴 한데 위가 제일 쉬워보임.
		addi $sp, $sp, 12			# ????????????????????????
		addi $s0, $s0, 12			# count #instructions
		jr $ra						# return



	getMinCost1:
		addi $t0, $zero, 7			# $t0 = 7
		mul $t1, $a0, $t0			# $t1 = i($a0) * 7($t0)
		sll $t2, $t1, 2				# $t2 = (i * 7) * 4
		sll $t0, $a1, 2				# $t0 = visitMask($a1) * 4
		add $t1, $t2, $t0			# $t1 = (i*7)*4 + visitMask*4
		add $t4, $t1, $s5 			# $t4 = address of memo[i][visitMask]
		lwc1 $f3, 0($t4)			# $f3 = memo[i][visitMask]
		add.s $f2, $f3, $zero		# tempCost($f2) = $f3

		c.eq.s $f2, $zero			# If tempCost == 0, condition code = 1. Else, 0
		addi $s0, $s0, 10			# count #instructions
		bc1t getMinCost2			# If tempCost == 0, go to getMinCost2

		#리턴하기
		addi.s $f0, $f2, $zero		# $f0 = tempCost($f2) (return value)
# 얘도 위처럼
		addi $sp, $sp, 12			# ????????????????????????
		addi $s0, $s0, 3			# count #instructions
		jr $ra



	getMinCost2:
		add $s3, $zero, $zero		# j($s3) = 0
		addi $s0, $s0, 1			# count #instructions



	getMinCost2_jfor0:
		slti $t0, $s3, 7			# If j($s3) < 7, $t0 = 1. Else, $t0 = 0.
		addi $s0, $s0, 2			# count #instructions
		beq $t0, $zero, getMinCost3	# If $t0 = 0, go to getMinCost3

		addi $s0, $s0, 1
		bne $a0, $s0, getMinCost2_jfor1	# If i != j, go to getMinCost2_jfor1

		addi $s3, $s3, 1			# j = j + 1
		addi $s0, $s0, 2			# count #instructions
		j getMinCost2_jfor0			# loop



	getMinCost2_jfor1:
		addi $t0, $zero, 1			# $t0 = 1
		sll $t1, $t0, $s3			# $t1 = 1 << j
		and $t2, $a1, $t1			# $t2 = visitMask & (1<<j)
		addi $s0, $s0, 4			# count #instructions
		beq $t2, $zero, getMinCost2_jfor2 # If visitMask&(i<<j) == 0, go to getMinCost2_jfor2

		addi $s3, $s3, 1			# j = j + 1
		addi $s0, $s0, 2			# count #instructions
		j getMinCost2_jfor0			# loop



	getMinCost2_jfor2:
		addi $t0, $zero, 1			# $t0 = 1
		sll $t1, $t0, $s3			# $t1 = 1 << j
		or $t2, $a1, $t1			# $t2 = visitMask | (1<<j)

		add $a0, $s3, $zero			# pass argument1 j
		add $a1, $t2, $zero			# pass argument2 visitMask | (1<<j)

		addi $s0, $s0, 6			# count #instructions
		jal getMinCost0 			# jump to getMinCost0

		lw $ra, 8($sp)				# restore return address from stack
		lw $a1, 4($sp)				# restore argument2(visitMask) from stack
		lw $a0, 0($sp)				# restore argument1(i) from stack
		addi $sp, $sp, 12			# pop 3 values from stack

		addi $t0, $zero, 7			# $t0 = 7
		mul $t1, $a0, $t0			# $t1 = i($a0) * 7($t0)
		sll $t2, $t1, 2				# $t2 = (i * 7) * 4
		sll $t3, $s3, 2				# $t3 = j * 4
		add $t4, $t2, $t3			# $t4 = (i*7)*4 + j*4
		add $t5, $t4, $s1 			# $t5 = address of dist[i][j]
		lwc1 $f4, 0($t5)			# $f4 = dist[i][j]
		add.s $f2, $f4, $f0			# tempCost($f2) = dist[i][j] + getMinCost()
		
		c.lt.s $f2, $f1 			# If tempCost < tempMinCost, condition code = 1. Else, 0.
		addi $s0, $s0, 14			# count #instructions
		bc1f getMinCost2_jfor3		# If tempCost >= tempMinCost, go to getMinCost2_jfor3

		add $f1, $f2, $zero			# tempMinCost = tempCost
		addi $s0, $s0, 1			# count #instructions


	getMinCost2_jfor3:
		addi $s3, $s3, 1			# j = j + 1
		addi $s0, $s0, 2			# count #instructions
		j getMinCost2_jfor0			# loop


	getMinCost3:
		addi $t0, $zero, 7			# $t0 = 7
		mul $t1, $a0, $t0			# $t1 = i($a0) * 7($t0)
		sll $t2, $t1, 2				# $t2 = (i * 7) * 4
		sll $t0, $a1, 2				# $t0 = visitMask($a1) * 4
		add $t1, $t2, $t0			# $t1 = (i*7)*4 + visitMask*4
		add $t4, $t1, $s5 			# $t4 = address of memo[i][visitMask]
		swc1 $f1, 0($t4)			# memo[i][visitMask] = tempMinCost

		# 리턴하기 
		add $f0, $f1, $zero			# $f0 = tempMinCost (return value)
# 얘도 위처럼
		addi $sp, $sp, 12			# ????????????????????????
		addi $s0, $s0, 10			# count #instructions
		jr $ra
		




#보희 코드
add $a0, $zero, $s0      	# pass $s0(= i) as argument1
addi $a1, $a1, 1		# pass cntVisit+1 as argument2

#??????????????????????????
addi $sp, $sp, -12
swc1 $f3, 0($sp)		# save dist[v][i]
sw $s0, 4($sp)		# save i
swc1 $f2, 8($sp)		# save tmp
#??????????????????????????

addi $s5, $s5, 16            # count Instruction

jal DFS			# DFS(i, cntVisit+1)

#??????????????????????????
lwc1 $f3, 0($sp)		# restore dist[v][i]
lw $s0, 4($sp)		# restore i
lwc1 $f2, 8($sp)		# restore tmp
addi $sp, $sp, 12
#??????????????????????????
lw $a0, 0($sp)
lw $a1, 4($sp)