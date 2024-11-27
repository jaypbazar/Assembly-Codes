section .data
    greetings db "Hi we are Bazar, Belano, Garcia, and Valle. This program is intended to sort numbers and words or change all the vowels to a number.", 10, 0
    menu db "=== Assembly Program by Bazar, Belano, Garcia, and Valle ===", 10, "[0] Exit", 10, "[1] Number", 10, "[2] Word", 10, 0
    
    choice_prompt db  "Enter choice: ", 0
    input_prompt db "Enter up to 5 items: ", 10, 0
    sort_prompt db "Sort by [1] Ascending or [2] Descending: ", 0
    sorted_prompt db "Sorted items: ", 10, 0
    change_num_prompt db "Do you want to change the vowels? (Y/N): ", 0

    input_num_error_msg db "Error: Invalid input. Please enter only numbers.", 10, 0
    input_word_error_msg db "Error: Invalid input. Please enter only words.", 10, 0
    choice_error_msg db "Error: Invalid choice. Please enter a valid choice.", 10, 0
    exit_msg db "Thank you!", 0

    num_format db "%d", 0
    print_num_format db "%d", 10, 0
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
            ; get inputs and store to nums_arr
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
            ; pass 2 arguments and call input_choice function
            push 1           ; lower bound of choice range
            push sort_prompt ; prompt to display
            call input_choice

            ; check if user choose to sort asc or desc
            cmp byte[choice], 1
            je sort_asc
            cmp byte[choice], 2
            je sort_desc

            sort_asc:
                push 1 ; sorting direction, 1 = ascending
                push nums_arr ; array to sort
                call sort_nums

                jmp sort_done
            
            sort_desc:
                push 0 ; sorting direction, 0 = descending
                push nums_arr ; array to sort
                call sort_nums

            sort_done:
            ; display sorted numbers
            push sorted_prompt
            call _printf
            add esp, 4

            lea esi, [nums_arr]
            mov ecx, 5
            num_print_loop:
                mov ebx, [esi]

                push ecx

                push ebx
                push print_num_format
                call _printf
                add esp, 8

                add esi, 4

                pop ecx

                loop num_print_loop

            jmp main_loop_start

        case_2:
            ; get inputs and store to words_arr
            push words_arr
            call input_words

            ; repeat input if any of the input is not a word
            cmp ebx, 0
            jnz word_input_valid

            ; display error message
            push input_word_error_msg
            call _printf
            add esp, 4

            jmp case_2 ; repeat input

            word_input_valid:

            jmp main_loop_start

input_choice:
    ; create stack frame
    mov ebp, esp

    ; preserve value of registers
    push eax
    push ebx

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

    ; restore the values
    pop ebx
    pop eax

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
    num_input_loop_start:
        ; preserve values in stack
        push ecx 

        ; get input for each item in list
        push esi
        push num_format
        call _scanf
        add esp, 8

        cmp eax, 1 ; check if input is accepted
        je next_input

        mov dword[esi], 0 ; declare value as 0 if not a number
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
        loop num_input_loop_start

    ; destroy stack frame and return
    mov esp, ebp
    ret 

sort_nums:
    ; create stack frame
    mov ebp, esp

    mov esi, [ebp + 4] ; address of array to sort
    mov edx, [ebp + 8] ; sort direction (1 = ascending, 0 = descending)

    mov ecx, 0 ; starting index

    sort_outer_loop:
        ; done sorting if index is 5
        cmp ecx, 5 
        jge outer_loop_done

        mov ebx, ecx
        inc ebx ; start from next item

        sort_inner_loop:
            cmp ebx, 5
            jge inner_loop_done

            mov eax, [esi + ecx*4] ; address of min/max
            mov edi, [esi + ebx*4] ; address of next item

            cmp edx, 0 ; check if ascending/descending
            je descending

            ; compare if current min is less than the current item
            cmp eax, edi
            jl not_swap
            jmp swap_numbers

            ; compare if current max is greater than the current item
            descending:
            cmp eax, edi
            jg not_swap
            jmp swap_numbers

            swap_numbers:
                mov [esi + ecx*4], edi
                mov [esi + ebx*4], eax

            not_swap:
                inc ebx

            jmp sort_inner_loop

        inner_loop_done:
            
        ; mov to the next item
        inc ecx

        jmp sort_outer_loop

    outer_loop_done:
    
    ; destroy stack and return
    mov esp, ebp
    ret

input_words:
    ; create stack frame
    mov ebp, esp

    ; display input prompt
    push input_prompt
    call _printf
    add esp, 4

    mov esi, [ebp + 4] ; address of array 

    mov ebx, 1 ; initialized ebx to true as default

    mov ecx, 5 ; array size

    word_input_loop_start:
        ; preserve values in stack
        push ecx 

        ; get input for each item in list
        push esi
        push string_format
        call _scanf
        add esp, 8

        push esi ; preserve value in esi

        ; check each character on the string for non-alphabet
        validate_char_loop:
        
            lodsb ; load 1 character from esi to al register, esi + 1

            ; check for end of string
            cmp al, 0
            je validate_done

            ; check if character is uppercase A-Z
            cmp al, 'A'
            jl not_word
            cmp al, 'Z'
            jle valid_char

            ; check if character is lowercase a-z
            cmp al, 'a'
            jl not_word
            cmp al, 'z'
            jg not_word

            valid_char:
                jmp validate_char_loop

        not_word:
            mov ebx, 0

        validate_done:
            pop esi ; retrieve value in esi

        add esi, 10 ; move to the next item

        pop ecx ; retrieve value of ecx

        loop word_input_loop_start

    ; destroy stack and return
    mov esp, ebp
    ret
