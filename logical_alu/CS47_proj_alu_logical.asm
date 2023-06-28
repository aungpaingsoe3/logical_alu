.include "./cs47_proj_macro.asm"
.text
.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1) | Final carry out bit in addition process
# Notes:
#####################################################################
au_logical:
# TBD: Complete it
	store_frame
	beq	$a2, '+', add_logical
	beq	$a2, '-', sub_logical
	beq	$a2, '*', mul_logical
	beq	$a2, '/', div_logical
	j	end_operation

add_logical:
	store_frame
	li	$a2, 0x00000000
	jal	add_sub_logical
	restore_frame
	
sub_logical:
	store_frame
	li	$a2, 0xFFFFFFFF
	jal	add_sub_logical
	restore_frame

mul_logical:
	store_frame
	jal	mul_signed
	restore_frame

div_logical:
	store_frame
	jal	div_signed
	restore_frame

end_operation:
	restore_frame

#############################################################################
# Implementation of add_sub_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: Mode (0x00000000 for Addition and 0xFFFFFFFF for Subtraction)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1)
# 	$v1: Final carry out bit in addition process
# Notes:
#############################################################################
add_sub_logical:
	store_frame
	add	$t0, $zero, $zero	# I = 0
	add	$v0, $zero, $zero	# S = 0
	extract_nth_bit($v1, $a2, $zero) 	# C = $a2[0]
	beq	$v1, $zero, add_process	# If C = 0 --> Process of Addition
	not	$a1, $a1	# Subtraction --> $a1 = ~$a1
add_process:
	beq	$t0, 32, end_add_sub_logical	# If I = 32, end addition process
	extract_nth_bit($t2, $a0, $t0)		# $t2 = $a0[I]
	extract_nth_bit($t3, $a1, $t0)		# $t3 = $a1[I]
	xor	$t4, $t2, $t3			# $t4 = $t2 ($a0[I]) xor $t3 ($a1[I])
	xor	$t5, $t4, $v1			# $t5 (Y) = $t4 xor $v1(C)
	and	$v1, $t4, $v1			# $v1 (C) = $t4 ($a0[I] xor $a1[I]) and $v1 (C)
	and	$t6, $t2, $t3			# $t6 = $t2 ($a0[I]) and $t3 ($a1[I])
	or 	$v1, $v1, $t6			# C = C or $t6
	insert_to_nth_bit($v0, $t0, $t5, $t9)	# S[I] = Y
	addi	$t0, $t0, 1			# I = I + 1
	j	add_process
	
end_add_sub_logical:
	restore_frame

#############################################################################
# Implementation of twos_complement
# Argument:
# 	$a0: Number which two's complment to be computed
# Return:
#	$v0: Two's complement of $a0
# Notes:
#############################################################################	
twos_complement:
	store_frame
	la	$s0, ($a0)		# $s0 = $a0
	not	$s0, $s0		# $s0 = ~$s0
	la	$a0, ($s0)		# Reload the not value to $a0
	li	$a1, 1			# Add $a0 and 1
	jal	add_logical
	restore_frame
	
#############################################################################
# Implementation of twos_complement_if_neg
# Argument:
# 	$a0: Number which two's complment to be computed
# Return:
#	$v0: Two's complement of $a0 if $a0 is negative
# Notes:
#############################################################################
twos_complement_if_neg:
	store_frame
	bltz	$a0, twos_procedure_call	# If $a0 >= 0 --> Positive num
	move	$v0, $a0			# Positive num --> Return $a0
	j	end_twos_complement_if_neg
twos_procedure_call:
	jal	twos_complement
	
end_twos_complement_if_neg:
	restore_frame

