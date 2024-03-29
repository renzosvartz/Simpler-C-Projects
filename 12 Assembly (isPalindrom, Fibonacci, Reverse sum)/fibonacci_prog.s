   .data

# array terminated by 0 (which is not part of the array)
xarr:
   .word 1
   .word 2
   .word 3
   .word 4
   .word 10
   .word 11
   .word 12
   .word 13
   .word 14
   .word 15
   .word 16
   .word 17
   .word 18
   .word 19
   .word 20
   .word 21
   .word 22
   .word 23
   .word 24
   .word 0

   .text

# main(): ##################################################
#   uint* j = xarr
#   while (*j != 0):
#     printf(" %d\n", fibonacci(*j))
#     j++
#
main:
   li   $sp, 0x7ffffffc    # initialize $sp

   # PROLOGUE
   subu $sp, $sp, 8        # expand stack by 8 bytes
   sw   $ra, 8($sp)        # push $ra (ret addr, 4 bytes)
   sw   $fp, 4($sp)        # push $fp (4 bytes)
   addu $fp, $sp, 8        # set $fp to saved $ra

   subu $sp, $sp, 8        # save s0, s1 on stack before using them
   sw   $s0, 8($sp)        # push $s0
   sw   $s1, 4($sp)        # push $s1

   la   $s0, xarr          # use s0 for j. init to xarr
main_while:
   lw   $s1, ($s0)         # use s1 for *j
   beqz $s1, main_end      # if *j == 0 go to main_end
   move $a0, $s1
   jal  fibonacci          # result = fibonacci(*j)
   move $a0, $v0           # print_int(result)
   li   $v0, 1
   syscall
   li   $a0, 10            # print_char('\n')
   li   $v0, 11
   syscall
   addu $s0, $s0, 4        # j++
   b    main_while
main_end:
   lw   $s0, -8($fp)       # restore s0
   lw   $s1, -12($fp)      # restore s1

   # EPILOGUE
   move $sp, $fp           # restore $sp
   lw   $ra, ($fp)         # restore saved $ra
   lw   $fp, -4($sp)       # restore saved $fp
   j    $ra                # return to kernel
## end main #################################################
fibonacci:

        #PROLOGUE
        subu $sp, $sp, 8        # expand stack by 8 bytes
        sw   $ra, 8($sp)        # push $ra (ret addr, 4 bytes)
        sw   $fp, 4($sp)        # push $fp (4 bytes)
        addu $fp, $sp, 8        # set $fp to saved $ra

	li   $v0, 0

	#BASE CASE(S)
        beqz $a0, ret0   	# return 0/1
        beq  $a0, 1, ret1
		
        #RECURSION n - 1        # fibonacci(n - 1)
	sub  $sp, $sp, 8	# store n and sum
	sw   $a0, 8($sp)
	sw   $v0, 4($sp)	
	sub  $a0, $a0, 1	# n - 1 for fibonacci(n - 1)
	jal  fibonacci		# stores fib(n - 1) in $v0
	lw   $t0, 4($sp)	# load current result, add to return $v0
	add  $v0, $t0, $v0 	# + fibonacci(n - 1)
	sw   $v0, 4($sp)	# store updated result

	#RECURSION n - 2
	lw   $a0, 8($sp)	# restores $a0 for fib(n - 2) if applicable
	blt  $a0, 2, epl
	sub  $a0, $a0, 2        # fib(n - 2)
        jal  fibonacci
	lw   $t0, 4($sp)
        add  $v0, $t0, $v0      # + fib(n - 2)
	j    epl
	
ret0:
	li   $v0, 0		# return 0
	j    epl
ret1:
	li   $v0, 1		# return 1
	j    epl

epl:
        # EPILOGUE
        move $sp, $fp           # restore $sp
        lw   $ra, ($fp)         # restore saved $ra
        lw   $fp, -4($sp)       # restore saved $fp
        j    $ra                # return to caller


