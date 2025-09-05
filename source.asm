;--- brainfuck compiler for Linux x86_64 by Denis Bazhenov ---;
format ELF64 executable
entry _start
                                                               
                                                                                   
segment readable executable                                                        
macro syscall_1 num, arg1 {                                                        
mov rdi, arg1                                                                      
mov rax, num                                                                       
syscall                                                                           
}

macro syscall_3 num, arg1, arg2, arg3 {
mov rdi, arg1
mov rsi, arg2
mov rdx, arg3
mov rax, num
syscall
}
_start:
mov rbx, [rsp + 16]
syscall_3 2, rbx, 0, 0
mov rbx, rax
syscall_3 0, rbx, code, 20000
syscall_1 3, rbx
mov rbx, [rsp + 24]
syscall_3 2, rbx, 1, 0x1ed
mov rbx, rax

mov qword [jump_table + 43 * 8], plus
mov qword [jump_table + 45 * 8], minus
mov qword [jump_table + 44 * 8], char_in
mov qword [jump_table + 46 * 8], char_out
mov qword [jump_table + 62 * 8], next
mov qword [jump_table + 60 * 8], back
mov qword [jump_table + 91 * 8], loop_start
mov qword [jump_table + 93 * 8], loop_end


mainloop:
xor rax, rax
mov al, byte [code + r15]
test al, al
jz exit
jmp qword [jump_table + rax * 8]
skip:
inc r15
jmp mainloop


plus:
mov rsi, plus_opcode
mov rdi, gen_code
add rdi, r15
mov rcx, PO_size
rep movsb
add r15, PO_size
jmp skip

minus:
mov rsi, plus_opcode
mov rdi, gen_code
add rdi, r15
mov rcx, MO_size
rep movsb
add r15, MO_size
jmp skip

next:
mov rsi, plus_opcode
mov rdi, gen_code
add rdi, r15
mov rcx, NO_size
rep movsb
add r15, NO_size
jmp skip

back:
mov rsi, back_opcode
mov rdi, gen_code
add rdi, r15
mov rcx, BO_size
rep movsb
add r15, BO_size
jmp skip

char_in:
mov rsi, input_opcode
mov rdi, gen_code
add rdi, r15
mov rcx, IO_size
rep movsb
add r15, IO_size
jmp skip

char_out:
mov rsi, output_opcode
mov rdi, gen_code
add rdi, r15
mov rcx, OO_size
rep movsb
add r15, OO_size
jmp skip

loop_start:
mov rsi, startloop_opcode
mov rdi, gen_code
add rdi, r15
mov rcx, SO_size
rep movsb
add r15, SO_size
jmp skip

loop_end:
mov rsi, endloop_opcode
mov rdi, gen_code
add rdi, r15
mov rcx, EO_size
rep movsb
add r15, EO_size
jmp skip


exit:
syscall_3 1, rbx, headers, 84
mov r13, gen_code
mov rsi, exit_opcode
mov rdi, r13
add rdi, r15
mov rcx, 9
rep movsb
add r15, 10
syscall_3 1, rbx, r13, r15
syscall_1 60, 0


segment readable writable
jump_table dq 256 dup(skip)
code db 20000 dup(0)

plus_opcode:
inc byte [0x08048800+ebx]
PO_size = $ - plus_opcode

minus_opcode:
dec byte [0x08048800+ebx]
MO_size = $ - minus_opcode

next_opcode:
inc ebx
NO_size = $ - next_opcode

back_opcode:
dec ebx
BO_size = $ - back_opcode

input_opcode:
mov eax, 3
mov ebx, 0
mov ecx, 0x08048800
add ecx, ebx
mov edx, 1
int 0x80
IO_size = $ - input_opcode

output_opcode:
mov eax, 4
mov ebx, 1
mov ecx, 0x08048800
add ecx, ebx
mov edx, 1
int 0x80
OO_size = $ - output_opcode

startloop_opcode:
nop
SO_size = $ - startloop_opcode

endloop_opcode:
nop
EO_size = $ - endloop_opcode

exit_opcode:
mov eax, 1
xor ebx, ebx
int 0x80

headers:
db 0x7f, 0x45, 0x4c, 0x46
db 0x01
db 0x01
db 0x01
db 0x00
db 0x00
db 7 dup(0)
dw 0x0002
dw 0x0003
dd 0x00000001
dd 0x08048000
dd 0x00000034
dd 0x00000000
dd 0x00000000
dw 0x0034
dw 0x0020
dw 0x0001
dw 0x0000
dw 0x0000
dw 0x0000

dd 0x00000001
dd 0x00000034
dd 0x08048000
dd 0x08048000
dd 0x00000864
dd 0x00000864
dd 0x00000007
dd 0x00001000

gen_code db 2048 dup(0x90)
arr db 100 dup(0)