#########################################################################
# Implementation of twos_complement_64bit
# Argument:
# 	$a0: Lo of number
# 	$a1: Hi of number
# Return:
#	$v0: Lo part of two's complemented 64 bit
#	$v1: Hi part of two's complemented 64 bit
# Notes:
#########################################################################
twos_complement_64bit:
	store_frame
	la	$s0, ($a0)	# $s0 = $a0
	la	$s1, ($a1)	# $s1 = $a1
	not	$s2, $s0	# $s2 = ~$s0 (~$a0)
	not	$s3, $s1	# $s3 = ~$s1 (~$a1)
	la	$a0, ($s2)	# Reload $s2 to $a0
	li	$a1, 1		# $s4 = $a0 + 1
	jal	add_logical
	move	$s4, $v0
	move	$a0, $v1	# $a0 = Carry out bit from the previous addition
	move	$a1, $s3	# $a1 = $s3 (~$s1 == ~$a1)
	jal	add_logical	# $v1 = $a1 + $a0 (Carry out bit from previous addition)
	move	$v1, $v0	
	move	$v0, $s4	# $v0 = The sum of $a0 and 1
	restore_frame
	
#############################################################################
# Implementation of bit_replicator
# Argument:
# 	$a0: 0x0 or 0x1 (The bit value to be replicated)
# Return:
#	$v0: 0x00000000 if $a0 = 0x0
#	     0xFFFFFFFF if $a1 = 0x1
# Notes:
#############################################################################
bit_replicator:
	store_frame
	beqz	$a0, zero_value		# If $a0 == 0 --> go to zero_value
	li	$v0, 0xFFFFFFFF		# Else, load $v0 with 0xFFFFFFFF
	j	end_bit_replicator
	
zero_value:
	li	$v0, 0x00000000		# Load $v0 with 0x00000000 ($a0 == 0 case)

end_bit_replicator:
	restore_frame
	
#############################################################################
# Implementation of mul_unsigned
# Argument:
# 	$a0: Multiplicand
#	$a1: Multiplier
# Return:
#	$v0: Lo Part of result
# 	$v1: Hi part of result
# Notes:
#############################################################################
mul_unsigned:
	store_frame
	li	$s0, 0		# I = 0
	li	$s1, 0		# H = 0
	la	$s2, ($a1)	# L = Multiplier ($a1)
	la	$s3, ($a0)	# M = Multiplicand ($a0)
	
mul_process:
	beq	$s0, 32, end_mul_unsigned	# If I == 32 --> Finish process
	extract_nth_bit($a0, $s2, $zero)	# $a0 = L[0]
	jal	bit_replicator			# R ($s4) = {32{$a0 (L[0])}}
	move	$s4, $v0
	and	$s5, $s3, $s4			# X ($s5) = M ($s3) & R ($s4)
	la	$a0, ($s1)
	la	$a1, ($s5)
	jal	add_logical			# H ($s1) = H + X ($s5)
	move	$s1, $v0
	srl	$s2, $s2, 1			# L ($s2) = L >> 1
	extract_nth_bit($t1, $s1, $zero)	# L[31] ($s2) = H[0] ($t1)
	li	$t8, 31	
	insert_to_nth_bit($s2, $t8, $t1, $t9)
	srl	$s1, $s1, 1			# H ($s1) = H >> 1
	addi	$s0, $s0, 1			# I ($s0) = $s0 + 1
	j	mul_process

end_mul_unsigned:
	move	$v0, $s2
	move	$v1, $s1
	restore_frame
	
#############################################################################
# Implementation of mul_signed
# Argument:
# 	$a0: Multiplicand
#	$a1: Multiplier
# Return:
#	$v0: Lo part of result
#	$v1: Hi part of result    
# Notes:
#############################################################################
mul_signed:
	store_frame
	la	$s0, ($a0)			# N1 ($s0) = $a0
	la	$s1, ($a1)			# N2 ($s1) = $a1
	jal	twos_complement_if_neg		# N1 ($s2) = N1's two's complement if negative
	move	$s2, $v0
	la	$a0, ($s1)			# $a0 = N2 ($s1)
	jal	twos_complement_if_neg		# N2 ($s3) = N2's two's complement if negative
	move	$s3, $v0
	la	$a0, ($s2)			# Reload $a0 with $s2 
	la	$a1, ($s3)			# Reload $a1 with $s3
	jal	mul_unsigned
	move	$s4, $v0			# Rlo ($s4) = Lo part of $a0 * $a1
	move	$s5, $v1			# Rhi ($s5) = Hi part of $a1 * $a1
	li	$t0, 31
	extract_nth_bit($s6, $s0, $t0)		# $s6 = $a0[31]
	extract_nth_bit($s7, $s1, $t0)		# $s7 = $a1[31]
	xor 	$t3, $s6, $s7			# S ($t3) = $a0[31] ($s6) xor $a1[31] ($s7)
	beqz	$t3, end_mul_signed		# If S == 0 --> End process
	la	$a0, ($s4)
	la	$a1, ($s5)
	jal	twos_complement_64bit		# Else, Rlo ($s4) & Rhi ($s5) goes through twos_complement_64bit
	move	$s4, $v0
	move	$s5, $v1
	j	end_mul_signed
	
end_mul_signed:
	move	$v0, $s4
	move	$v1, $s5
	restore_frame
	
#############################################################################
# Implementation of div_unsigned
# Argument:
# 	$a0: Dividend
#	$a1: Divisor
# Return:
#	$v0: Quotient
#	$v1: Remainder
# Notes:
#############################################################################
div_unsigned:
	store_frame
	li	$s0, 0		# I ($s0) = 0
	la	$s1, ($a0)	# Q ($s1) = Dividend
	la	$s2, ($a1)	# D ($s2) = Divisor
	li	$s3, 0		# R ($s3) = 0

div_process:
	beq	$s0, 32, end_div_unsigned
	sll	$s3, $s3, 1			# R ($s3) = R << 1
	li	$t8, 31
	extract_nth_bit($t1, $s1, $t8)		# R[0] = Q[31]
	insert_to_nth_bit($s3, $zero, $t1, $t9)
	sll	$s1, $s1, 1			# Q ($s1) = Q << 1
	la	$a0, ($s3)			# S ($s4) = R - D
	la	$a1, ($s2)		
	jal	sub_logical
	move	$s4, $v0
	bltz	$s4, increment			# If S < 0 --> Increment
	la	$s3, ($s4)			# R = S
	li	$t5, 1				# Q[0] = 1
	insert_to_nth_bit($s1, $zero, $t5, $t9)
increment:
	addi	$s0, $s0, 1			# I ($s0) = I + 1
	j	div_process
	
end_div_unsigned:
	move	$v0, $s1
	move	$v1, $s3
	restore_frame
	
#############################################################################
# Implementation of div_signed
# Argument:
# 	$a0: Dividend
#	$a1: Divisor
# Return:
#	$v0: Quotient
#	$v1: Remainder
# Notes:
#############################################################################
div_signed:
	store_frame
	la	$s0, ($a0)	# N1 = $a0
	la	$s1, ($a1)	# N2 = $a1
	jal	twos_complement_if_neg
	move	$s2, $v0	# $s2 = 2's complement of $a0 if negative
	la	$a0, ($s1)	
	jal	twos_complement_if_neg
	move	$s3, $v0	# $s3 = 2's complement of $a1 if negative
	la	$a0, ($s2)	# Call div_unsigned with N1 and N2
	la	$a1, ($s3)
	jal	div_unsigned
	move	$s4, $v0	# $s4 = Quotient
	move	$s5, $v1	# $s5 = Remainder
	li	$t7, 31
	extract_nth_bit($s6, $s0, $t7)		# $a0[31] 
	extract_nth_bit($s7, $s1, $t7)		# $a1[31]
	xor	$t4, $s6, $s7			# S = $a0[31] xor $a1[31]
	bne	$t4, 1, remainder_sign		# If S != 1 --> Move onto checking remainder's sign
	move	$a0, $s4			# Calculate Q's two's complement
	jal	twos_complement
	move	$s4, $v0
	
remainder_sign: 
 	bne	$s6, 1, end_div_signed		# If $a0[31] != 1 --> Finish the process 
 	move	$a0, $s5			# Else --> Calculate R's two's complement
 	jal	twos_complement
 	move	$s5, $v0
	
end_div_signed:
	move	$v0, $s4
	move	$v1, $s5
	restore_frame

