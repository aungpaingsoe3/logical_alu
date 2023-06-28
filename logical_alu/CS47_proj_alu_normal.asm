.include "./cs47_proj_macro.asm"
.text
.globl au_normal
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_normal
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_normal:
# TBD: Complete it
	addi	$sp, $sp, -24
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2, 8($sp)
	addi	$fp, $sp, 24
	
	beq	$a2, '+', add_normal
	beq	$a2, '-', sub_normal
	beq	$a2, '*', mul_normal
	beq	$a2, '/', div_normal
	
add_normal:
	add	$v0, $a0, $a1
	j	end_operation
sub_normal:
	sub	$v0, $a0, $a1
	j	end_operation
mul_normal:
	mul	$v0, $a0, $a1
	mflo	$v0
	mfhi	$v1
	j	end_operation
div_normal:
	div	$a0, $a1
	mflo	$v0
	mfhi	$v1
	j	end_operation

end_operation:
	lw	$fp, 24($sp)
	lw	$ra, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw	$a2, 8($sp)
	addi	$sp, $sp, 24
	jr	$ra
