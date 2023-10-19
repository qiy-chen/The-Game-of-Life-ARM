.global _start
_start:
        bl      input_loop
end:
        b       end

.equ PIXELBUFF, 0xc8000000
VGA_draw_point_ASM:
	//verify boundaries, return if invalid
	PUSH {V1,V2}
	MOV V1,#0
	LDR V2,=319
	CMP A1,V1
	BLT Invalid
	CMP A2,V1
	BLT Invalid
	CMP A1,V2
	BGT Invalid
	MOV V2,#239
	CMP A2,V2
	BGT Invalid
	//Make shifts
	MOV A1,A1,LSL #1
	MOV A2,A2,LSL #10
	LDR V1,=PIXELBUFF
	ADD V1,A1
	ADD V1,A2
	STRH A3,[V1]
Invalid:
	POP {V1,V2}
	BX LR
VGA_clear_pixelbuff_ASM:
	PUSH {V1-V4,LR}
	MOV V1,#0
	MOV V2,#0 //i
LOOPX:
	MOV V3,#0 //j
	LOOPY:
		MOV A1,V2
		MOV A2,V3
		MOV V4,#1
		MOV A4,V1
		BL VGA_draw_point_ASM
		ADD V3,V4
		LDR V4, =240
		CMP V4,V3
		BNE LOOPY
	MOV V4,#1
	ADD V2,V4
	LDR V4, =320
	CMP V4,V2
	BNE LOOPX
	POP {V1-V4,LR}
	BX LR
.equ CHARBUFF, 0xc9000000
VGA_write_char_ASM:
	//verify boundaries, return if invalid
	PUSH {V1,V2}
	MOV V1,#0
	LDR V2,=79
	CMP A1,V1
	BLT Invalid2
	CMP A2,V1
	BLT Invalid2
	CMP A1,V2
	BGT Invalid2
	MOV V2,#59
	CMP A2,V2
	BGT Invalid2
	//Make shifts
	MOV A2,A2,LSL #7
	LDR V1,=CHARBUFF
	ADD V1,A1
	ADD V1,A2
	STRB A3,[V1]
Invalid2:
	POP {V1,V2}
	BX LR
VGA_clear_charbuff_ASM:
	PUSH {V1-V4,LR}
	MOV V1,#0
	MOV V2,#0 //i
LOOPX2:
	MOV V3,#0 //j
	LOOPY2:
		MOV A1,V2
		MOV A2,V3
		MOV A4,V1
		MOV V4,#1
		BL VGA_write_char_ASM
		ADD V3,V4
		LDR V4, =60
		CMP V4,V3
		BNE LOOPY2
	MOV V4,#1
	ADD V2,V4
	LDR V4, =80
	CMP V4,V2
	BNE LOOPX2
	POP {V1-V4,LR}
	BX LR
.equ KB_INPUT, 0xff200100
read_PS2_data_ASM:
	PUSH {V1-V4}
	MOV V1,#1
	LDR V2,=KB_INPUT
	LDR V3,[V2]
	MOV V4,V3,LSR #15
	//Store data if true and return 1
	TST V4,V1
	BNE DATAFRESH
	//otherwise return 0
	MOV A1,#0
	POP {V1-V4}
	BX LR
DATAFRESH:
	STRB V3,[A1]
	MOV A1,#1
	POP {V1-V4}
	BX LR

write_hex_digit:
        push    {r4, lr}
        cmp     r2, #9
        addhi   r2, r2, #55
        addls   r2, r2, #48
        and     r2, r2, #255
        bl      VGA_write_char_ASM
        pop     {r4, pc}
write_byte:
        push    {r4, r5, r6, lr}
        mov     r5, r0
        mov     r6, r1
        mov     r4, r2
        lsr     r2, r2, #4
        bl      write_hex_digit
        and     r2, r4, #15
        mov     r1, r6
        add     r0, r5, #1
        bl      write_hex_digit
        pop     {r4, r5, r6, pc}
input_loop:
        push    {r4, r5, lr}
        sub     sp, sp, #12
        bl      VGA_clear_pixelbuff_ASM
        bl      VGA_clear_charbuff_ASM
        mov     r4, #0
        mov     r5, r4
        b       .input_loop_L9
.input_loop_L13:
        ldrb    r2, [sp, #7]
        mov     r1, r4
        mov     r0, r5
        bl      write_byte
        add     r5, r5, #3
        cmp     r5, #79
        addgt   r4, r4, #1
        movgt   r5, #0
.input_loop_L8:
        cmp     r4, #59
        bgt     .input_loop_L12
.input_loop_L9:
        add     r0, sp, #7
        bl      read_PS2_data_ASM
        cmp     r0, #0
        beq     .input_loop_L8
        b       .input_loop_L13
.input_loop_L12:
        add     sp, sp, #12
        pop     {r4, r5, pc}
