; PIC16F1786 Configuration Bit Settings

; Assembly source line config statements

#include "p16f1786.inc"

; CONFIG1
; __config 0xFFE4
 __CONFIG _CONFIG1, _FOSC_INTOSC & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _CLKOUTEN_OFF & _IESO_ON & _FCMEN_ON
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _WRT_OFF & _VCAPEN_OFF & _PLLEN_ON & _STVREN_ON & _BORV_LO & _LPBOR_OFF & _LVP_ON

    UDATA_SHR
OSC	    EQU	B'00000111'
INITCONT    EQU	B'11111110'
PRE	    EQU	B'11000000'
 
CONTEXT_SAVING	UDATA_SHR
	W_TMP	res 1
	S_TMP	res 1
	CONUT	res 1
	SEG	res 1
	OUTINT	res 1
	OPEN_INDEX  res	1
	OPEN_COUNT  res	1
	OPEN_ALL    res	1
	OPEN_DIX1    res	1
	OPEN_DIX2    res	1
	
 
RST CODE 0x0
    PAGESEL MAIN
    GOTO    MAIN
 
ISR	CODE 0x04
	MOVWF	W_TMP
	SWAPF	STATUS, W
	MOVWF	S_TMP ;;??
	
	BANKSEL	INTCON
	BTFSC	INTCON, INTF
	GOTO	OINT
	GOTO	ININT
	
	OINT
	BANKSEL	INTCON
	BCF INTCON, INTF
	MOVLW B'000000001'     
	XORWF OUTINT
	
	ININT
	
	BANKSEL SEG
	MOVLW B'00000000'   
	MOVWF SEG
	BANKSEL	SEG
	MOVF	SEG, W
	BANKSEL	PORTC
	MOVWF	PORTC
	
	BANKSEL	CONUT
	INCF	CONUT,F
	BTFSC	CONUT,2
	GOTO	CONUTINIT ;;?4??
	
	SHOW 
	CALL	COUNTER
	CALL	DECODER
	BANKSEL	SEG
	MOVF	SEG, W
	BANKSEL	PORTC
	MOVWF	PORTC ;;????
	;CALL	DELAY
	
	BANKSEL	INTCON
	BCF	INTCON, TMR0IF
	BANKSEL	TMR0
	MOVLW	INITCONT
	MOVWF	TMR0  ;;????
	
	SWAPF	S_TMP, W ;;??
	MOVWF	STATUS
	SWAPF	W_TMP, F
	SWAPF	W_TMP, W
	RETFIE
	
	CONUTINIT   
	BANKSEL	CONUT
	MOVLW	B'00000000'
	MOVWF	CONUT
	GOTO	SHOW ;;??connter
	
	CODE
MAIN	
	BANKSEL	TMR0
	MOVLW	INITCONT
	MOVWF	TMR0
	BANKSEL	OPTION_REG
	MOVLW	PRE
	MOVWF OPTION_REG  ;;timer0??
	
	BANKSEL	OSCCON
	MOVLW	OSC
	MOVWF	OSCCON  ;;??????
	
	BANKSEL PORTA
	CLRF PORTA		 
	BANKSEL LATA	
	MOVLW B'00000111'   
	MOVWF LATA
	BANKSEL ANSELA
	CLRF ANSELA		
	BANKSEL TRISA
	MOVLW B'00000000'   
	MOVWF TRISA  ;;porta??
	
	BANKSEL PORTB;
	CLRF PORTB 
	BANKSEL ANSELB ;
	CLRF ANSELB 
	BANKSEL TRISB
	MOVLW B'11111111' 
	MOVWF TRISB	;;portb????
	BANKSEL	INLVLB
	MOVLW	B'11111111'
	MOVWF	INLVLB
	
	BANKSEL PORTC
	CLRF PORTC
	BANKSEL LATC	
	CLRF LATC	
	BANKSEL TRISC
	MOVLW B'00000000'   
	MOVWF TRISC  ;;portc????
	
	BANKSEL	CONUT
	MOVLW	B'00000000'
	MOVWF	CONUT
	BANKSEL	SEG
	MOVLW	B'00000010'
	MOVWF	CONUT	;;??????????
	BANKSEL	OUTINT
	MOVLW	B'00000001'
	MOVWF	OUTINT
	BANKSEL	OPEN_INDEX
	MOVLW	B'00000000'
	MOVWF	OPEN_INDEX
	
	BANKSEL	INTCON
	MOVLW	B'00000000'
	MOVWF	INTCON
	
	OPEN_AC
	
	MOVLW   09H
	MOVWF   OPEN_DIX1
	LOOP2_D
	MOVLW   10H
	MOVWF   OPEN_DIX2
	LOOP1_D
	CALL	OPENON
	DECFSZ  OPEN_DIX2, F
	GOTO    LOOP1_D
	DECFSZ  OPEN_DIX1, F
	GOTO    LOOP2_D
	
	BANKSEL	OPEN_INDEX
	INCF	OPEN_INDEX,F
	BTFSC	OPEN_INDEX,2
	GOTO	SEL
	GOTO	OPEN_AC
	SEL
	BTFSC	OPEN_INDEX,3
	GOTO	OPENINTCON
	GOTO	OPEN_AC
	
	OPENINTCON
	BANKSEL	INTCON
	BSF INTCON, GIE
	BSF INTCON, TMR0IE
	BSF INTCON, INTE
	
	MAINLOOP
	NOP
	GOTO	MAINLOOP
	
