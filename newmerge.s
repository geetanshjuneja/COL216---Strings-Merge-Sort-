.global prompt
.global input_list
.global output_list
.global merge

.text

@ Prompt function is used print to stdout 
@ r0 contains the address where string to be printed is stored    
@ gets a number from stdin which is stored in r0
prompt:
    str lr, [sp,#-4]! 
    bl output_string
    bl output_new_line
    bl input_number
    ldr lr, [sp], #4
    mov pc,lr
    
@ r0 contains address of buffer
@ r1 contains address of location where address of first elements of strings are place
@ r2 contains number of strings to be taken for input
@ r7 is used to print string number 
@ returns the next position till which buffer has been filled in r0.
input_list : 
    str r0,[r1],#4
    stmfd sp!, {r0-r3,lr}
    ldr r0,=out
    bl output_string
    mov r0,r7
    bl output_number
    add r7,r7,#1
    bl output_new_line
    ldmfd sp!, {r0-r3,lr}
    stmfd sp!, {r1-r2,lr}
    bl input_string
    ldmfd sp!, {r1-r2,lr}
    sub r2,r2,#1
    cmp r2,#0
    bne input_list
    mov pc,lr

@ r2 contains array of pointers pointing to strings
@ r1 contains size of merged list
output_list :
    str lr, [sp,#-4]!
    stmfd sp!,{r1-r2,lr}
    ldr r0,=out1
    bl output_string
    bl output_new_line
    ldmfd sp!,{r1-r2,lr}
    mov r5,r1
    mov r6,r1
    mov r7,r2
show1:    
    ldr r0,[r7],#4
    cmp r5,#0
    beq show2
    bl output_string
    bl output_new_line
    sub r5,r5,#1
    b show1
show2: 
    ldr r0,=out2
    bl output_string
    bl output_new_line
    mov r0,r6
    bl output_number
    ldr lr, [sp], #4
    mov pc,lr

@ r0 contains duplicate removal option
@ r1 contains comparison mode
@ r2 contains array of pointers pointing to elements in list1.
@ r3 contains array of pointers pointing to elements in list2.
@ r4 contains contains address of location which will contain merged pointers.
@ r5 contains size of list 1
@ r6 contains size of list 2
@ returns sorted merged list of pointers in r4.
@ returns the mergred list size in r11.
merge :
    stmfd sp!, {r0-r6,lr}
    mov r7,r5
    mov r8,r6
    mov r5,r0
    mov r6,r2
    mov r2,r1
loop_back:    
    ldr r0,[r6],#4      @Changes made here
    ldr r1,[r3],#4
    bl stage1
    cmp r9,#1
    blt loop1       @ If  strings are equal move to loop1
    beq loop2       @ If string1 > string2 move to loop2    
    bgt loop3       @ If string1 < string2 move to loop3
    
check_cond:
    bl search
    cmp r7,#0          @ If all the strings in list1 are pushed then only loop3 will be called 
    beq push_L2         
    cmp r8,#0          @ If all the strings in list2 are pushed then only loop2 will be called 
    beq push_L1        
    bl stage1
    cmp r9,#1
    blt loop1       @ If  strings are equal move to loop1
    beq loop2       @ If string1 > string2 move to loop2    
    bgt loop3       @ If string1 < string2 move to loop3

loop1 :
    cmp r5,#1   
    bne allow  
    str r0,[r4],#4 
    add r11,r11,#1              @ If duplication is not allowed
    sub r7,r7,#1
    sub r8,r8,#1
    ldr r1,[r3],#4           @changes made here
    ldr r0,[r6],#4
    cmp r7,#0
    beq push_L2
    cmp r8,#0
    beq push_L1 
    b check_cond
allow :                           @ If duplication is allowed
    str r0,[r4],#4   
    str r1,[r4],#4
    add r11,r11,#2
    sub r7,r7,#1
    sub r8,r8,#1 
    ldr r1,[r3],#4  @changes made here
    ldr r0,[r6],#4
    b check_cond

loop2 :
    str r1,[r4],#4
    add r11,r11,#1
    sub r8,r8,#1
    ldr r1,[r3],#4
    b check_cond

loop3 :
    str r0,[r4],#4
    add r11,r11,#1
    sub r7,r7,#1
    ldr r0,[r6],#4
    b check_cond

push_L2 : 
    cmp r8,#0
    beq back
    str r1,[r4],#4
    add r11,r11,#1
    sub r8,r8,#1
    ldr r1,[r3],#4 
    b push_L2

push_L1 :
    cmp r7,#0
    beq back
    str r0,[r4],#4
    add r11,r11,#1
    sub r7,r7,#1
    ldr r0,[r6],#4
    b push_L1
   

@ Search is used for duplication removal    
@ r0 has the address of string in List 1 to be compared with last element inserted in r4
@ r1 has the address of string in List 2 to be compared with last element inserted in r4
@ r5 has duplication removal option
@ r2 has comparison mode
@ return updated r0,r1,r7,r8
search :
    cmp r5,#0
    bgt pt    
    mov pc,lr
pt :
    stmfd sp!,{r4-r5,lr}
    mov r5,r1          @ r3 has the address of string in List 2 to be compared with last element inserted in r4
    ldr r1,[r4,#-4]    @ r1 has the address of last inserted string
    bl stage1
    cmp r9,#0
    ldreq r0,[r6],#4
    subeq r7,r7,#1
    mov r4,r0          
    mov r0,r5
    bl stage1
    ldreq r0,[r3],#4
    subeq r8,r8,#1
    mov r1,r0
    mov r0,r4
    ldmfd sp!,{r4-r5,lr}
    mov pc,lr

back:    
    ldmfd sp!, {r0-r6,lr}
    mov pc,lr


.data
out : .asciz "Enter String "
out1 : .asciz "Sorted List is"
out2 : .asciz "Size of Sorted List is"
