#####################################################################
#
# CSCB58 Winter 2022 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Name, Student Number, UTorID, official email
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4 (update this as needed)
# - Unit height in pixels: 4 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3 (choose the one the applies)
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes / no / yes, and please share this project github link as well!
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################
# https://youtu.be/YC7dBJ-KXZE

.eqv BASE_ADDRESS 0x10008000
.eqv KEYCHECK_ADDRESS 0xffff0000 
.data
str: .asciiz "THE GAME IS OVER\n"
str1: .asciiz "YOU WIN\n "
str2: .asciiz "score:  "
str3: .asciiz "\n "
.text
main:
	# let ********* $a1 ********** store the adress of charactor.(center)
	# let ********* $a2 ********** store the adress of platform_1.(center)
	# let ********* $a3 ********** store the adress of platform_2.(center)
	# let ********* $s0 ********** store the adress of platform_3.(center)
	# let ********* $t7 ********** store the adress of star.(center)
	# let ********* $s2 ********** store the score you get now.(center)
	jal make_backgroud # make_backgroud()
	jal initial_char
	jal initial_platform
	li $s5, 0
	li $s6, 0
	li $s4, 0
	li $s2, 0
	
	add $t1, $zero, $a1
	jal random_star
	lw $t7, 0($sp)
	addi $sp, $sp, 4
	add $a1, $zero, $t1
	li $t5, 0x00ffff
	sw $t5, 0($t7)
	

	j check_loop
	# --------------------------------------------------------------------
check_loop:
	li $v0, 32
	li $a0, 40 # Wait one second (1000 milliseconds)
	syscall
	# whether the char touch the lava
	li $t0, 256
	li $t1, BASE_ADDRESS
	sub $t2, $a1, $t1
	div $t2, $t0
	mflo $t3
	beq $t3, 61, touch_lava
	# whether the char touch the star
	lw $t1, 0($t7)
	beq $t1, 0x000000, get_star
	# whether the char touch the highest platform
	beq $s2, 1, win
	# move the platform 1
	addi $sp, $sp, -4
	sw $a2, 0($sp)
	addi $sp, $sp, -4
	sw $s5, 0($sp)
	jal move_pf
	lw $s5, 0($sp)
	addi $sp, $sp, 4
	lw $a2, 0($sp)
	addi $sp, $sp, 4
	# move the platform 2
	addi $sp, $sp, -4
	sw $a3, 0($sp)
	addi $sp, $sp, -4
	sw $s6, 0($sp)
	jal move_pf
	lw $s6, 0($sp)
	addi $sp, $sp, 4
	lw $a3, 0($sp)
	addi $sp, $sp, 4
	# move the platform 3
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	addi $sp, $sp, -4
	sw $s4, 0($sp)
	jal move_pf
	lw $s4, 0($sp)
	addi $sp, $sp, 4
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	
	# whether the char touch the platforms
	li $t6, 0
	# check platform_1
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	addi $sp, $sp, -4
	sw $a2, 0($sp)
	jal touch_platform_down
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	add $t6, $t6, $t1
	# whether the char touch the platform_2
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	addi $sp, $sp, -4
	sw $a3, 0($sp)
	jal touch_platform_down
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	add $t6, $t6, $t1
	# whether the char touch the platform_3
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	jal touch_platform_down
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	add $t6, $t6, $t1
	
	beq $t6, 0, gravity_down
	
check_loop_1:
	
	jal check_key
	lw $t2, 0($sp)
	addi $sp, $sp, 4
	beq $t2, -1, continue
	beq $t2, 0x61, move_left       # a
	beq $t2, 0x64, move_right   # d
	beq $t2, 0x77, move_up      # w
	beq $t2, 0x73, move_down   # s
	jal update_char
	j continue
continue:
	j check_loop
move_left:
	# whether the char touch the left screen
	li $t0, 256
	li $t1, BASE_ADDRESS
	sub $t2, $a1, $t1
	div $t2, $t0
	mfhi $t3
	beq $t3, 4, touch_bdr
	# whether the char touch the ceiling of board
	li $t6, 0
	# check platform_1
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	addi $sp, $sp, -4
	sw $a2, 0($sp)
	jal touch_platform_left
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	add $t6, $t6, $t1
	# whether the char touch the platform_2
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	addi $sp, $sp, -4
	sw $a3, 0($sp)
	jal touch_platform_left
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	add $t6, $t6, $t1
	# whether the char touch the platform_3
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	jal touch_platform_left
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	add $t6, $t6, $t1
	
	beq $t6, 0, valid_move_left
	bgt $t6, 0, touch_bdr
move_right:
	# whether the char touch the right screen
	li $t0, 256
	li $t1, BASE_ADDRESS
	sub $t2, $a1, $t1
	div $t2, $t0
	mfhi $t3
	beq $t3, 248, touch_bdr
	# whether the char touch the ceiling of board
	li $t6, 0
	# check platform_1
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	addi $sp, $sp, -4
	sw $a2, 0($sp)
	jal touch_platform_right
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	add $t6, $t6, $t1
	# whether the char touch the platform_2
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	addi $sp, $sp, -4
	sw $a3, 0($sp)
	jal touch_platform_right
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	add $t6, $t6, $t1
	# whether the char touch the platform_3
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	jal touch_platform_right
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	add $t6, $t6, $t1
	
	beq $t6, 0, valid_move_right
	bgt $t6, 0, touch_bdr
move_up:
	# whether the char touch the platforms
	li $t6, 0
	# check platform_1
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	addi $sp, $sp, -4
	sw $a2, 0($sp)
	jal touch_platform_down
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	add $t6, $t6, $t1
	# whether the char touch the platform_2
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	addi $sp, $sp, -4
	sw $a3, 0($sp)
	jal touch_platform_down
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	add $t6, $t6, $t1
	# whether the char touch the platform_3
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	jal touch_platform_down
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	add $t6, $t6, $t1
	
	beq $t6, 0, touch_bdr
	
	li $t1, 8
	addi $sp, $sp, -4
	sw $t1, 0($sp)
	jal move_up_n_times
	
	li $t1, 4
	addi $sp, $sp, -4
	sw $t1, 0($sp)
	jal move_up_n_times
	
	li $t1, 2
	addi $sp, $sp, -4
	sw $t1, 0($sp)
	jal move_up_n_times
	
	li $t1, 1
	addi $sp, $sp, -4
	sw $t1, 0($sp)
	jal move_up_n_times
	j check_loop
move_up_n_times:
	lw $s1, 0($sp)
	addi $sp, $sp, 4
	li $t4, 0
	addi $sp, $sp, -4
	sw $ra, 0($sp)
move_up_n_times_loop:
	beq $t4, $s1, move_up_n_times_return
	# whether the char touch the ceiling
	li $t0, 256
	li $t1, BASE_ADDRESS
	sub $t2, $a1, $t1
	div $t2, $t0
	mflo $t3
	beq $t3, 1, touch_bdr
	# whether the char touch the ceiling of board
	li $t6, 0
	# check platform_1
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	addi $sp, $sp, -4
	sw $a2, 0($sp)
	jal touch_platform_up
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	add $t6, $t6, $t1
	# whether the char touch the platform_2
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	addi $sp, $sp, -4
	sw $a3, 0($sp)
	jal touch_platform_up
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	add $t6, $t6, $t1
	# whether the char touch the platform_3
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	jal touch_platform_up
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	add $t6, $t6, $t1
	
	bgt $t6, 0, touch_bdr
	jal valid_move_up_func
	addi $t4, $t4, 1
	j move_up_n_times_loop
move_up_n_times_return:
	li $v0, 32
	li $a0, 40 # Wait one second (1000 milliseconds)
	syscall
	lw $ra, 0($sp)
	addi, $sp, $sp, 4
	jr $ra
