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
		addi $s0, $zero, 3			# count #instructions


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

		mtc1 $t4, $f1				# $f0 = $t4, move to coprocessor1
		cvt.s.w $f2, $f1			# convert from integer($f0) to single($f1)
		sprt.s $f3, $f2				# $f2 = sqrt(pow(city[i][0] - city[j][0], 2) + pow(city[i][1] - city[j][1], 2))

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
		add $a0, $zero, $zero		# argument1 = 0
		addi $a1, $zero, 1			# argument2 = 1
		addi $s0, $s0, 3			# count #instructions
		jal getMinCost				# call getMinCost(0, 1)
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
		beq $t0, $zero, return

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




	getMinCost:



	getMinPath:

