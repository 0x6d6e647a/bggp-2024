[bits 32]

file_load_va: equ 4096 * 40

elf_header:
        db 0x7f, 'E', 'L', 'F'          ; Magic Bytes
        db 1                            ; 32-bit
        db 1                            ; Little Endian
        db 1                            ; ELF Version
        db 0                            ; OS ABI
;; [BEGIN] Overwrites: Extended ABI + Padding
entry_point:
        lea ecx, [esp+4]
        jmp call_curl_init
        dw 0
;; [-END-]
        dw 2                            ; Executable
        dw 0x03                         ; Machine x86
        dd 1                            ; Version
        dd entry_point + file_load_va   ; Entry Point
        dd program_headers_start        ; Program Headers Offset
;; [BEGIN] Overwrites: Section Headers Offset + Flags
call_curl_init:
        mov ebx, file_load_va + curl ; curl path
        jmp call_curl
        db 0
;; [-END-]
        dw 52                           ; ELF Header Size
        dw 32                           ; Program Header Entry Size
        dw 1                            ; Number of Program Header Entries

program_headers_start:
        dd 1                        ; Program Header Type: Loadable Segment
        dd 0                        ; Segment Offset
        dd file_load_va             ; Segment Virtual Address
        dd file_load_va             ; Segment Physical Address
        dd file_end                 ; Segment File Size (Ends at string_table)
        dd file_end                 ; Segment Memory Size (Ends at string_table)
        dd 5                        ; Flags (+r -w +x)

curl: db '/bin/curl', 0

call_curl:
        lea eax, [edx+0xb]           ; syscall execve
        int 0x80

file_end:
