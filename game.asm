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
.eqv BASE_ADDRESS 0x10008000
.eqv KEYCHECK_ADDRESS 0xffff0000 
.text
main:
	# let ********* $a1 ********** store the adress of charactor.(center)
	jal make_backgroud # make_backgroud()
	jal initial_char
	
	li, $t7, BASE_ADDRESS
	j check_loop
	# --------------------------------------------------------------------
check_loop:
	li $v0, 32
	li $a0, 40 # Wait one second (1000 milliseconds)
	syscall
	
	jal check_key
	lw $t2, 0($sp)
	addi $sp, $sp, 4
	beq $t2, -1, continue
	beq $t2, 0x61, move_left       # a
	beq $t2, 0x64, move_right   # d
	beq $t2, 0x77, move_up      # w
	beq $t2, 0x73, move_down   # s
	jal update
	j continue
continue:
	j check_loop
move_left:
	addi, $a1, $a1, -4
	j check_loop
move_right:
	addi, $a1, $a1, 4
	j check_loop
move_up:
	addi, $a1, $a1, -256
	j check_loop
move_down:
	addi, $a1, $a1, 256
	j check_loop
	# --------------------------------------------------------------------
update:
	# update(BASE_ADDRESS, pst_char, pst_obstacles...), return null and edit a1, obstacles and redraw graph array.
	
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
	# --------------------------------------------------------------------
	
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
	

end:
	li $v0, 10 # terminate the program gracefully
	syscall

