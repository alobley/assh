BITS 64
%include "src/linux64.inc"        ; They're in the same directory??

%define CMD_SIZE 255

section .rodata
pref: db "> ", 0
preflen: equ $ - pref
cmd_exit: db "exit", 0
cd: db "cd", 0
clear: db "clear", 0
ansi_clear: db 0x1B, '[', 'H', 0x1B, '[', '2', 'J', 0
aclen: equ $ - ansi_clear
path: db "PATH=", 0
pathlen: equ $ - path
slash: db "/", 0

section .data

section .text
global _start

_start:
    mov QWORD [environ], r8                 ; Set the environ variable (The kernel conveniently gave this to us)

    getcwd cwd_buffer, CMD_SIZE             ; Get current working directory

    mov byte [cwd_end], NULL                ; Null-terminate cwd_buffer
    write STDOUT, cwd_buffer, 256           ; Write cwd_buffer to STDOUT

    write STDOUT, pref, preflen             ; Write prompt to STDOUT

    read STDIN, command, CMD_SIZE           ; Read command from STDIN
    mov byte [command + rax - 1], NULL      ; Null-terminate command

    mov rdi, command
    mov rsi, cmd_exit
    call strcmp                             ; Compare command to "exit"
    cmp rax, 0                              ; If they are equal, go to .exit
    je .exit

    mov rdi, command
    mov rsi, clear
    call strcmp                             ; Compare command to "clear"
    cmp rax, 0                              ; If they are equal, go to .clear
    je .clear

    mov rdi, command
    mov rsi, cd
    call strcmp                             ; Compare command to "cd"
    cmp rax, 0                              ; If they are equal, go to .cd
    je .cd

.nocd:
    fork                                    ; Fork a child process
    cmp rax, NULL                           ; Check if we are in the child process
    je .child                               ; If so, go to .child, execute a command, and exit.

    waitid P_ALL, NULL, siginfo, WEXITED    ; Wait for the child process to exit
    jmp _start                              ; Go back to the beginning of the loop
    
    jmp .exit                               ; Exit the program (on error only)

.child:
    mov rdi, command                        ; Move the command to rdi
    mov rsi, argv                           ; Move the argv array to rsi
    call GetArgv                            ; Get the arguments from the command
    
    execve command, argv, [environ]

.exit:
    exit 0                                  ; Exit the program

.cd:
    mov rdi, command + 3                    ; Move to the path in the command
    chdir rdi                               ; Change the current working directory

    mov rsi, cwd_buffer
    mov al, 0
    mov rcx, CMD_SIZE
    call memset                             ; Clear the command buffer

    jmp .nocd                               ; Go back to the beginning of the loop

.clear:
    write STDOUT, ansi_clear, aclen         ; Clear the terminal
    jmp .nocd                               ; Go back to the beginning of the loop

; RSI: pointer to the first string
; RDI: pointer to the second string
; bool strcmp(const char *s1, const char *s2);
; Returns 0 if s1 == s2, 1 otherwise.
strcmp:
    push rsi
    push rdi
    xor rax, rax
.loop:
    mov al, [rdi]
    cmp al, [rsi]
    jne .exit
    inc rdi
    inc rsi
    test al, al
    jnz .loop
    xor rax, rax
    jmp .end
.exit:
    mov rax, 1
.end:
    pop rdi
    pop rsi
    ret

; RSI: pointer to the first string
; RDI: pointer to the second string
; RCX: number of bytes to compare
strncmp:
    push rsi
    push rdi
    push rcx
    xor rax, rax
    mov rcx, rdx
.loop:
    mov al, [rdi]
    cmp al, [rsi]
    jne .fail
    inc rdi
    inc rsi
    dec rcx
    jnz .loop
    xor rax, rax
    jmp .end
.fail:
    mov rax, 1
.end:
    pop rcx
    pop rdi
    pop rsi
    ret

; RSI: pointer to the buffer
; AL: byte to write
; RCX: number of bytes to write
memset:
    push rsi
    push rax
    push rcx
.loop:
    mov [rsi], al
    inc rsi
    loop .loop
    pop rcx
    pop rax
    pop rsi
    ret

; Get the first index of a character in a string
; RDI: pointer to the string
; BL: character to find
; Returns the index of the character in RAX
indexof:
    push rdi
    push rbx
    xor rax, rax
.loop:
    mov bh, [rdi]
    cmp bh, bl
    je .end
    inc rax
    inc rdi
    test bh, bh
    jnz .loop
    mov rax, -1
.end:
    pop rbx
    pop rdi
    ret

; RDI: input string
; RSI: argv array
GetArgv:
    push rdi
    push rsi
    mov rdx, rsi        ; Save original argv pointer
.loop:
    mov al, [rdi]
    test al, al
    jz .finish         ; Jump to finish when we hit null
.skip_spaces:
    cmp al, ' '
    jne .notspace
    mov byte [rdi], 0  ; Null-terminate the previous argument
    inc rdi
    mov al, [rdi]
    jmp .skip_spaces
.notspace:
    mov [rsi], rdi     ; Store pointer to argument
    add rsi, 8         ; Move to next argv slot
.find_end:
    mov al, [rdi]
    test al, al        ; Check for null terminator
    jz .finish
    cmp al, ' '        ; Check for space
    je .skip_spaces
    inc rdi
    jmp .find_end
.finish:
    mov QWORD [argv_end], 0 ; NULL-terminate argv array
    pop rsi
    pop rdi
    ret

; Find the length of a string
; RSI: pointer to the string
; Returns the length of the string in RAX
strlen:
    push rsi
    xor rax, rax
.loop:
    mov al, [rsi]
    test al, al
    jz .end
    inc rsi
    inc rax
    jmp .loop
.end:
    pop rsi
    ret

; RDI: pointer to the first string
; RSI: pointer to the second string
; RAX: pointer to the concatenated string
StrConcat:
    push rax
    push rdi
    push rsi

.copyfirst:
    mov al, [rsi]
    test al, al
    jz .copysecond
    mov [rax], al
    inc rsi
    inc rax
    jmp .copyfirst
.copysecond:
    mov al, [rdi]
    test al, al
    jz .end
    mov [rax], al
    inc rdi
    inc rax
    jmp .copysecond

.end:
    pop rsi
    pop rdi
    pop rax
    ret


section .bss
; On read, rax = number of bytes read. Set command + rax to NULL.
command: resb CMD_SIZE

siginfo: resb 128

; Allocate 10 bytes for the argument count
argv: resq 10
argv_end: resq 1

cwd_buffer: resb CMD_SIZE
cwd_end: resb 1

environ: resq 1

full_path: resb 256
path_buff: resb 1024

concatenatedStr: resb 1024