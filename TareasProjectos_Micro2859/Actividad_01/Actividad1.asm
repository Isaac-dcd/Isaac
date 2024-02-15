;
; Actividad1.asm
;
; Created: 2/7/2024 7:56:21 PM
; Author : Isaac-dcd
; Program to generate a discrete signal
; using internal 16 bits Timer and 2 inputs
;
.include "./m328Pdef.inc"
.def temp=r16

;init code segment
.cseg
.org 0x00
	;Setting Fast PWM
	;ldi temp, 1<<WGM13 | 1<<WGM12 
	;out TCCR1B, temp
	;ldi temp, 1<<WGM11 | 1<<WGM10
	;out TCCR1A, temp;PWM mode 15
	;sbi TCCR1A,COM1A0;duty cycle=50%
	;out TCCR1B, 1<<ICNC1 | 1<<CS12 | 1<<CS11 | 1<<CS10 ;PRESCALER=256 & noise Canceler
	ldi r16,0b10111100
	sts TCCR1B,r16
	ldi r16,0b01000011
	sts TCCR1A,r16													;F=62.5K, T=16u
	;Setting PORTB													;MAX=2^16=65,536
	;two ways of set PB5
	;sbi DDRB,PB5 ; PB5->output
	ldi r16,0b00100110 
	out DDRB,r16 ; PB1 & PB2 & PB5->output, and PB3 & PB4->input
	ldi temp,1<<PB3 | 1<<PB2
	out	PORTB,temp

start:
	rcall top_values
	;start counter on 0
	ldi r16,0
	sts TCNT1H, r16
	sts TCNT1L, r16
	;led status
	lds r16,OCF1A
	cpi r16,0
	brne led_on
	cbi PORTB5,PB5 ;write '0'
	led_on:
		sbi PORTB5,PB5 ;write '1'
		ret ;end of led_on

	;in	R16,PINB
	;andi r16,0b00011000
	;brne start	   	
	;sbi PORTB,PB5	;writes logic "1" on PB5
	;rcall delay		;wait for 200ms
	;cbi PORTB,PB5	;writes logic "0" on PB5
	;rcall delay		;wait for 200ms*/
	rjmp start	

top_values:
	
	;reading input
	in r17,PB2 ;Low part
	in r18,PB3 ;High part
	cpi r18,0
	brne highfrec
	cpi r17,0
	brne twodotfivehertz
	;1Hz case
	ldi r21,0xF4
	ldi r20,0x23
	sts OCR1AH,r21
	sts OCR1AL,r20
	twodotfivehertz:
	ldi r21,0x61
	ldi r20,0xA7
		sts OCR1AH,r21
		sts OCR1AL,r20
		ret ;end of 2.5Hz case
	highfrec:
		cpi r17,0
		brne thenkilohertz
		;50 Hz case
		ldi r21,0x04
		ldi r20,0xE1
		sts OCR1AH,r21
		sts OCR1AL,r20
		thenkilohertz:
			ldi r21,0x00
			ldi r20,0x05
			sts OCR1AH,r21
			sts OCR1AL,r20
			ret ;end of thenkilohertz
		ret ;end of highrec case
	ret	;end of top_values


