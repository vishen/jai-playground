section .text
bits 32
global start
start:
    ; print `OK` to screen
    ; mov dword [0xbb000], 0x2f4b2f4f
    mov dword [0xb8140], 0x2f4b2f4f
    ; mov dword [0xa0000], 0x2f4b2f4f
	; mov ax, 0x0F41
    ; mov [0xb8000], ax
	; Print `Hello, world!` on the screen by placing ASCII 
    ; characters in the VGA screen buffer that starts at 0xb8000
    ; mov word [0xb8000], 0x0248 ; H

    ; mov word [0xb8002], 0x0265 ; e

    ; mov word [0xb8004], 0x026c ; l
    ; mov word [0xb8006], 0x026c ; l

    ; mov word [0xb8008], 0x026f ; o

    ; mov word [0xb800a], 0x0220 ;
    ; mov word [0xb800c], 0x0277 ; w
    ; mov word [0xb800e], 0x026f ; o
    ; mov word [0xb8010], 0x0272 ; r
    ; mov word [0xb8012], 0x026c ; l
    ; mov word [0xb8014], 0x0264 ; d
    ; mov word [0xb8016], 0x0221 ; !
    ; mov word [0xb8156], 0x0221 ; !
    hlt
