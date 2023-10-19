.global _start


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
VGA_clearwhite_pixelbuff_ASM:
	PUSH {V1-V4,LR}
	LDR V1,=0xFFFFFF
	MOV V2,#0 //i
LOOPX:
	MOV V3,#0 //j
	LOOPY:
		MOV A1,V2
		MOV A2,V3
		MOV A3,V1
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
		MOV A3,V1
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

VGA_draw_line_ASM:
	PUSH {V1-V6,LR}
	MOV V1,A1 //x1
	MOV V2,A2 //y1
	MOV V3,A3 //x2
	MOV V4,A4 //y2
	LDR V6,[SP,#28]//colour
	//V1 and V2 hold the largest value
	CMP V1,V3
	MOVLT V5,V1
	MOVLT V1,V3
	MOVLT V3,V5
	CMP V2,V4
	MOVLT V5,V2
	MOVLT V2,V4
	MOVLT V4,V5
	
	CMP V1,V3
	BEQ LINEY
	//Draw in x (y1=y2)
LINEX:
	MOV A1,V1
	MOV A2,V2
	MOV A3,V6
	BL VGA_draw_point_ASM
	MOV V5,#1
	SUB V1,V5
	CMP V1,V3
	BGE LINEX
	
	POP {V1-V6,LR}
	BX LR
	//Draw in y (x1=x2)
LINEY:
	MOV A1,V1
	MOV A2,V2
	MOV A3,V6
	BL VGA_draw_point_ASM
	MOV V5,#1
	SUB V2,V5
	CMP V2,V4
	BGE LINEY
	
	POP {V1-V6,LR}
	BX LR

//Square: 20 pixels wide, black outline in square
GoL_draw_grid_ASM:
	PUSH {V1-V6,LR}
	MOV V6,A1
	//Top left corner of the square
	
	MOV V2,#0
GRIDLOOPY:
	MOV V1,#0
	GRIDLOOPX:
		//Draw the outline
		DRAWOUTLINE:
			//Top line
			MOV V3,#19
			ADD V3,V1,V3
			MOV A1,V1
			MOV A2,V2
			MOV A3,V3
			MOV A4,V2
			MOV V5,V6
			PUSH {V5}
			BL VGA_draw_line_ASM
			POP {V5}
			//Left line
			MOV V3,#19
			ADD V3,V2,V3
			MOV A1,V1
			MOV A2,V2
			MOV A3,V1
			MOV A4,V3
			MOV V5,V6
			PUSH {V5}
			BL VGA_draw_line_ASM
			POP {V5}
			//Right line
			MOV V3,#19
			ADD V3,V1,V3
			MOV V4,#19
			ADD V4,V2,V4
			MOV A1,V3
			MOV A2,V2
			MOV A3,V3
			MOV A4,V4
			MOV V5,V6
			PUSH {V5}
			BL VGA_draw_line_ASM
			POP {V5}
			//Bottom line
			MOV V3,#19
			ADD V3,V1,V3
			MOV V4,#19
			ADD V4,V2,V4
			MOV A1,V1
			MOV A2,V4
			MOV A3,V3
			MOV A4,V4
			MOV V5,V6
			PUSH {V5}
			BL VGA_draw_line_ASM
			POP {V5}
		MOV V3,#20
		ADD V1,V3
		LDR V3, =320
		CMP V1,V3
		BNE GRIDLOOPX
		
	MOV V3,#20
	ADD V2,V3
	LDR V3, =240
	CMP V2,V3
	BNE GRIDLOOPY
	
	POP {V1-V6,LR}
	BX LR

VGA_draw_rect_ASM:
	PUSH {V1-V7,LR}
	MOV V1,A1 //x1
	MOV V2,A2 //y1
	MOV V3,A3 //x2
	MOV V4,A4 //y2
	LDR V6,[SP,#32]//colour
	
RECTANGLEY:
	MOV V5,V1 //x
	RECTANGLEX:
		MOV A1,V5
		MOV A2,V2
		MOV A3,V6
		BL VGA_draw_point_ASM
		MOV V7,#1
		ADD V5,V7
		CMP V5,V3
		BLE RECTANGLEX
	MOV V7,#1
	ADD V2,V7
	CMP V2,V4
	BLE RECTANGLEY
	POP {V1-V7,LR}
	BX LR

GoL_fill_gridxy_ASM:
	PUSH {V1-V6,LR}
	MOV V1,A1
	MOV V2,A2
	MOV V3,A3
	//Scale from grid position to pixel position
	MOV V4,#20
	MUL V1,V4
	MUL V2,V4
	MOV V4,#1
	ADD V1,V4
	ADD V2,V4
	//Determine x2,y2
	MOV V4,#17
	ADD V5,V1,V4
	ADD V6,V2,V4
	MOV A1,V1
	MOV A2,V2
	MOV A3,V5
	MOV A4,V6
	PUSH {V3}
	BL VGA_draw_rect_ASM
	POP {V3}
	POP {V1-V6,LR}
	BX LR

GoL_draw_board_ASM:
	PUSH {V1-V6,LR}
	
	LDR V4,=GoLBoard
	MOV V2,#0 //y
DRAWBOARDY:
	MOV V1,#0 //x
	DRAWBOARDX:
		//Offset with V5
		MOV V5,V1
		MOV V6,#16
		MUL V6,V2,V6
		ADD V5,V6
		MOV V6,#4
		MUL V5,V6
		LDR V3,[V4,V5]
		MOV V5,#1
		TST V3,V5
		//If 1, draw black square, otherwise, white square
		MOV A1, V1
		MOV A2,V2
		MOVNE A3,#0
		LDREQ A3,=0xFFFFFF
		BL GoL_fill_gridxy_ASM
		MOV V3,#1
		ADD V1,V3
		CMP V1,#16
		BNE DRAWBOARDX
	MOV V3,#1
	ADD V2,V3
	CMP V2,#12
	BNE DRAWBOARDY
	//Redraw grid
	//BL GoL_draw_grid_ASM
	POP {V1-V6,LR}
	BX LR

GoLBoard:
	//  x 0 1 2 3 4 5 6 7 8 9 a b c d e f    y
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 // 0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 // 1
	.word 0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0 // 2
	.word 0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0 // 3
	.word 0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0 // 4
	.word 0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0 // 5
	.word 0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0 // 6
	.word 0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0 // 7
	.word 0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0 // 8
	.word 0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0 // 9
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 // a
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 // b

GoLBoardNext:
	//  x 0 1 2 3 4 5 6 7 8 9 a b c d e f    y
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 // 0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 // 1
	.word 0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0 // 2
	.word 0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0 // 3
	.word 0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0 // 4
	.word 0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0 // 5
	.word 0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0 // 6
	.word 0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0 // 7
	.word 0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0 // 8
	.word 0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0 // 9
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 // a
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 // b

KEYPRESSED: .word 0
JUNK: .word 0
BUFFER: .word 0,0,0,0,0,0,0,0,0,0
//V1: potential cursor index
//V2: cursor position
//V6: initial sp address
//V5: ignore next key flag

_start:
       //Clear screen
	BL VGA_clear_charbuff_ASM
	//Makes the screen white
	BL VGA_clearwhite_pixelbuff_ASM
	//Draw grid
	MOV A1,#0x0
	BL GoL_draw_grid_ASM
	BL GoL_draw_board_ASM
	MOV V5,#0
	MOV V6,SP
	MOV V1,#0
	//Draw cursor, blue if on inactive tile, red if on active tile
	LDR R12,=GoLBoard
	MOV V8,#4
	MUL V8,V1,V8
	LDR V8,[R12,V8]
	MOV R12,#1
	TST R12,V8
	//Convert index into x and y
	MOV V7,#15
	AND A1,V1,V7
	MOV A2,V1,LSR #4
	//Inactive
	LDREQ A3,=0xFF
	//Active
	LDRNE A3,=0xF000
	BL GoL_fill_gridxy_ASM
	
		
LOOP:
	MOV V2,V1
	
	//Read keyboard, push on stack
	LDR V8,=KEYPRESSED
	MOV A1,V8
	BL read_PS2_data_ASM
	//If fresh key pressed, update, otherwise end iteration
	MOV R12,#1
	CMP A1,R12
	LDR A1,[V8]
	PUSHEQ {A1}
	CMP V5,R12
	POPEQ {R12}
	MOVEQ V5,#0
	

SKIP2:
	CMP SP,V6 //If stack increased, extract key
	BEQ LOOP
	
EXTRACTKEY:
	
	POP {V3}
	LDR A1,=0xF0
	CMP V3,A1
	MOVEQ V5,#1
	
	
END:
	
	LDR V4,=0x1D
	CMP V3,V4
	//Go up
	MOVEQ V3, #16
	SUBEQ V1,V3
	BEQ KEYENTERED
	
	LDR V4,=0x1B
	CMP V3,V4
	//Go down
	MOVEQ V3, #16
	ADDEQ V1,V3
	BEQ KEYENTERED
	
	LDR V4,=0x1C
	CMP V3,V4
	//Go left if possible
	BNE SKIP
	MOVEQ V3, #1
	MOVEQ V7,#15
	ANDEQ V4,V1,V7
	SUBEQ V4,V3
	MOVEQ V7,#0
	CMPEQ V4,V7
	SUBGE V1,V3
	BGE KEYENTERED

SKIP:

	LDR V4,=0x29
	CMP V3,V4
	//Toggle activity of current tile
	BNE SKIP3
	LDR V3,=GoLBoard
	MOV V4,#4
	MUL V4,V4,V1
	LDR V7,[V3,V4]
	MOV V8,#1
	EOR V7,V8,V7
	STR V7,[V3,V4]
	
	//Draw cursor, blue if on inactive tile, red if on active tile
	LDR R12,=GoLBoard
	MOV V8,#4
	MUL V8,V1,V8
	LDR V8,[R12,V8]
	MOV R12,#1
	TST R12,V8
	//Convert index into x and y
	MOV V7,#15
	AND A1,V1,V7
	MOV A2,V1,LSR #4
	//Inactive
	LDREQ A3,=0xFF
	//Active
	LDRNE A3,=0xF000
	BL GoL_fill_gridxy_ASM
	B KEYENTERED

SKIP3:

	LDR V4,=0x31
	CMP V3,V4
	//Check neighbor and update board
	BNE SKIP4
	
	MOV V4,#0
LOOPCHECKY:
	MOV V3,#0
	LOOPCHECKX:
		//V8: current cell index
		//A1: nb neighbours
		LDR A3,=GoLBoard
		
		MOV V8,V3
		MOV V7,#16
		MUL V7,V4,V7
		ADD V8,V7
		
		//nb neighbor is in A1
		MOV A1,#0
		
		//Check up
		MOV V7,#16
		SUB R12,V8,V7
		MOV A2,#0 //boundary check up
		CMP R12,A2
		BLT NEX1
		MOV A2,#4
		MUL R12,A2
		LDR A2, [A3,R12]
		ADD A1,A2
NEX1:
		//Check down
		MOV V7,#16
		ADD R12,V8,V7
		MOV A2,#191 //boundary check down
		CMP R12,A2
		BGT NEX2
		MOV A2,#4
		MUL R12,A2
		LDR A2, [A3,R12]
		ADD A1,A2
NEX2:
		//Check left
		MOV V7,#1
		SUB R12,V8,V7
		//boundary check left (reject wrap back to opposite side)
		MOV A2,#15
		AND V7,R12,A2
		CMP V7,A2
		BEQ NEX3
		MOV A2,#4
		MUL R12,A2
		LDR A2, [A3,R12]
		ADD A1,A2
NEX3:
		//Check right
		MOV V7,#1
		ADD R12,V8,V7
		//boundary check right (reject wrap back to opposite side)
		MOV A2,#15
		AND V7,R12,A2
		MOV A2,#0
		CMP V7,A2
		BEQ NEX4
		MOV A2,#4
		MUL R12,A2
		LDR A2, [A3,R12]
		ADD A1,A2
NEX4:
		//Check top-left
		//Check up
		MOV V7,#16
		SUB R12,V8,V7
		MOV A2,#0 //boundary check up
		CMP R12,A2
		BLT NEX5
		//Check left
		MOV V7,#1
		SUB R12,V7
		//boundary check left (reject wrap back to opposite side)
		MOV A2,#15
		AND V7,R12,A2
		CMP V7,A2
		BEQ NEX5
		MOV A2,#4
		MUL R12,A2
		LDR A2, [A3,R12]
		ADD A1,A2

NEX5:
		//Check top-right
		//Check up
		MOV V7,#16
		SUB R12,V8,V7
		MOV A2,#0 //boundary check up
		CMP R12,A2
		BLT NEX6
		//Check right
		MOV V7,#1
		ADD R12,V7
		//boundary check right (reject wrap back to opposite side)
		MOV A2,#15
		AND V7,R12,A2
		MOV A2,#0
		CMP V7,A2
		BEQ NEX6
		MOV A2,#4
		MUL R12,A2
		LDR A2, [A3,R12]
		ADD A1,A2
		
NEX6:
		//Check bottom-left
		//Check down
		MOV V7,#16
		ADD R12,V8,V7
		MOV A2,#191 //boundary check down
		CMP R12,A2
		BGT NEX7
		//Check left
		MOV V7,#1
		SUB R12,V7
		//boundary check left (reject wrap back to opposite side)
		MOV A2,#15
		AND V7,R12,A2
		CMP V7,A2
		BEQ NEX7
		MOV A2,#4
		MUL R12,A2
		LDR A2, [A3,R12]
		ADD A1,A2
NEX7:
		//Check bottom right
		//Check down
		MOV V7,#16
		ADD R12,V8,V7
		MOV A2,#191 //boundary check down
		CMP R12,A2
		BGT NEX8
		//Check right
		MOV V7,#1
		ADD R12,V7
		//boundary check right (reject wrap back to opposite side)
		MOV A2,#15
		AND V7,R12,A2
		MOV A2,#0
		CMP V7,A2
		BEQ NEX8
		MOV A2,#4
		MUL R12,A2
		LDR A2, [A3,R12]
		ADD A1,A2
NEX8:
		
		//Update condition
		MOV V7,#4
		MUL V7,V8,V7
		LDR A3,=GoLBoardNext
		LDR R12,[A3,V7]
		MOV A2,#1
		CMP R12,A2
		//If 1, update for active, otherwise update as inactive cell
		BNE INACTIVE
		
		MOV A2,#0
		MOV R12,#0
		CMP A1,A2
		STREQ R12,[A3,V7]
		
		MOV A2,#1
		MOV R12,#0
		CMP A1,A2
		STREQ R12,[A3,V7]
		
		
		MOV A2,#4
		MOV R12,#0
		CMP A1,A2
		STRGE R12,[A3,V7]
		
		B ENDING
		
		
		INACTIVE:
		
		MOV A2,#3
		MOV R12,#1
		CMP A1,A2
		STREQ R12,[A3,V7]
		
		ENDING:
		MOV V8,#1
		ADD V3,V8
		CMP V3,#16
		BNE LOOPCHECKX
	MOV V8,#1
	ADD V4,V8
	CMP V4,#12
	BNE LOOPCHECKY
	
	//Copy new board to current
	MOV V3,#0
	MOV V4,#4
	//Save values of V5 and V6
	PUSH {V5,V6}
	LDR V5,=GoLBoardNext
	LDR V6,=GoLBoard
COPYLOOP:
	
	
	MUL R12,V3,V4
	LDR V7,[V5,R12]
	STR V7,[V6,R12]
	
	MOV V8,#1
	ADD V3,V8
	CMP V3,#192
	BNE COPYLOOP
	
	//Resotre V5 and V6
	POP {V5,V6}
	BL GoL_draw_board_ASM
		

SKIP4:

	LDR V4,=0x23
	CMP V3,V4
	//Go right if possible
	BNE KEYENTERED
	MOVEQ V3, #1
	MOVEQ V7,#15
	ANDEQ V4,V1,V7
	ADDEQ V4,V3
	MOVEQ V7,#15
	CMPEQ V4,V7
	ADDLE V1,V3

KEYENTERED:
	//Check if within bounds (top and bottom)
	MOV V3,#0
	CMP V1,V3
	BLT SKIPCURSORWRITE
	LDR V3,=191
	CMP V1,V3
	BGT SKIPCURSORWRITE
	//Check if position not changed
	CMP V1,V2
	BEQ SKIPCURSORWRITE
	
	//Erase old cursor position
	//Draw blank at cursor, restore black if on active tile
	LDR R12,=GoLBoard
	MOV V8,#4
	MUL V8,V2,V8
	LDR V8,[R12,V8]
	MOV R12,#1
	TST R12,V8
	//Convert index into x and y
	MOV V7,#15
	AND A1,V2,V7
	MOV A2,V2,LSR #4
	//Inactive
	LDREQ A3,=0xFFFF
	//Active
	LDRNE A3,=0x0
	BL GoL_fill_gridxy_ASM
	
	//Register as new cursor position
	MOV V2,V1
	
	//Draw cursor, blue if on inactive tile, red if on active tile
	LDR R12,=GoLBoard
	MOV V8,#4
	MUL V8,V1,V8
	LDR V8,[R12,V8]
	MOV R12,#1
	TST R12,V8
	//Convert index into x and y
	MOV V7,#15
	AND A1,V1,V7
	MOV A2,V1,LSR #4
	//Inactive
	LDREQ A3,=0xFF
	//Active
	LDRNE A3,=0xF000
	BL GoL_fill_gridxy_ASM
SKIPCURSORWRITE:
	MOV V1,V2
	B LOOP
end:
        b       end
