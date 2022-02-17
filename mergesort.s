.text
main:
    ldr r0,=num
    bl prompt            @ Input for size of List 1
    mov r2,r0
    ldr r3,=List0_size
    str r0,[r3]
    ldr r0,=List_data
    ldr r1,=Main_List_pointers
    mov r7,#1
    bl input_list
    ldr r0,=dup
    bl prompt
    mov r5,r0
    ldr r0,=comp_mode
    bl prompt
    mov r3,r0
    ldr r0,=Main_List_pointers    @ Array of Pointers to the list
    ldr r4,=List0_size            
    ldr r1,[r4]                    @ Size of the list
    mov r2,r5
    bl mergesort
    ldr r2,=Main_List_pointers
    mov r1,r7
    bl output_list
    mov r0,#0x18
    swi 0x123456


@ r0 contains array of pointers to the list.
@ r1 contains size of the list.
@ r2 contains duplicate removal option
@ r3 contains comparison mode
@ return the sorted list in List_pointers_3
@ returns the size of sorted list in r7
mergesort : 
    stmfd sp!, {r0-r6,r8,r9,r10,lr}
    cmp r1,#1
    bne not_base_case

base_case :
    @ldr r2,=List_pointers_3
    @ldr r3,[r0]
    @str r3,[r2]
    mov r7,#1
    b move_out

not_base_case :
    mov r5,r2          @ Duplicate Removal Option
    mov r2,r1,LSR #1   @ Size of Left half of the array
    sub r9,r1,r2       @ Size of Right half of the array
    mov r1,r2
    mov r2,r5
    bl mergesort
    mov r8,r7
    mov r10,r0
    mov r4,#4
    mla r0,r1,r4,r0
    mov r1,r9
    mov r2,r5
    bl mergesort
    ldr r1,=List_pointers_2    @ parameters for copy func
    mov r2,r7
    bl copy
    mov r2,r8              @ Parameters for copy func
    mov r0,r10
    ldr r1,=List_pointers_1
    bl copy
    mov r0,r5              @ Parameters for merge func       @ r0 contains dup
    mov r1,r3              @ r3 contains comparison mode
    mov r5,r8              @ r5 contains size of first list
    mov r6,r7              @ r6 contains size of second list
    ldr r2,=List_pointers_1
    ldr r3,=List_pointers_2
    mov r4,r10
    mov r11,#0
    bl merge
    mov r7,r11

move_out :
    ldmfd sp!, {r0-r6,r8,r9,r10,lr}
    mov pc,lr


@ This function is used to copy array of pointers from List_pointers_3
@ r0 contains the address of location fron where array is to be copied
@ r1 contains the address of the location to where array is to be copied
@ r2 contains the size of the array to be copied
copy :
    stmfd sp!, {r0-r3,lr}
    @ldr r0,=List_pointers_3
go_to :
    ldr r3,[r0],#4
    str r3,[r1],#4
    sub r2,r2,#1
    cmp r2,#0
    bne go_to    
    ldmfd sp!, {r0-r3,lr}
    mov pc,lr


.data
num : .asciz "Enter the size of list "
dup : .asciz "Enter the  duplicate removal option (0 for no and 1 for yes)"
comp_mode: .asciz "Enter comparison mode (0 for sensitive and 1 for insensitive)"

.align 2
List_data : .space 200
List_pointers_1 : .space 100
List_pointers_2 : .space 100
Main_List_pointers : .space 200
List0_size : .word 0
List3_size : .word 0