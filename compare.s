.global stage1
.text
@ r0 contains the address of string 1.
@ r1 contains the address of string 2.
@ r2 contains 0 for sensitive or 1 for insensitive.
@ returns 0,1 or 2 if string1 is equal, greater or less than string2 in r9.
stage1:    stmfd sp!, {r0-r8,lr}
           cmp r2,#0            @ 0 for sensitive and 1 for insensitive
           beq sensitive
           bne insensitive

sensitive: ldrb r3,[r0],#1
           ldrb r4,[r1],#1
           cmp r3,r4
           beq ret0
           blt ret1
           bgt ret2

insensitive: ldrb r3,[r0],#1
             ldrb r4,[r1],#1            
             bl uptodown
             cmp r3,r4
             beq ret3
             blt ret1
             bgt ret2           

ret0:      mov r5,#0
           cmp r3,r5
           beq equal
           b sensitive

equal:     mov r9,#0
           ldmfd sp!, {r0-r8,lr}
           mov pc,lr                      
        
ret1:      mov r9,#2               
           ldmfd sp!, {r0-r8,lr}
           mov pc,lr

ret2:      mov r9,#1
           ldmfd sp!, {r0-r8,lr}
           mov pc,lr 

ret3:      mov r5,#0
           cmp r3,r5
           beq equal
           b insensitive                    

uptodown:  cmp r3,#'A
           blt ex
           cmp r3,#'Z
           bgt ex
           add r3,r3,#32
ex:        cmp r4,#'A
           blt exit
           cmp r4,#'Z
           bgt exit
           add r4,r4,#32
exit:      
           mov pc,lr    

.data           