DELAY:
    MOVLW   02H
    MOVWF   20H
    LOOP2
    MOVLW   7H
    MOVWF   21H
    LOOP1
    DECFSZ  21H, F
    GOTO    LOOP1
    DECFSZ  20H, F
    GOTO    LOOP2
    RETURN  
    
DELAY_SHORT:
    MOVLW   b'00000100' ;00001100--12
    MOVWF   20H
    LOOP2_S
    MOVLW   b'00000001' ;00010100--20
    MOVWF   21H
    LOOP1_S
    DECFSZ  21H, F
    GOTO    LOOP1_S
    DECFSZ  20H, F
    GOTO    LOOP2_S
    RETURN  

OPENON:
    ;;???????
    MOVLW	B'00000000'
    MOVWF	CONUT
    
    OPEN_LOOP
    
    ;CALL    DELAY_SHORT
    CALL    COUNTER
    MOVF    OPEN_INDEX, W
    ADDWF   CONUT, W
    MOVWF   OPEN_ALL
    CALL    NEW_DECODER
    BANKSEL	SEG
    MOVF	SEG, W
    BANKSEL	PORTC
    MOVWF	PORTC ;;????
    
    BANKSEL SEG
    MOVLW B'00000000'   
    MOVWF SEG
    BANKSEL	SEG
    MOVF	SEG, W
    BANKSEL	PORTC
    MOVWF	PORTC
    
    BANKSEL	CONUT
    INCF	CONUT,F
    BTFSC	CONUT,2
    GOTO	RE_TURN ;;?4??

    GOTO    OPEN_LOOP
    RE_TURN
    RETURN

NEW_DECODER:  
    BANKSEL OPEN_ALL
    MOVF    OPEN_ALL, W
    CALL    OPEN_TABLE
    MOVWF   SEG
    RETURN
    
DECODER:
    ;;???
    BANKSEL CONUT    
    MOVF    CONUT, W
    CALL    SEG_TABLE
    MOVWF   SEG
    RETURN
    
COUNTER:
    ;???????
    BTFSC   OUTINT, 0
    GOTO    AC1
    
    BANKSEL CONUT
    BTFSC   CONUT, 0
    GOTO    COMP3
    GOTO    COMP4
    COMP3
    BTFSC   CONUT, 1
    GOTO    L1
    GOTO    L3
    COMP4
    BTFSC   CONUT, 1
    GOTO    L2
    GOTO    L4
    
    AC1
    BANKSEL CONUT
    BTFSC   CONUT, 0
    GOTO    COMP1
    GOTO    COMP2
    COMP1
    BTFSC   CONUT, 1
    GOTO    L4
    GOTO    L2
    COMP2
    BTFSC   CONUT, 1
    GOTO    L3
    GOTO    L1
    
    
    ;;???????
    L1
    BANKSEL PORTA
    MOVLW   B'00001110'
    MOVWF   PORTA
    GOTO RETU
    L2
    BANKSEL PORTA
    MOVLW   B'00001101'
    MOVWF   PORTA
    GOTO RETU
    L3
    BANKSEL PORTA
    MOVLW   B'00001011'
    MOVWF   PORTA
    GOTO RETU
    L4
    BANKSEL PORTA
    MOVLW   B'00000111'
    MOVWF   PORTA
    RETU
    RETURN
    
SEG_TABLE
    BRW
    RETLW   B'11111100' ;;0
    RETLW   B'01100000' ;;1
    RETLW   B'11011010' ;;2
    RETLW   B'11110010'	;;3

OPEN_TABLE
    BRW
    RETLW   B'00000010' ;
    RETLW   B'00000010' ;
    RETLW   B'00000010' ;
    RETLW   B'10110110' ;s
    RETLW   B'10011110' ;e
    RETLW   B'10011110' ;e
    RETLW   B'11111100'	;d
    RETLW   B'10011100'	;c
    RETLW   B'00011100'	;l
    RETLW   B'11101110'	;a
    RETLW   B'10110110' ;s
    RETLW   B'10110110' ;s
    RETLW   B'00000010' ;
    RETLW   B'00000010' ;
    RETLW   B'00000010' ;
	END