move_down:
	# whether the char touch the lava
	li $t0, 256
	li $t1, BASE_ADDRESS
	sub $t2, $a1, $t1
	div $t2, $t0
	mflo $t3
	beq $t3, 61, touch_lava
	# whether the char touch the platforms
	li $t6, 0
	# check platform_1
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	addi $sp, $sp, -4
	sw $a2, 0($sp)
	jal touch_platform_down
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	add $t6, $t6, $t1
	# whether the char touch the platform_2
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	addi $sp, $sp, -4
	sw $a3, 0($sp)
	jal touch_platform_down
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	add $t6, $t6, $t1
	# whether the char touch the platform_3
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	jal touch_platform_down
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	add $t6, $t6, $t1
		
	beq $t6, 0, valid_move_down
	bgt $t6, 0, touch_bdr
	
#   --------------------------------------
touch_platform_down:
	# touch_platform_down(char, platform)
	# return 0 if char not on the platform. return 1 if char on the platform
	lw $t2, 0($sp)
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	addi $t3, $t2, -492
	addi $t4, $t2, -532
	
	bgt $t1, $t3, untouch_down
	blt $t1, $t4, untouch_down
	
	addi $t5, $zero, 1
	addi $sp, $sp, -4
	sw $t5, 0($sp)
	jr $ra
untouch_down:
	li $t5, 0
	addi $sp, $sp, -4
	sw $t5, 0($sp)
	jr $ra
#   --------------------------------------
touch_platform_up:
	# touch_platform_down(char, platform)
	# return 0 if char not on the platform. return 1 if char on the platform
	lw $t2, 0($sp)
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	addi $t3, $t2, 492
	addi $t4, $t2, 532
	
	blt $t1, $t3, untouch_up
	bgt $t1, $t4, untouch_up
	
	addi $t5, $zero, 1
	addi $sp, $sp, -4
	sw $t5, 0($sp)
	jr $ra
untouch_up:
	li $t5, 0
	addi $sp, $sp, -4
	sw $t5, 0($sp)
	jr $ra
#   --------------------------------------
touch_platform_left:
	# touch_platform_right(char, platform)
	# return 0 if char not on the platform. return 1 if char on the platform
	lw $t2, 0($sp)
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	addi $t3, $t1, -256
	addi $t4, $t1, 256
	addi $t5, $t2, 24
	
	beq $t5, $t1, touch_left
	beq $t5, $t3, touch_left
	beq $t5, $t4, touch_left
	
	addi $s7, $zero, 0
	addi $sp, $sp, -4
	sw $s7, 0($sp)
	jr $ra
touch_left:
	li $s7, 1
	addi $sp, $sp, -4
	sw $s7, 0($sp)
	jr $ra
#   --------------------------------------
touch_platform_right:
	# touch_platform_right(char, platform)
	# return 0 if char not on the platform. return 1 if char on the platform
	lw $t2, 0($sp)
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	addi $t3, $t1, -256
	addi $t4, $t1, 256
	addi $t5, $t2, -24
	
	beq $t5, $t1, touch_right
	beq $t5, $t3, touch_right
	beq $t5, $t4, touch_right
	
	addi $s7, $zero, 0
	addi $sp, $sp, -4
	sw $s7, 0($sp)
	jr $ra
touch_right:
	li $s7, 1
	addi $sp, $sp, -4
	sw $s7, 0($sp)
	jr $ra
#   --------------------------------------
valid_move_down:
	# push old, new
	addi, $sp, $sp, -4
	sw $a1, 0($sp)
	addi, $a1, $a1, 256
	addi, $sp, $sp, -4
	sw $a1, 0($sp)
	
	jal update_char	
	
	j check_loop
gravity_down:
	# push old, new
	addi, $sp, $sp, -4
	sw $a1, 0($sp)
	addi, $a1, $a1, 256
	addi, $sp, $sp, -4
	sw $a1, 0($sp)
	
	jal update_char
	j check_loop_1
valid_move_up:
	# push old, new
	addi, $sp, $sp, -4
	sw $a1, 0($sp)
	addi, $a1, $a1, -256
	addi, $sp, $sp, -4
	sw $a1, 0($sp)
	
	jal update_char
	j check_loop_1
valid_move_up_func:
	addi, $sp, $sp, -4
	sw $ra, 0($sp)
	addi, $sp, $sp, -4
	sw $a1, 0($sp)
	addi, $a1, $a1, -256
	addi, $sp, $sp, -4
	sw $a1, 0($sp)
	
	jal update_char
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
valid_move_left:
	# push old, new
	addi, $sp, $sp, -4
	sw $a1, 0($sp)
	addi, $a1, $a1, -4
	addi, $sp, $sp, -4
	sw $a1, 0($sp)
	
	jal update_char	
	
	j check_loop
valid_move_right:
	# push old, new
	addi, $sp, $sp, -4
	sw $a1, 0($sp)
	addi, $a1, $a1, 4
	addi, $sp, $sp, -4
	sw $a1, 0($sp)
	
	jal update_char	
	
	j check_loop
#   --------------------------------------
touch_bdr:
	j check_loop
touch_lava:
	jal reset_screen
	# print gameover
	li $v0, 4
	la $a0, str
	syscall
	j main
win:
	jal reset_screen
	# print win
	li $v0, 4
	la $a0, str1
	syscall
	j main
	# --------------------------------------------------------------------
update_char:
	# update(old char, new char), return null and edit a1, obstacles and redraw graph array.
	lw $t1, 0($sp)
	addi, $sp, $sp, 4  # new
	lw $t2, 0($sp)
	addi, $sp, $sp, 4  # old
	sub $t3, $t1, $t2
	
	li $t4, 0x000000 # black
	li $t5, 0x00ff00 # green
	beq  $t3, -4, updt_char_left
	beq  $t3, 4, updt_char_right
	beq  $t3, 256, updt_char_down
	beq  $t3, -256, updt_char_up
	jr $ra
updt_char_left:
	sw $t5, -8($t2)
	sw $t5, 248($t2)
	sw $t5, -264($t2)
	sw $t4, 4($t2)
	sw $t4, -252($t2)
	sw $t4, 260($t2)
	jr $ra
updt_char_right:
	sw $t5, 8($t2)
	sw $t5, -248($t2)
	sw $t5, 264($t2)
	sw $t4, -4($t2)
	sw $t4, 252($t2)
	sw $t4, -260($t2)
	jr $ra
updt_char_down:
	sw $t5, 512($t2)
	sw $t5, 508($t2)
	sw $t5, 516($t2)
	sw $t4, -256($t2)
	sw $t4, -252($t2)
	sw $t4, -260($t2)
	jr $ra
updt_char_up:
	sw $t5, -512($t2)
	sw $t5, -508($t2)
	sw $t5, -516($t2)
	sw $t4, 256($t2)
	sw $t4, 252($t2)
	sw $t4, 260($t2)
	jr $ra
	# --------------------------------------------------------------------
check_key:
	# check_key(), use the stack
	# return the key input in acci code
	# valid acci code or -1 (do not enter any key)
	li $t0, KEYCHECK_ADDRESS
	lw $t1, 0($t0)
	beq $t1, 1, keypress_happened
	j keypress_unhappened
keypress_happened:
	addi $sp, $sp, -4
	lw $t2, 4($t0)
	sw $t2, 0($sp)
	jr $ra
keypress_unhappened:
	addi $sp, $sp, -4
	li $t2, -1
	sw $t2, 0($sp)
	jr $ra
	# --------------------------------------------------------------------
	
initial_char:
	# initial_char(), do not use the stack
	li $t0, BASE_ADDRESS
	addi $a1, $t0, 12924
	li $t1, 0x00ff00
	sw $t1, 0($a1)
	sw $t1, 4($a1)
	sw $t1, -4($a1)
	sw $t1, 252($a1)
	sw $t1, 256($a1)
	sw $t1, 260($a1)
	sw $t1, -252($a1)
	sw $t1, -256($a1)
	sw $t1, -260($a1)
	jr $ra
	jr $ra
	# --------------------------------------------------------------------
initial_platform:
	# initial_char(), do not use the stack
	li $t0, BASE_ADDRESS
	li $t1, 0x0000ff
	li $t2, 0xFFFF00
	# initialize platform_1
	addi $a2, $t0, 13436
	sw $t1, 0($a2)
	sw $t1, 4($a2)
	sw $t1, -4($a2)
	sw $t1, 8($a2)
	sw $t1, -8($a2)
	sw $t1, 12($a2)
	sw $t1, -12($a2)
	sw $t1, 16($a2)
	sw $t1, -16($a2)

	# initialize platform_2
	addi $a3, $t0, 10812
	sw $t1, 0($a3)
	sw $t1, 4($a3)
	sw $t1, -4($a3)
	sw $t1, 8($a3)
	sw $t1, -8($a3)
	sw $t1, 12($a3)
	sw $t1, -12($a3)
	sw $t1, 16($a3)
	sw $t1, -16($a3)
	# initialize platform_3
	addi $s0, $t0, 8892
	sw $t1, 0($s0)
	sw $t1, 4($s0)
	sw $t1, -4($s0)
	sw $t1, 8($s0)
	sw $t1, -8($s0)
	sw $t1, 12($s0)
	sw $t1, -12($s0)
	sw $t1, 16($s0)
	sw $t1, -16($s0)
	jr $ra
	# --------------------------------------------------------------------
move_pf:
	# s3 = 0 left, s3 = 1 right
	lw $s3, 0($sp) 
	addi $sp, $sp, 4
	lw $t2, 0($sp)
	addi $sp, $sp, 4
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	beqz $s3, move_pf_left
	j move_pf_right
move_pf_left:
	addi $sp, $sp, -4
	sw $t2, 0($sp)
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	jal move_pf_left_func
	lw $s3, 0($sp)
	addi $sp, $sp, 4
	lw $t2, 0($sp)
	addi $sp, $sp, 4
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	addi $sp, $sp, -4
	sw $t2, 0($sp)
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	jr $ra
move_pf_right:
	addi $sp, $sp, -4
	sw $t2, 0($sp)
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	jal move_pf_right_func
	lw $s3, 0($sp)
	addi $sp, $sp, 4
	lw $t2, 0($sp)
	addi $sp, $sp, 4
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	addi $sp, $sp, -4
	sw $t2, 0($sp)
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	jr $ra
move_pf_left_func:
	# move_pf_left(address, direction_changed), return the moved address of the plarform	
	
	li $t0, BASE_ADDRESS 
	li $t1, 256
	lw $s3, 0($sp)
	addi $sp, $sp, 4
	lw $t2, 0($sp)
	addi $sp, $sp, 4
	
	li $t5, 0x0000ff
	li $t6, 0x000000
	
	addi, $sp, $sp, -4
	sw $ra, 0($sp)
	
	sub $t3, $t2, $t0
	div $t3, $t1
	mfhi $t4
	ble $t4, 16, hold_still_left
	# update the platform
	sw $t6, 16($t2)
	sw $t5, -20($t2)
	addi $t2, $t2, -4
	
	addi $sp, $sp, -4
	sw $t2, 0($sp)

	# check whether the char touch the platform
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	addi $sp, $sp, -4
	sw $t2, 0($sp)
	jal touch_platform_down
	# push old, new
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	beq $t1, 1, move_left_with_pf
	
	lw $t2, 0($sp)
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	addi $sp, $sp, -4
	sw $t2, 0($sp)
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	jr $ra
hold_still_left:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	addi $sp, $sp, -4
	sw $t2, 0($sp)
	li $s3, 1
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	jr $ra
move_left_with_pf:	
	addi, $sp, $sp, -4
	sw $a1, 0($sp)
	addi, $a1, $a1, -4
	addi, $sp, $sp, -4
	sw $a1, 0($sp)
	
	jal update_char

	lw $t2, 0($sp)
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	addi $sp, $sp, -4
	sw $t2, 0($sp)
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	jr $ra
	# --------------------------------------------------------------------
