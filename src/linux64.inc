; ***********************************************************************************************************************************
; File: linux64.inc
; Author: xWatexx (aka alobley)
; Created: 01/23/2025
; Last Modified: 01/23/2025
; Version: 0.1 (still in development)
;
; Description: Linux x86_64 system call numbers and macros, Linux library for x86-64 assembly programming.
; This file is meant specifically to make programming in assembly on Linux easier.
;
; Dependencies: NASM assembler for your programs, Linux x86_64 operating system.
; ***********************************************************************************************************************************

; Read: file descriptior, buffer, count. Return: number of bytes read
; Write: file descriptior, buffer, count.
%define SYSCALL_WRITE 1
%define SYSCALL_READ 0
; Exit: status
%define SYSCALL_EXIT 60
; Execve: path, argv, envp
%define SYSCALL_EXECVE 59

;Fork: void. Return: child pid. If the fork result is 0, it is the child process. Otherwise, it is the parent process. Returned value can be passed to waitid.
%define SYSCALL_FORK 57

; Waitpid: pid, status, options. Return: pid of the child process that exited, 0 if no child exited, -1 if error.
%define SYSCALL_WAITID 247

%define SYSCALL_GETCWD 79

%define SYSCALL_CHDIR 80

%define SYS_ACCESS 21

%define STDOUT 1
%define STDIN 0

%define NULL 0

%define P_ALL 0

%define WEXITED 4

; System V ABI parameters: rdi, rsi, rdx, rcx, r8, r9
; Kernel ABI parameters: rdi, rsi, rdx, r10, r8, r9

%macro exit 1
    mov rax, SYSCALL_EXIT
    mov rdi, %1
    syscall
%endmacro

%macro write 3
    mov rax, SYSCALL_WRITE
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    syscall
%endmacro

%macro read 3
    mov rax, SYSCALL_READ
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    syscall
%endmacro

%macro fork 0
    mov rax, SYSCALL_FORK
    syscall
%endmacro

%macro waitid 4
    mov rax, SYSCALL_WAITID
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    mov r10, %4
    mov r8, 0
    syscall
%endmacro

%macro execve 3
    mov rax, SYSCALL_EXECVE
    mov rdi, %1
    mov rsi, %2
    mov rdx, %3
    syscall
%endmacro

%macro getcwd 2
    mov rax, SYSCALL_GETCWD
    mov rdi, %1
    mov rsi, %2
    syscall
%endmacro

%macro chdir 1
    mov rax, SYSCALL_CHDIR
    mov rsi, %1
    syscall
%endmacro

%macro access 2
    mov rax, SYS_ACCESS
    mov rdi, %1
    mov rsi, %2
    syscall
%endmacro