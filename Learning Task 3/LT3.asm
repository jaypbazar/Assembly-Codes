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

section .bss
    nums_arr resd 5 ; 5 items 4 bytes each
    words_arr resb 50 ; 5 items 10 bytes each
    choice resb 1

section .text
    extern _scanf
    extern _printf
    extern _getchar
    global _main

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
            ; display thank you message
            push exit_msg
            call _printf
            add esp, 4

            ret ; terminate program
            
        case_1:
            push nums_arr
            call input_nums

            ; repeat input if any of the input is not a number
            cmp ebx, 0
            jnz num_input_valid

            ; display error message
            push input_num_error_msg
            call _printf
            add esp, 4

            jmp case_1 ; repeat input

            num_input_valid:

            ; ; pass 2 arguments and call input_choice function
            ; push 1           ; lower bound of choice range
            ; push sort_prompt ; prompt to display
            ; call input_choice

            ; cmp byte[choice], 1
            ; je sort_asc
            ; cmp byte[choice], 2
            ; je sort_desc

            ; sort_asc:
            ;     ; call sort_ascending

            ;     jmp main_loop_start
            
            ; sort_desc:
            ;     ; call sort_descending

                jmp main_loop_start

        case_2:
            push input_prompt
            call _printf
            add esp, 4

            jmp main_loop_start

input_choice:
    ; create stack frame
    push ebp
    mov ebp, esp

    ; preserve value of registers
    push eax
    push ebx

    mov eax, [ebp + 8] ; prompt
    mov ebx, [ebp + 12] ; lower bound of range

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

    ; restore the values
    pop ebx
    pop eax

    ; destroy stack frame and return to caller
    mov esp, ebp
    pop ebp
    ret 

    ; display error message
    invalid_choice:
    push choice_error_msg
    call _printf
    add esp, 4

    ; return to start of function
    jmp input_choice

input_nums:
    ; create stack frame
    mov ebp, esp

    ; display input prompt
    push input_prompt
    call _printf
    add esp, 4

    mov esi, [ebp + 4] ; move address of array to esi

    mov ebx, 1 ; initialized ebx to true as default

    mov ecx, 5 ; array size

    ; asks for number input
    input_loop_start:
        ; preserve values in stack
        push ecx 

        ; get input for each item in list
        push esi
        push num_format
        call _scanf
        add esp, 8

        cmp eax, 1 ; check if input is accepted
        je next_input

        mov dword[esi], 0 ; ; declare value as 0 if not a number
        mov ebx, 0 ; set to false

        ; If input fails, clear input buffer
        clear_input_buffer:
            ; Read and discard characters until newline
            call _getchar
            cmp eax, 10  ; newline character
            jne clear_input_buffer

        next_input:
        ; restore value from stack
        pop ecx 

        ; mov to the next item
        add esi, 4
        
        ; reapeat input until ecx is 0
        loop input_loop_start

    ; destroy stack frame and return
    mov esp, ebp
    ret 