move_pf_right_func:
	# move_pf_left(address, direction_changed), return the moved address of the plarform	
	
	li $t0, BASE_ADDRESS 
	li $t1, 256
	lw $s3, 0($sp)
	addi $sp, $sp, 4
	lw $t2, 0($sp)
	addi $sp, $sp, 4
	
	li $t5, 0x0000ff
	li $t6, 0x000000
	
	addi, $sp, $sp, -4
	sw $ra, 0($sp)
	
	sub $t3, $t2, $t0
	div $t3, $t1
	mfhi $t4
	bge $t4, 240, hold_still_right
	# update the platform
	sw $t6, -16($t2)
	sw $t5, 20($t2)
	addi $t2, $t2, 4
	
	addi $sp, $sp, -4
	sw $t2, 0($sp)

	# check whether the char touch the platform
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	addi $sp, $sp, -4
	sw $t2, 0($sp)
	jal touch_platform_down
	# push old, new
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	beq $t1, 1, move_right_with_pf
	
	lw $t2, 0($sp)
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	addi $sp, $sp, -4
	sw $t2, 0($sp)
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	jr $ra
hold_still_right:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	addi $sp, $sp, -4
	sw $t2, 0($sp)
	li $s3, 0
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	jr $ra
move_right_with_pf:	
	addi, $sp, $sp, -4
	sw $a1, 0($sp)
	addi, $a1, $a1, 4
	addi, $sp, $sp, -4
	sw $a1, 0($sp)
	
	jal update_char

	lw $t2, 0($sp)
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	addi $sp, $sp, -4
	sw $t2, 0($sp)
	addi $sp, $sp, -4
	sw $s3, 0($sp)
	jr $ra
	# --------------------------------------------------------------------
make_backgroud:
	# make_backgroud(), do not use the stack
	li $t0, BASE_ADDRESS 
	addi $t0, $t0, 16380 # $t0 stores the left_right address in the form
	li $t1, 0xff0000 # $t1 stores the red colour code
	li $t3, 64
	li, $t4, 0
	j red_bottem
red_bottem:
	# paint the bottem unit red
	beq $t3, $t4, reset_64
	sw $t1, 0($t0)
	addi,$t0, $t0, -4
	addi, $t4, $t4, 1
	j red_bottem
reset_64:
	li $t3, 64
	li, $t4, 0
bottem_fire:
	# simulate the fire on the layer upper bottom level
	beq $t3, $t4, end_func
	sw $t1, 0($t0)
	addi,$t0, $t0, -8
	addi, $t4, $t4, 2
	j bottem_fire
end_func:
	jr $ra
	# -------------------------------------------------------------------
	# -------------------------------------------------------------------
reset_screen:
	li $t1, 4096
	li $t0, 0
	li $t3, BASE_ADDRESS
	li $t4, 0x000000
reset_loop:
	beq $t0, $t1, end_func
# end_func:
#	jr $ra
	sw $t4, 0($t3)
	addi $t3, $t3, 4
	addi $t0, $t0, 1
	j reset_loop
	# -------------------------------------------------------------------
random_star:
	li $v0, 42
	li $a0, 0
	li $a1, 4095
	syscall
	li $t2, BASE_ADDRESS
	li $t3, 4
	mul $t3, $a0, $t3
	add $t2, $t3, $t2
	addi $sp, $sp, -4
	sw $t2, 0($sp)
	jr $ra
get_star:
	add $t1, $zero, $a1
	jal random_star
	lw $t7, 0($sp)
	addi $sp, $sp, 4
	add $a1, $zero, $t1
	li $t5, 0x00ffff
	sw $t5, 0($t7)
	li $v0, 4
	la $a0, str2
	syscall
	addi $s2, $s2, 1
	li $v0, 1
	add $a0, $zero, $s2
	syscall
	li $v0, 4
	la $a0, str3
	syscall
	j check_loop
end:
	li $v0, 10 # terminate the program gracefully
	syscall

