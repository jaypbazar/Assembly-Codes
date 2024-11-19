section .data
    menu db "==== LCM and GCF CALCULATOR by Jayp Bazar ====", 10, "[0] Exit", 10, "[1] LCM", 10, "[2] GCF", 10, 0

    prompt1 db "Enter choice: ", 0
    prompt2 db "Enter the 3 two-digit numbers (separated by space): ", 0

    title1 db "==== LCM ====", 10, 0
    title2 db "==== GCF ====", 10, 0

    choice_error_msg db "Entered Choice is not on the menu. Please enter a valid choice.", 10, 0
    input_error_msg db "Inputs should only be between 1 to 99. Please enter your valid inputs.", 10, 0
    ty_msg db "Thank you!", 10, 0

    choice_format db "%d", 0
    input_format db "%d %d %d", 0

    LCM db "LCM: %d", 10, 0
    GCF db "GCF: %d", 10, 0

section .bss
    choice resw 1
    
    num1 resd 1
    num2 resd 1
    num3 resd 1

    gcf resd 1

section .text
    extern _printf
    extern _scanf
    global _main

calculate_lcm:
    ; set up base pointer
    mov ebp, esp

    ; find the gcf of first two numbers
    push gcf
    push dword [ebp + 4]
    push dword [ebp + 8]
    call calculate_gcf
    
    ; multiply 1st number by 2nd number
    mov eax, [ebp + 8]
    mov ebx, [ebp + 4]
    mul ebx 

    ; divide by the gcf
    mov edx, 0 ; clear edx register
    div dword [gcf]
    
    ret 8

calculate_gcf:
    ; set up base pointer
    mov ebp, esp

    ; move the address of gcf variable to ecx register
    mov ecx, [ebp+12]

    ; move the value num1 and num2 from stack to registers
    mov eax, [ebp+8]
    mov ebx, [ebp+4]

    gcf_loop_start:
        mov edx, 0 ; clear edx register before division

        ; divide 1st num by 2nd num, remainder in edx
        div ebx
        
        ; assign remainder as 2nd num and ebx as 1st num
        mov eax, ebx
        mov ebx, edx

        ; store the result in the address of gcf variable
        mov [ecx], eax

        ; check if remainder is 0 then terminate
        cmp ebx, 0
        jz gcf_loop_end

        jmp gcf_loop_start ; jump back to start of loop

    gcf_loop_end:
        ; restore stack pointer to original value
        mov esp, ebp 

        ret 12

get_nums:
    input_loop_start:
        ; display prompt for num input
        push prompt2
        call _printf
        add esp, 4
        
        ; get one line input separated by space
        push num3
        push num2
        push num1
        push input_format
        call _scanf
        add esp, 16

        ; move the input values to registers
        mov eax, [num1]
        mov ebx, [num2]
        mov ecx, [num3]

        ; check validity of each input
        cmp eax, 1
        jl invalid_input
        cmp eax, 99
        jg invalid_input

        cmp ebx, 1
        jl invalid_input
        cmp ebx, 99
        jg invalid_input

        cmp ecx, 1
        jl invalid_input
        cmp ecx, 99
        jg invalid_input

        ; return to caller if input is valid
        ret

        invalid_input:
            ; display error message
            push input_error_msg
            call _printf
            add esp, 4

            ; go back to start of loop
            jmp input_loop_start

_main:
    main_loop_start:
        ; display the menu
        push menu
        call _printf
        add esp, 4

        ; display prompt for choice
        push prompt1
        call _printf
        add esp, 4

        ; get input for choice
        push choice
        push choice_format
        call _scanf
        add esp, 8

        ; compare input to choices then skip error message if input is in the choices
        mov ax, [choice]
        cmp ax, 0
        je case_0
        cmp ax, 1
        je case_1
        cmp ax, 2
        je case_2

        ; display error message
        push choice_error_msg
        call _printf
        add esp, 4

        ; loop back to start of loop
        jmp main_loop_start

        case_0:
            ; display thank you message
            push ty_msg
            call _printf
            add esp, 4

            ret

        ; Pass by value
        case_1:
            ; ==== LCM ====
            push title1
            call _printf
            add esp, 4

            ; get num inputs
            call get_nums

            ; get the lcm of first 2 numbers
            push dword [num1]
            push dword [num2]
            call calculate_lcm

            ; include the 3rd number
            push eax
            push dword [num3]
            call calculate_lcm

            ; display the lcm
            push eax
            push LCM
            call _printf
            add esp, 8

            jmp main_loop_start

        ; Pass by reference
        case_2: 
            ; ==== GCF ====
            push title2
            call _printf
            add esp, 4

            ; get num inputs 
            call get_nums
            
            ; get the gcf of first 2 numbers
            push gcf
            push dword [num1]
            push dword [num2]
            call calculate_gcf

            ; include the 3rd number
            push gcf
            push eax
            push dword [num3]
            call calculate_gcf

            ; display the gcf
            push dword [gcf]
            push GCF
            call _printf
            add esp, 8

            jmp main_loop_start
    
    ret