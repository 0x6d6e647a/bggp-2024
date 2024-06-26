[bits 32]

file_load_va: equ 4096 * 40

elf_header:
        db 0x7f, 'E', 'L', 'F'  ; Magic Bytes
        db 1                    ; 32-bit
        db 1                    ; Little Endian
        db 1                    ; ELF version
        db 0                    ; OS ABI
;; [BEGIN] Overwrites: Extended ABI + Padding
entry_point:
        jmp 0x33:file_load_va + call_curl_init
        db 0
;; [-END-]
        dw 2                          ; Executable
        dw 0x03                       ; Machine x86
        dd 1                          ; Version
        dd entry_point + file_load_va ; Entry Point
        dd program_headers_start      ; Program Headers Offset
;; [BEGIN] Overwrites: Section Headers Offset + Flags
call_curl_init:
        mov eax, dword [esp+8]
        jmp call_curl
        dw 0
;; [-END-]
        dw 52                   ; ELF Header Size
        dw 32                   ; Program Header Entry Size
        dw 1                    ; Number of Program Header Entries

program_headers_start:
        dd 1                    ; Program Header Type: Loadable Segment
        dd 0                    ; Segment Offset
        dd file_load_va         ; Segment Virtual Address
        dd file_load_va         ; Segment Physical Address
        dd file_end             ; Segment File Size
        dd file_end             ; Segment Memory Size
        dd 5                    ; Flags (+r -w +x)

curl: db '/bin/curl', 0

call_curl:
[bits 64]
        ; -- Convert 32-bit argv pointers to 64-bit.
        mov qword [esp+12], rax
        mov dword [esp+8], ebx
        mov qword [esp+20], rbx

        ; -- Call execve(curl, argv, 0)
        lea eax, [ebx+0x3b]          ; syscall execve
        mov edi, file_load_va + curl ; curl path
        lea esi, [rsp+4]             ; argv
        syscall

file_end:
