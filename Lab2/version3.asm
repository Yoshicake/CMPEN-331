	.text
	
	.globl main
	
main:
	la $a0, hello_string
	jal Print_string
	jal Exit0
	
	.data
	
hello_string:
	.asciiz "Hello, world\n"
	
#---------------------------------

	.text

	.globl Print_integer

Print_integer:
	
	li $v0, 1
	syscall
	jr $ra
	
	.globl Print_string
	
Print_string:
	li $v0, 4
	syscall
	jr $ra
	
	.globl Exit
	
Exit: 
	li $v0, 10
	syscall
	jr $ra
	
	.globl Exit0
	
Exit0:
	li $a0, 0
	li $v0, 17
	syscall
	jr $ra
	
	.globl Exit2
	
Exit2:
	li $v0, 17
	syscall
	jr $ra