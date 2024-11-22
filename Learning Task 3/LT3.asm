section .data
    greetings db "Hi we are Bazar, Belano, Garcia, and Valle. This program is intended to sort numbers and words or change all the vowels to a number.", 10, 0
    menu db "=== Assembly Program by Bazar, Belano, Garcia, and Valle ===", 10, "[0] Exit", 10, "[1] Number", 10, "[2] Word", 10, 0
    choice_prompt db  "Enter choice: ", 0
    input_prompt db "Enter up to 5 items: ", 10, 0
    sort_prompt db "Sort by [1] Ascending or [2] Descending: ", 0
    change_num_prompt db "Do you want to change the vowels? (Y/N): ", 0

    input_num_error_msg db "Error: Invalid input. Please enter only numbers.", 10, 0
    input_word_error_msg db "Error: Invalid input. Please enter only words.", 10, 0
    choice_error_msg db "Error: Invalid choice. Please enter a valid choice.", 10, 0
    exit_msg db "Thank you!", 0

    num_format db "%d", 0
    string_format db "%s", 0

    ; counter db 0
    type_error_flag db 0

section .bss
    arr resd 5
    choice resb 1

section .text
    extern _scanf
    extern _printf
    global _main

input_choice:
    ; create stack frame
    mov ebp, esp

    mov eax, [ebp + 4] ; prompt
    mov ebx, [ebp + 8] ; lower bound of range

    ; display prompt
    push eax
    call _printf
    add esp, 4

    ; get input for choice
    push choice
    push num_format
    call _scanf
    add esp, 8

    ; check if input is within range
    cmp dword[choice], ebx 
    jl invalid_choice
    cmp dword[choice], 2
    jg invalid_choice

    ; destroy stack frame and return to caller
    mov esp, ebp
    ret 

    ; display error message
    invalid_choice:
    push choice_error_msg
    call _printf
    add esp, 4

    ; return to start of function
    jmp input_choice

input_array:
    ; create stack frame
    mov ebp, esp

    ; display input prompt
    push input_prompt
    call _printf
    add esp, 4

    ; move address of array to source index
    lea esi, [arr]
    mov ecx, 5

    ; asks for number input
    input_loop_start:
        push ecx 

        ; get input for each item in list
        push esi
        push string_format
        call _scanf
        add esp, 8

        pop ecx

        ; mov to the next item
        add esi, 4
        dec ecx
        
        ; reapeat the input process
        jnz input_loop_start

        ; destroy stack frame and return
        mov esp, ebp
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

        ; pass 2 arguments and call input_choice function
        push 0             ; lower bound of choice range
        push choice_prompt ; prompt to display
        call input_choice

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
            call input_array

            ; pass 2 arguments and call input_choice function
            push 1           ; lower bound of choice range
            push sort_prompt ; prompt to display
            call input_choice

            cmp byte[choice], 1
            je sort_asc
            cmp byte[choice], 2
            je sort_desc

            sort_asc:
                ; call sort_ascending

                jmp main_loop_start
            
            sort_desc:
                ; call sort_descending

                jmp main_loop_start

        case_2:
            push input_prompt
            call _printf
            add esp, 4

            jmp main_loop_start