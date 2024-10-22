section .data
    menu db "==== LCM and GCF CALCULATOR by Jayp Bazar ====", 10, "[0] Exit", 10, "[1] LCM", 10, "[2] GCF", 10, 0

    prompt1 db "Enter choice: ", 0
    prompt2 db "Enter the 3 two-digit numbers (separated by space): ", 0

    title1 db "==== LCM ====", 10, 0
    title2 db "==== GCF ====", 10, 0

    input_format db "%d"

    LCM db "LCM: %d", 10, 0
    GCF db "GCF: %d", 10, 0

section .bss

section .text
    extern _printf
    extern _scanf
    global _main

_main:
