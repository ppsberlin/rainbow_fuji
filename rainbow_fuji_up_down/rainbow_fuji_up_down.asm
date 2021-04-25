/*
rainbow_fuji by PPs
coded:	24.04.2021
*/

	BEGIN	equ $2000		;assemble code to this address

;define needed registers
setvbv	= $e45c
xitvbv	= $e462
color0	= $d016
color1	= $d017
color2	= $d018
colbak	= $d01a
consol	= $d01f
trig0	= $d010
trig1	= $d011
nmien	= $d40e
chbase	= $d409
skctl	= $d20f
wsync	= $d40a

.enum	@dmactl
	blank	= %00
	narrow	= %01
	standard= %10
	wide	= %11
	missiles= %100
	players	= %1000
	lineX1	= %10000
	lineX2	= %00000
	dma	= %100000
.ende
;define registers end

	.zpvar .byte regx,regy,rega,store

	org BEGIN
	.proc ant
	.he 70 70 70 70 70 60 80 44
	.wo screen
:10	.he 04
:06	.he 02
	.he 41
	.wo ant
	.endp
;------------
	.proc main
	mva #0 559			;screen off
	mwa #ant 560			;new DL
	mwa #dli 512			;DLI address
	lda #7				;deffered VBI
	ldx >vbi
	ldy <vbi
	jsr setvbv
	mva #$c0 nmien			;DLI & VBI on
	mva #@dmactl(narrow|dma) 559	;screen on
loop	jmp loop
	.endp
;------------
	.proc vbi
	mwa #dli 512
	mva #0 77
	sta colbak
	sta color2
	jmp xitvbv
	.endp
;------------
	.proc dli
	sta rega
	stx regx
	sty regy

	mva >fnt chbase
	sta wsync
	lda $13
	cmp store
	bne chg
furth	ldy $14
	ldx #85
lp	sty color1
	sty color2
	sty color0
	sta wsync
what	iny
	dex
	bpl lp
	mva #0 color2
	mva #$e color1
	sta wsync
	ldy regy
	ldx regx
	lda rega
	rti
;-------
chg
	lda what
	cmp #$88	;dey?
	bne c_dey
;c_iny
	lda #$c8	;iny
	sta what
	mva $13 store
	jmp furth
c_dey
	lda #$88	;dey
	sta what
	mva $13 store
	jmp furth
	.endp
;------------
	.proc screen
	ins 'fujilogo.scr'
	.endp
;------------
	.align $0400
	.proc fnt
	ins 'fujilogo.fnt'
	.endp
;------------
	run main