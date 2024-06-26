[bits 64]

file_load_va: equ 4096 * 40

elf_header:
        db 0x7f, 'E', 'L', 'F'  ; Magic Bytes
        db 2                    ; 64-bit
        db 1                    ; Little Endian
        db 1                    ; ELF version
        db 0                    ; OS ABI
;; [BEGIN] Overwrites: Extended ABI + Padding
entry_point:
        lea eax, [ebx+0x3b]     ; syscall execve
        jmp call_curl
        dw 0
;; [-END-]
        dw 2                    ; Executable
        dw 0x3e                 ; Machine x86_64
        dd 1                    ; Version
        dq entry_point + file_load_va ; Entry point
        dq program_headers_start      ; Program Headers Offset
;; [BEGIN] Overwrites: Section Header Offset + Flags
call_curl:
        mov edi, file_load_va + curl ; curl path
        lea rsi, [rsp+8]             ; argv
        syscall
;; [-END-]
        dw 64                         ; ELF Header Size
        dw 0x38                       ; Program Header Entry Size
        dw 1                          ; Number of Program Header Entries.

program_headers_start:
        dd 1                    ; Program Header Type: Loadable Segment
        dd 5                    ; Flags (+r -w +x)
        dq 0                    ; Segment Offset
        dq file_load_va         ; Segment Virtual Address
        dq file_load_va         ; Segment Physical Address
        dq file_end             ; Segment File Size
        dq file_end             ; Segment Memory Size

curl: db '/bin/curl', 0

file_end:
