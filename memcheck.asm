[BITS 16]
[ORG 0x7c00]
_start:	
	cli
	mov ax, cs
	mov ds, ax
	mov ss, ax
	mov sp, _start

	lgdt [gd_reg]

	in al, 0x92
	or al, 2
	out 0x92, al

	mov eax, cr0 
	or al, 1	
	mov cr0, eax  

	jmp 0x8: _protected


[BITS 32]
_protected:	
	mov ax, 0x10
	mov ds, ax
	mov ss, ax

  call testmem

  jz short .goodmem
	mov esi, msg_bad
	call kputs	

	hlt
	jmp short $

.goodmem:
	mov esi, msg_good
	call kputs	

	hlt
	jmp short $


cursor:	dd 0
%define VIDEO_RAM 0xB8000
%define TEST_RAM 0x1000000

testmem:
  pusha

  mov bx, 0xffff
  mov cx, 0x47
.testwrite:
  mov [TEST_RAM+bx], cx
  dec bx
  jnz short .testwrite
  
  mov bx, 0xffff
.testread:
  mov dx, [TEST_RAM+bx]
  test dx, cx
  jnz short .badmem
  dec bx
  jnz short .testread

  test bx, cx
  
  popa
  ret
.badmem:
  test al, al

  popa
  ret
	
kputs:
	pusha
.loop:	
	lodsb 
	test al, al
	jz .quit

	mov ecx, [cursor]
	mov [VIDEO_RAM+ecx], al
	inc dword [cursor]
	jmp short .loop

.quit:	
	popa
	ret
		

gdt:
	dw 0, 0, 0, 0	

	db 0xFF		
	db 0xFF	
	db 0x00
	db 0x00
	db 0x00
	db 10011010b
	db 0xCF
	db 0x00
	
	db 0xFF	
	db 0xFF
	db 0x00	
	db 0x00
	db 0x00
	db 10010010b
	db 0xCF
	db 0x00


gd_reg:
	dw 8192
	dd gdt

msg_good:	db "g",0x1,"o",0x1,"o",0x1,"d",0x1," ",0x1,"m",0x1,"e",0x1,"m",0x1,"o",0x1,"r",0x1,"y",0x1,0
msg_bad:	db "b",0x4,"a",0x4,"d",0x4," ",0x4,"m",0x4,"e",0x4,"m",0x4,"o",0x4,"r",0x4,"y",0x4,0

	times 510-($-$$) db 0
	db 0xaa, 0x55


