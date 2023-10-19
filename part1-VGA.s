.global _start
_start:
        bl      draw_test_screen
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
		MOV A4,V1
		MOV V4,#1
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
		MOV V4,#1
		MOV A4,V1
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
draw_test_screen:
        push    {r4, r5, r6, r7, r8, r9, r10, lr}
        bl      VGA_clear_pixelbuff_ASM
        bl      VGA_clear_charbuff_ASM
        mov     r6, #0
        ldr     r10, .draw_test_screen_L8
        ldr     r9, .draw_test_screen_L8+4
        ldr     r8, .draw_test_screen_L8+8
        b       .draw_test_screen_L2
.draw_test_screen_L7:
        add     r6, r6, #1
        cmp     r6, #320
        beq     .draw_test_screen_L4
.draw_test_screen_L2:
        smull   r3, r7, r10, r6
        asr     r3, r6, #31
        rsb     r7, r3, r7, asr #2
        lsl     r7, r7, #5
        lsl     r5, r6, #5
        mov     r4, #0
.draw_test_screen_L3:
        smull   r3, r2, r9, r5
        add     r3, r2, r5
        asr     r2, r5, #31
        rsb     r2, r2, r3, asr #9
        orr     r2, r7, r2, lsl #11
        lsl     r3, r4, #5
        smull   r0, r1, r8, r3
        add     r1, r1, r3
        asr     r3, r3, #31
        rsb     r3, r3, r1, asr #7
        orr     r2, r2, r3
        mov     r1, r4
        mov     r0, r6
        bl      VGA_draw_point_ASM
        add     r4, r4, #1
        add     r5, r5, #32
        cmp     r4, #240
        bne     .draw_test_screen_L3
        b       .draw_test_screen_L7
.draw_test_screen_L4:
        mov     r2, #72
        mov     r1, #5
        mov     r0, #20
        bl      VGA_write_char_ASM
        mov     r2, #101
        mov     r1, #5
        mov     r0, #21
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #22
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #23
        bl      VGA_write_char_ASM
        mov     r2, #111
        mov     r1, #5
        mov     r0, #24
        bl      VGA_write_char_ASM
        mov     r2, #32
        mov     r1, #5
        mov     r0, #25
        bl      VGA_write_char_ASM
        mov     r2, #87
        mov     r1, #5
        mov     r0, #26
        bl      VGA_write_char_ASM
        mov     r2, #111
        mov     r1, #5
        mov     r0, #27
        bl      VGA_write_char_ASM
        mov     r2, #114
        mov     r1, #5
        mov     r0, #28
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #29
        bl      VGA_write_char_ASM
        mov     r2, #100
        mov     r1, #5
        mov     r0, #30
        bl      VGA_write_char_ASM
        mov     r2, #33
        mov     r1, #5
        mov     r0, #31
        bl      VGA_write_char_ASM
        pop     {r4, r5, r6, r7, r8, r9, r10, pc}
.draw_test_screen_L8:
        .word   1717986919
        .word   -368140053
        .word   -2004318071
