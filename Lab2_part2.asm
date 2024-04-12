# CMPEN 331, Lab 2_part2

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# switch to the Data segment
	.data
	# global data is defined here

	# Don't forget the backslash-n (newline character)
Homework:
	.asciiz	"CMPEN 331 Homework 2\n"
Name:
	.asciiz	"Grant Allen\n"
 

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# switch to the Text segment
	.text
	# the program is defined here

	.globl	main
main:
	# Whose program is this?
	la	$a0, Homework
	jal	Print_string
	la	$a0, Name
	jal	Print_string
	
	# int i, j = 2, n = 3;
	# for (i = 0; i <= 16; i++)
	#   {
	#      ... j = testcase[i]
	#      ... calculate n from j
	#      ... print i, j and n
	#   }
	
	# register assignments
	#  $s0   i
	#  $s1   j = testcase[i]
	#  $s2   n
	#  $t0   address of testcase[i]
	#  $a0   argument to Print_integer, Print_string, etc.
	#  add to this list if you use any other registers

	# initialization
	li	$s1, 2			# j = 2
	li	$s2, 3			# n = 3
	
	# for (i = 0; i <= 16; i++)
	li	$s0, 0			# i = 0
	la	$t0, testcase		# address of testcase[i]
	bgt	$s0, 16, bottom
top:
	lw	$s1, 0($t0)		# j = testcase[i]
	# calculate n from j
	# Your part starts here
	li $t1, 0
	srl $t2, $s1, 7 		# shifts the bits to the right to see if they all fit in 7 bits
	bgt $t2, $t1, Else1		# if 8 or more bits, then go to Else1
	move $s2, $s1			# n = j
	j Output
	
Else1:	
	srl $t2, $s1, 11		# shifts bits to see if they all can fit in 11 bits
	bgt $t2, $t1, Else2		# if 12 or more bits, go to Else2
	srl $t3, $s1, 6			# $t3 = aaaaa
	li $t4, 6			# $t4 = 110
	sll $t4, $t4, 5			# 110 00000
	or $t4, $t3, $t4		# 110 aaaaa
	sll $t4, $t4, 8			# 11 aaaaa 00 000000
	ori $t4, $t4, 0x80              # 11 aaaaa 10 000000
	andi $t3, $s1, 0x003f		# bbbbbb
	or $s2, $t3, $t4		# n = 1110 aaaa 10 bbbbbb
	j Output
	
Else2:	
	srl $t2, $s1, 16		# shifts bits to see if they all can fit in 16 bits
	bgt $t2, $t1, Else3		# if 17 or more bits, go to Else3
	srl $t3, $s1, 12		# $t3 = aaaa
	li $t4, 14			# $t4 = 1110
	sll $t4, $t4, 4			# 1110 0000
	or $t4, $t3, $t4		# 1110 aaaa
	sll $t4, $t4, 2			# 1110 aaaa 00
	ori $t4, $t4, 2			# 1110 aaaa 10
	sll $t4, $t4, 6 		# 1110 aaaa 10 000000
	srl $t3, $s1 , 6		# aaaa bbbbbb
	andi $t3, $t3, 0x003f		# bbbbbb
	or $t4, $t3, $t4		# 1110 aaaa 10 bbbbbb
	sll $t4, $t4, 2			# 1110 aaaa 10 bbbbbb 00
	ori $t4, $t4, 2			# 1110 aaaa 10 bbbbbb 10 
	sll $t4, $t4, 6			# 1110 aaaa 10 bbbbbb 10 000000
	andi $t3, $s1, 0x003f		# cccccc
	or $s2, $t3, $t4		# n = 1110 aaaa 10 bbbbbb 10 cccccc
	j Output
	
Else3:
	srl $t2, $s1, 16		# shifts by 16
	li $t1, 0x80			# loads 1000 0000
	bgt $t2, $t1, Else4		# if remaining bits are greater than 1000 0000, go to Else4
	srl $t3, $s1, 18		#$t3 = aaa
	li $t4, 30			# $t4 = 11110
	sll $t4, $t4, 3			# 11110 000
	or $t4, $t3, $t4		# 11110 aaa
	sll $t4, $t4, 2			# 1110 aaaa 00
	ori $t4, $t4, 2			# 1110 aaaa 10
	sll $t4, $t4, 6 		# 1110 aaaa 10 000000
	srl $t3, $s1 , 12		# aaa bbbbbb
	andi $t3, $t3, 0x003f		# bbbbbb
	or $t4, $t3, $t4		# 1110 aaaa 10 bbbbbb
	sll $t4, $t4, 2			# 1110 aaaa 10 bbbbbb 00
	ori $t4, $t4, 2			# 1110 aaaa 10 bbbbbb 10 
	sll $t4, $t4, 6			# 1110 aaaa 10 bbbbbb 10 000000
	srl $t3, $s1 , 6		# aaa bbbbbb cccccc
	andi $t3, $t3, 0x003f		# cccccc
	or $t4, $t3, $t4		# 11110 aaa 10 bbbbbb 10 cccccc
	sll $t4, $t4, 2			# 11110 aaa 10 bbbbbb 10 cccccc 00
	ori $t4, $t4, 2			# 11110 aaa 10 bbbbbb 10 cccccc 10
	sll $t4, $t4, 6			# 11110 aaa 10 bbbbbb 10 cccccc 10 000000
	andi $t3, $s1, 0x003f		# dddddd
	or $s2, $t3, $t4		# n = 11110 aaa 10 bbbbbb 10 cccccc 10 dddddd
	j Output
	
Else4:	
	lui $t3, 0xffff			#ffff0000
	ori $s2, $t3, 0xffff		#ffffffff		
	j Output
	# Your part ends here
Output:	
	# print i, j and n
	move	$a0, $s0	# i
	jal	Print_integer
	la	$a0, sp		# space
	jal	Print_string
	move	$a0, $s1	# j
	jal	Print_hex
	la	$a0, sp		# space
	jal	Print_string
	move	$a0, $s2	# n
	jal	Print_hex
	la	$a0, sp		# space
	jal	Print_string
	move	$a0, $s1	# j
	jal	Print_bin
	la	$a0, sp		# space
	jal	Print_string
	move	$a0, $s2	# n
	jal	Print_bin
	la	$a0, nl		# newline
	jal	Print_string
	
	# for (i = 0; i <= 16; i++)
	addi	$s0, $s0, 1	# i++
	addi	$t0, $t0, 4	# address of testcase[i]
	ble	$s0, 16, top	# i <= 16
bottom:
	
	la	$a0, done	# mark the end of the program
	jal	Print_string
	
	jal	Exit0	# end the program, default return status

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	.data
	# global data is defined here
sp:
	.asciiz	" "	# space
nl:
	.asciiz	"\n"	# newline
done:
	.asciiz	"All done!\n"

testcase:
	# UTF-8 representation is one byte
	.word 0x0000	# nul		# Basic Latin, 0000 - 007F
	.word 0x0024	# $ (dollar sign)
	.word 0x007E	# ~ (tilde)
	.word 0x007F	# del

	# UTF-8 representation is two bytes
	.word 0x0080	# pad		# Latin-1 Supplement, 0080 - 00FF
	.word 0x00A2	# cent sign
	.word 0x0627	# Arabic letter alef
	.word 0x07FF	# unassigned

	# UTF-8 representation is three bytes
	.word 0x0800
	.word 0x20AC	# Euro sign
	.word 0x2233	# anticlockwise contour integral sign
	.word 0xFFFF

	# UTF-8 representation is four bytes
	.word 0x10000
	.word 0x10348	# Hwair, see http://en.wikipedia.org/wiki/Hwair
	.word 0x22E13	# randomly-chosen character
	.word 0x10FFFF

	.word 0x89ABCDEF	# randomly chosen bogus value

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Wrapper functions around some of the system calls
# See P&H COD, Fig. A.9.1, for the complete list.

	.text

	.globl	Print_integer
Print_integer:	# print the integer in register $a0 (decimal)
	li	$v0, 1
	syscall
	jr	$ra

	.globl	Print_string
Print_string:	# print the string whose starting address is in register $a0
	li	$v0, 4
	syscall
	jr	$ra

	.globl	Exit
Exit:		# end the program, no explicit return status
	li	$v0, 10
	syscall
	jr	$ra	# this instruction is never executed

	.globl	Exit0
Exit0:		# end the program, default return status
	li	$a0, 0	# return status 0
	li	$v0, 17
	syscall
	jr	$ra	# this instruction is never executed

	.globl	Exit2
Exit2:		# end the program, with return status from register $a0
	li	$v0, 17
	syscall
	jr	$ra	# this instruction is never executed

# The following syscalls work on MARS, but not on QtSPIM

	.globl	Print_hex
Print_hex:	# print the integer in register $a0 (hexadecimal)
	li	$v0, 34
	syscall
	jr	$ra

	.globl	Print_bin
Print_bin:	# print the integer in register $a0 (binary)
	li	$v0, 35
	syscall
	jr	$ra

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
