# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#
	# Macro: extract_nth_bit
	# Usage: extract_nth_bit(<nth bit>, <Source bit pattern>, <Bit position>)
	.macro	extract_nth_bit($regD, $regS, $regT)			
	srlv	$regD, $regS, $regT 	
	and	$regD, $regD, 0x1
	.end_macro
	
	# Macro: insert_to_nth_bit
	# Usage: insert_to_nth_bit(<bit pattern to be inserted at nth position>, <Value n>, 
	#                          <Register that contain bit to be inserted>. 
	#			   <Register to hold temporary mask>)
	.macro	insert_to_nth_bit($regD, $regS, $regT, $maskReg)
	li	$maskReg, 0x1
	sllv 	$maskReg, $maskReg, $regS
	not	$maskReg, $maskReg
	and	$regD, $regD, $maskReg
	sllv	$regT, $regT, $regS
	or	$regD, $regD, $regT
	.end_macro
	
	# Macro: store_frame
	# Usage: Stores frames used in logical procedure implementations
	.macro	store_frame
	addi	$sp, $sp, -56
	sw	$fp, 56($sp)
	sw	$ra, 52($sp)
	sw	$a0, 48($sp)
	sw	$a1, 44($sp)
	sw	$a2, 40($sp)
	sw	$s0, 36($sp)
	sw	$s1, 32($sp)
	sw	$s2, 28($sp)
	sw	$s3, 24($sp)
	sw	$s4, 20($sp)
	sw	$s5, 16($sp)
	sw	$s6, 12($sp)
	sw	$s7, 8($sp)
	addi	$fp, $sp, 56
	.end_macro
	
	# Macro: restore_frame
	# Usage: Restores frames used in logical procedure implementations
	.macro	restore_frame
	lw	$fp, 56($sp)
	lw	$ra, 52($sp)
	lw	$a0, 48($sp)
	lw	$a1, 44($sp)
	lw	$a2, 40($sp)
	lw	$s0, 36($sp)
	lw	$s1, 32($sp)
	lw	$s2, 28($sp)
	lw	$s3, 24($sp)
	lw	$s4, 20($sp)
	lw	$s5, 16($sp)
	lw	$s6, 12($sp)
	lw	$s7, 8($sp)
	addi	$sp, $sp, 56
	jr	$ra
	.end_macro
	
