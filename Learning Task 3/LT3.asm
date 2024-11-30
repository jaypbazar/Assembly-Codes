section .data
    greetings db "Hi we are Bazar, Belano, Garcia, and Valle. This program is intended to sort numbers and words or change all the vowels to a number.", 10, 0
    menu db "=== Assembly Program by Bazar, Belano, Garcia, and Valle ===", 10, "[0] Exit", 10, "[1] Number", 10, "[2] Word", 10, 0
    
    choice_prompt db  "Enter choice: ", 0
    input_prompt db "Enter up to 5 items: ", 10, 0
    sort_prompt db "Sort by [1] Ascending or [2] Descending: ", 0
    sorted_prompt db "Sorted items:", 10, 0
    change_vowel_prompt db "Do you want to change the vowels? (Y/N): ", 0
    replaced_prompt db "Changed vowels:", 10, 0

    input_num_error_msg db "Error: Invalid input. Please enter only numbers.", 10, 0
    input_word_error_msg db "Error: Invalid input. Please enter only words.", 10, 0
    choice_error_msg db "Error: Invalid choice. Please enter a valid choice.", 10, 0
    exit_msg db "Thank you!", 0

    num_format db "%d", 0
    print_num_format db "%d", 10, 0
    string_format db "%s", 0
    print_word_format db "%s", 10, 0

    STRING_SIZE equ 20 ; 20 bytes each word
    ARRAY_SIZE equ 5 ; number of items

section .bss
    nums_arr resd ARRAY_SIZE ; 5 items 4 bytes each
    words_arr resb STRING_SIZE * ARRAY_SIZE ; 5 items 20 bytes each
    choice resb 1
    temp resb STRING_SIZE ; temporary storage for swapping

section .text
    extern _scanf
    extern _printf
    extern _getchar
    extern _strcmp
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
            lea esi, [nums_arr] ; load address of array in esi
            
            ; display prompt
            push sorted_prompt
            call _printf
            add esp, 4

            mov ecx, ARRAY_SIZE ; size of array

            ; print each number in the array
            display_num_loop:
                push ecx ; preserve value of counter
            
                ; print number
                push dword[esi]
                push print_num_format
                call _printf
                add esp, 8

                add esi, 4 ; move to next element
                
                pop ecx ; retrieve value of counter

                loop display_num_loop ; loop until counter is 0, decrement ecx

            jmp main_loop_start ; go back to main menu

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
            
            ; pass 2 arguments and call input_choice function
            push 1           ; lower bound of choice range
            push sort_prompt ; prompt to display
            call input_choice

            ; check if user choose to sort asc or desc
            cmp byte[choice], 1
            je sort_word_asc
            cmp byte[choice], 2
            je sort_word_desc

            sort_word_asc:
                push 1 ; sorting direction, 1 = ascending
                push words_arr ; array to sort
                call sort_words

                jmp word_sort_done
            
            sort_word_desc:
                push 0 ; sorting direction, 0 = descending
                push words_arr ; array to sort
                call sort_words

            word_sort_done:

            ; display sorted words
            push sorted_prompt
            push words_arr
            call display_words

            ; ask user if they want to change the vowels
            changing_vowels:
            push change_vowel_prompt
            call _printf
            add esp, 4

            ; ask for choice
            push choice
            push string_format
            call _scanf
            add esp, 8

            ; if Y or y change vowels
            cmp byte[choice], 'y'
            je change_vowels
            cmp byte[choice], 'Y'
            je change_vowels

            ; if N or n don't change
            cmp byte[choice], 'n'
            je not_change
            cmp byte[choice], 'N'
            je not_change

            ; if choice is not any of the above then invalid
            push choice_error_msg
            call _printf
            add esp, 4

            jmp changing_vowels ; repeat choice input

            change_vowels:
                push words_arr
                call replace_vowels

                push replaced_prompt
                push words_arr
                call display_words
            
            not_change:

            jmp main_loop_start ; go back to main menu

display_words:
    ; create stack frame
    mov ebp, esp 
    
    mov esi, [ebp + 4] ; store address of array in esi
    mov ebx, [ebp + 8] ; prompt to print
                    
    ; display prompt
    push ebx
    call _printf
    add esp, 4

    mov ecx, ARRAY_SIZE ; store array size in ecx

    ; print each word in the array
    display_word_loop:
        push ecx ; preserve value of counter

        ; print word
        push esi
        push print_word_format
        call _printf
        add esp, 8

        add esi, STRING_SIZE ; move to next element
        
        pop ecx ; retrieve value of counter

        loop display_word_loop ; loop until counter is 0, decrement ecx

    ; destroy stack frame then return
    mov esp, ebp
    ret

clear_buffer:
    clear_input_buffer:
        ; read and discard characters until newline
        call _getchar
        cmp eax, 10
        jne clear_input_buffer

    ret

input_choice:
    ; create stack frame
    mov ebp, esp

    ; preserve value of registers
    push eax
    push ebx

    start_input:
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

        ; check if user entered a non-numeric value
        cmp eax, 1
        jne invalid_choice

        ; check if input is within range
        cmp dword [choice], ebx
        jl invalid_choice
        cmp dword [choice], 2
        jg invalid_choice

        ; restore the values
        pop ebx
        pop eax

        ; destroy stack frame and return to caller
        mov esp, ebp
        ret

    invalid_choice:
        ; clear buffer if input fails
        call clear_buffer

        ; display error message
        push choice_error_msg
        call _printf
        add esp, 4

        ; loop back to start of input
        jmp start_input

input_nums:
    ; create stack frame
    mov ebp, esp

    ; display input prompt
    push input_prompt
    call _printf
    add esp, 4

    mov esi, [ebp + 4] ; move address of array to esi

    mov ebx, 1 ; initialized ebx to true as default

    mov ecx, ARRAY_SIZE

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

        mov ebx, 0 ; set to false

        ; clear input buffer if input fails
        call clear_buffer

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
        cmp ecx, ARRAY_SIZE 
        jge outer_loop_done

        mov ebx, ecx
        inc ebx ; start from next item

        sort_inner_loop:
            cmp ebx, ARRAY_SIZE
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

    mov ebx, 1 ; initialize ebx to true (1) as default

    mov ecx, ARRAY_SIZE ; store array size to ecx

    word_input_loop:
        ; preserve values in stack
        push esi 
        push ecx 

        ; get input for current item in array
        push esi
        push string_format
        call _scanf
        add esp, 8

        pop ecx ; restore counter afer using printf

        validate_char_loop:
            cld ; clear direction
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
            mov ebx, 0 ; set to false (0) if not a word

        validate_done:
            pop esi ; restore esi afer using lodsb

        ; move to next string address
        add esi, STRING_SIZE

        loop word_input_loop ; loop until ecx is 0, ecx - 1

    ; destroy stack and return
    mov esp, ebp
    ret

sort_words:
    ; create stack frame
    mov ebp, esp

    mov esi, [ebp + 4] ; store to esi the address of 2st string
    mov edx, [ebp + 8] ; sorting order (1 = ascending, 0 = descending)

    mov ecx, 1 ; initialize counter to 1 for array_size-1 iterations

    word_outer_loop:
        ; store address of 2nd string in edi
        mov edi, esi
        add edi, STRING_SIZE

        ; initialize inner loop counter to outer loop counter
        mov ebx, ecx 

        word_inner_loop:
            cmp edx, 0
            je descending_words

            ; preserve indexes in stack
            push esi
            push edi
            ; compare the two strings
            mov ecx, STRING_SIZE
            repe cmpsb ; compare the strings in esi and edi registers
            ; restore indexes
            pop edi
            pop esi
            
            ja not_swap_words ; not swap if 1st > 2nd
            jmp swap_words
            
            descending_words:
                ; preserve indexes in stack
                push esi
                push edi
                ; compare the two strings
                mov ecx, STRING_SIZE
                repe cmpsb ; compare the strings in esi and edi registers
                ; restore indexes
                pop edi
                pop esi
                
                jb not_swap_words ; not swap if 1st < 2nd

            swap_words:
                ; swap the values in esi and edi
                push ecx
                push esi
                push edi
                
                mov ecx, STRING_SIZE
                mov esi, [esp+4]
                mov edi, temp
                rep movsb
                
                mov ecx, STRING_SIZE
                mov esi, [esp]
                mov edi, [esp+4]
                rep movsb
                
                mov ecx, STRING_SIZE
                mov esi, temp
                mov edi, [esp]
                rep movsb
                
                pop edi
                pop esi
                pop ecx

            not_swap_words:
                ; move to the next 2nd string
                add edi, STRING_SIZE 

                inc ebx ; increment inner loop counter

                ; loop while ebx is less than array size
                cmp ebx, ARRAY_SIZE
                jl word_inner_loop

        add esi, STRING_SIZE ; move to next 1st string

        inc ecx ; increment outer loop counter

    ; loop while ecx < array size
    cmp ecx, ARRAY_SIZE  
    jl word_outer_loop 

    ; destroy the stack and return
    mov esp, ebp
    ret

replace_vowels:
    ; create stack frame
    mov ebp, esp

    ; preserve values in stack
    push esi
    push edi
    push eax

    mov edi, [ebp + 4] ; array to replace vowels
    
    mov ecx, ARRAY_SIZE ; counter for number of elements in array

    string_loop_start:
        ; check if index is 5
        cmp ecx, 0
        je string_loop_end

        mov esi, edi ; store current string to esi

        ; check every vowel inside string and replace with number
        char_loop_start:
            cld ; clear direction
            lodsb ; load the current character to al, esi + 1

            ; check for end of string
            cmp al, 0
            je vowel_loop_end

            ; replace lowercase vovels
            cmp al, 'a'
            je replace_by_1
            cmp al, 'e'
            je replace_by_2
            cmp al, 'i'
            je replace_by_3
            cmp al, 'o'
            je replace_by_4
            cmp al, 'u'
            je replace_by_5

            ; replace uppercase vovels
            cmp al, 'A'
            je replace_by_1
            cmp al, 'E'
            je replace_by_2
            cmp al, 'I'
            je replace_by_3
            cmp al, 'O'
            je replace_by_4
            cmp al, 'U'
            je replace_by_5

            jmp replace_end ; no replacement needed

            replace_by_1:
                mov al, '1'
                jmp replace_end

            replace_by_2:
                mov al, '2'
                jmp replace_end

            replace_by_3:
                mov al, '3'
                jmp replace_end

            replace_by_4:
                mov al, '4'
                jmp replace_end

            replace_by_5:
                mov al, '5'

            replace_end:
                mov [esi - 1], al ; store the replaced value in the memory

            jmp char_loop_start
        
        vowel_loop_end:

        add edi, STRING_SIZE ; move to the next item 

        loop string_loop_start

    string_loop_end:
    ; restore values
    pop eax
    pop edi
    pop esi

    ; destroy the stack and return
    mov esp, ebp
    ret

