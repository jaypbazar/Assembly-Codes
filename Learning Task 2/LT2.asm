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
    choice resb 2
    num1 resb 4
    num2 resb 4
    num3 resb 4

section .text
    extern _printf
    extern _scanf
    global _main

lcm:

gcf:

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
    mov eax, [choice]
    cmp eax, 0
    je case1
    cmp eax, 1
    je case2
    cmp eax, 2
    je case3

    ; display error message
    push choice_error_msg
    call _printf
    add esp, 4

    ; loop back to start of loop
    jmp main_loop_start

    case1:
        ; display thank you message
        push ty_msg
        call _printf
        add esp, 4

        ret

    case2:
        ; ==== LCM ====
        push title1
        call _printf
        add esp, 4

        ; get num inputs
        call get_nums

        ; get the lcm
        push num3
        push num2
        push num1
        call lcm

        jmp main_loop_start

    case3:
        ; ==== GCF ====
        push title2
        call _printf
        add esp, 4

        ; get num inputs 
        call get_nums

        ; get the gcf
        push num3
        push num2
        push num1
        call gcf

        jmp main_loop_start

