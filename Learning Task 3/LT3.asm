section .data
    greetings db "Hi we are Bazar, Belano, Garcia, and Valle. This program is intended to sort numbers and words or change all the vowels to a number.", 10, 0
    menu db "=== Assembly Program by Bazar, Belano, Garcia, and Valle ===", 10, "[0] Exit", 10, "[1] Number", 10, "[2] Word", 10, 0
    choice_prompt db  "Enter choice: ", 0
    input_prompt db "Enter up to 5 items: ", 10, 0
    sort_prompt db "Sort by [1] Ascending or [2] Descending: ", 0
    change_num_prompt db "Do you want to change the vowels? (Y/N): ", 0

    input_error_msg db "Error: Invalid input. Please enter only numbers.", 10, 0
    choice_error_msg db "Error: Invalid choice. Please enter a valid choice.", 10, 0
    exit_msg db "Thank you!", 0

    num_format db "%d", 0
    string_format db "%s", 0

section .bss
    input resd 5
    choice resb 1

section .text
    extern _scanf
    extern _printf
    global _main

menu_choice:
    ; display choice prompt
    push choice_prompt
    call _printf
    add esp, 4

    ; get input for choice
    push choice
    push num_format
    call _scanf
    add esp, 8

    ; check if input is within range
    cmp byte[choice], 0
    jl invalid_choice
    cmp byte[choice], 2
    jg invalid_choice

    ; return to caller
    ret

    ; display error message
    invalid_choice:
    push choice_error_msg
    call _printf
    add esp, 4

    ; return to start of function
    jmp menu_choice

input_nums:
    ; display input prompt
    push input_prompt
    call _printf
    add esp, 4

    input1_loop_start:
        ; check if counter is 5 then exit loop
        cmp ecx, 5
        je exit_input

        ; get input for each item in list
        push eax
        push num_format
        call _scanf
        add esp, 8

        ; ; transfer input to input array
        ; mov dword[input + ecx], eax

        push eax
        push num_format
        call _printf
        add esp, 4

        ; increament ecx then repeat loop
        inc ecx
        jmp input1_loop_start

        ; exit loop
        exit_input:
        ret 

_main:
    ; display the greeting message
    push greetings
    call _printf
    add esp, 4

    main_loop_start:
        ; display the menu choices
        push menu
        call _printf
        add esp, 4

        call menu_choice

        cmp byte[choice], 0
        je case_0
        cmp byte[choice], 1
        je case_1
        cmp byte[choice], 2
        je case_2

        case_0:
            push exit_msg
            call _printf
            add esp, 4

            ret

        case_1:
            call input_nums

            jmp main_loop_start
        
        case_2:
            push input_prompt
            call _printf
            add esp, 4

            push input
            push string_format
            call _scanf
            add esp, 8

            jmp main_loop_start