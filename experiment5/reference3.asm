; PIC16F1786 Configuration Bit Settings

; Assembly source line config statements

#include "p16f1786.inc"

; CONFIG1
; __config 0xFFE4
 __CONFIG _CONFIG1, _FOSC_INTOSC & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _CLKOUTEN_OFF & _IESO_ON & _FCMEN_ON
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _WRT_OFF & _VCAPEN_OFF & _PLLEN_ON & _STVREN_ON & _BORV_LO & _LPBOR_OFF & _LVP_ON

CONTEXT    UDATA_SHR
    CONFIG_OSC		EQU	B'01101111' ;;??????
    CONFIG_INITCONT	EQU	B'00000000' ;;TMR0???
    CONFIG_PREHZ	EQU	B'01000011' ;;timer0???	
	
	W_TMP	res 1
	S_TMP	res 1
	COUNT	res 1	;;??
	SEG	res 4	;;LED0 seg
	OUTINT	res 1 ;;???????
	DELAY1	res 1 ;;????
	DELAY2	res 1 ;;
	DELAY3	res 1;;
	DELAY4	res 1;;
	SCAN_SWITCH_INDEX   res	1 ;;which switch has been scan
	READNUM	res 1
	LOOPCOUNT   res	1
	    UDATA
	SCAN_COUNT_0	res 1 ;;number of input 0 
	SCAN_TMP    res	1 ;;store input number
	SCAN_IN	res 1  ;;store input statu
	SCAN_STATU_INDEX	res 1 ;;statu for scan
	PRE_SCAN_S1 res 1
	PRE_SCAN_S2 res 1
	PRE_SCAN_S3 res 1
	SCAN_ADD_TMP	res 1
	SCAN_HAVE   res	1
	TEST	res 1
	SCAN_SWITCH_INDEX2  res	1
	SCAN_COUNT1  res 1
	SCAN_CHANGE res	1
	
	ATER_SWITCH_TMP	res 1
	AFTER_SWITCH	res 1
	DELAY_COUNTER1	res 1
	DELAY_COUNTER2	res 1
	SWITCH_PUSH_COUNT   res	1

	FLAG	res 1
	TAG	res 1
	VOLTAGE	res 1
	CNT_LONG    res	1
	CNT_LONG_C  res	1
	CNT_DOUBLE  res	1
	CNT_DOUBLE_C	res 1	    
	
RST CODE 0x0
    PAGESEL MAIN
    GOTO    MAIN
    
ISR	CODE 0x04
	MOVWF	W_TMP
	SWAPF	STATUS, W
	MOVWF	S
	CALL	DECO_TMP ;;??
	
	CALL	DECODER
	CALL    AFTER_DEAL_SCAN
	CALL	AADD_SELF

	BANKSEL	INTCON
	BCF	INTCON, TMR0IF
	BANKSEL	TMR0
	MOVLW	CONFIG_INITCONT
	MOVWF	TMR0  ;;???? 
	
	SWAPF	S_TMP, W ;;??
	MOVWF	STATUS
	SWAPF	W_TMP, F
	SWAPF	W_TMP, W
	RETFIE
	
	
	CODE
MAIN
    BANKSEL	TMR0
    MOVLW	CONFIG_INITCONT
    MOVWF	TMR0
    BANKSEL	OPTION_REG
    MOVLW	CONFIG_PREHZ
    MOVWF	OPTION_REG  ;;timer0??
    
    BANKSEL	OSCCON
    MOVLW	CONFIG_OSC
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
    CLRF    PORTB 
    BANKSEL ANSELB ;
    CLRF    ANSELB 
    BANKSEL TRISB
    MOVLW   B'00001111' 
    MOVWF   TRISB	

    BANKSEL PORTC
    CLRF    PORTC
    BANKSEL LATC	
    CLRF    LATC	
    BANKSEL TRISC
    MOVLW   B'00000000'   
    MOVWF   TRISC  ;;portc????
    
    MOVLW   B'00000000'
    MOVWF   COUNT
    MOVLW   B'00000001'
    MOVWF   OUTINT
    MOVLW   B'00000000'
    MOVWF   SEG+0x0
    MOVLW   B'00000000'
    MOVWF   SEG+0x1
    MOVLW   B'00000000'
    MOVWF   SEG+0x2
    MOVLW   B'00000000'
    MOVWF   SEG+0x3  ;;?????
    BANKSEL SCAN_SWITCH_INDEX
    MOVLW   .0
    MOVWF   SCAN_SWITCH_INDEX
    BANKSEL SCAN_COUNT1
    MOVLW   .0
    MOVWF   SCAN_COUNT1
    
    BANKSEL	INTCON
    BSF INTCON, GIE
    BSF INTCON, TMR0IE
    BCF INTCON, INTE ;;	??????
    
    MAINLOOP
    CALL    ONE_ZERO
    GOTO    MAINLOOP

AADD_SELF:
    BANKSEL TAG
    BTFSC TAG,1
    GOTO aaa
    MOVLW B'00000001'
    ADDWF  CNT_LONG,W
    MOVLW B'00011000'
    XORWF  CNT_LONG,W
    BNZ  INIT_LONG
    aaa
    BTFSC TAG,2
    GOTO bbb	
    MOVLW B'00000001'
    ADDWF  CNT_DOUBLE,W
    MOVLW B'00011000'
    XORWF  CNT_DOUBLE,W
    BNZ  INIT_DOUBLE
    INIT_LONG
    CLRF CNT_LONG
    MOVLW B'00000001'
    ADDWF  CNT_LONG_C,W
    GOTO aaa
    INIT_DOUBLE
    CLRF CNT_DOUBLE
    MOVLW B'00000001'
    ADDWF  CNT_DOUBLE_C,W
    bbb
    RETURN
    
LONG_SHORT_SHOW:
    BANKSEL TAG
    MOVFW   TAG
    SUBLW   B'00000001'
    BZ	    FLAG_S1
    
    MOVFW   TAG
    SUBLW   B'00000010'
    BZ	    FLAG_S1
    
    MOVFW   TAG
    SUBLW   B'00000100'
    BZ	    FLAG_S1
    
    MOVFW   TAG
    SUBLW   B'00001000'
    BZ	    FLAG_S4
    
    MOVFW   TAG
    SUBLW   B'00010000'
    BZ	    FLAG_S5
    
    FLAG_S1
    BANKSEL SEG
    MOVLW   .0
    MOVWF   SEG+0x2
    MOVLW   .0
    MOVWF   SEG+0x3
    
    FLAG_S4
    BANKSEL SEG
    MOVLW   .0
    MOVWF   SEG+0x2
    MOVLW   .1
    MOVWF   SEG+0x3
    
    FLAG_S5
    BANKSEL SEG
    MOVLW   .1
    MOVWF   SEG+0x2
    MOVLW   .0
    MOVWF   SEG+0x3
    ;MOVWF   
    RETURN
    
FLAG_SHOW:
    MOVFW   TAG
    SUBLW   B'00000100'
    BZ	    FLAG_S1
    RETURN
    
ONE_ZERO:
    S1
    MOVLW   .0
    BANKSEL FLAG
    MOVWF FLAG
    BANKSEL TAG
    MOVLW B'00000001'
    MOVWF TAG
    BANKSEL AFTER_SWITCH
    MOVFW    AFTER_SWITCH
    SUBLW   .0
    BNZ	    S2
    GOTO    S1
    S2
    BANKSEL TAG
    MOVLW   B'00000010'
    MOVWF   TAG
    BANKSEL CNT_LONG_C
    BTFSC   CNT_LONG_C,7
    GOTO    S5
    BANKSEL AFTER_SWITCH
    MOVFW    AFTER_SWITCH
    SUBLW   .0
    BNZ	    S2
    GOTO    S3
    S3
    BANKSEL  TAG
    MOVLW B'00000100'
    MOVWF TAG
    BTFSC CNT_DOUBLE_C,6
    GOTO S1
    BANKSEL AFTER_SWITCH
    MOVFW    AFTER_SWITCH
    SUBLW   .0
    BNZ	S4
    GOTO S3
    S4
    BANKSEL FLAG
    MOVLW B'00000011'
    MOVWF FLAG
    BANKSEL TAG
    MOVLW B'00001000'
    MOVWF TAG
    BANKSEL AFTER_SWITCH
    MOVFW    AFTER_SWITCH
    SUBLW   .0
    BZ  S1
    GOTO S4
    S5
    BANKSEL FLAG
    MOVLW B'00000010'
    MOVWF FLAG
    BANKSEL TAG
    MOVLW B'00010000'
    MOVWF TAG
    BANKSEL AFTER_SWITCH
    MOVFW    AFTER_SWITCH
    SUBLW   .0
    BNZ  S1
    GOTO  S5
    RETURN


    
AFTER_DEAL_SCAN:
    CALL    SWITCH_SCAN
    BANKSEL ATER_SWITCH_TMP
    MOVFW   ATER_SWITCH_TMP
    BANKSEL SCAN_SWITCH_INDEX
    SUBWF   SCAN_SWITCH_INDEX, W
    BZ	UPPER_1
    GOTO    CLEAR_SCAN_AFTER
    UPPER_1
    BANKSEL DELAY_COUNTER1
    INCF    DELAY_COUNTER1, F
    BTFSS   DELAY_COUNTER1, 7
    GOTO    UPPTER_2
    BANKSEL DELAY_COUNTER2
    MOVLW   .0
    MOVWF   DELAY_COUNTER2
    UPPTER_2
    BANKSEL DELAY_COUNTER2
    INCF    DELAY_COUNTER2, F
    BTFSS   DELAY_COUNTER2, 3
    GOTO    RETURN_AFTER    
    BANKSEL DELAY_COUNTER2
    MOVLW   .0
    MOVWF   DELAY_COUNTER2
    BANKSEL ATER_SWITCH_TMP
    MOVFW    ATER_SWITCH_TMP
    
    SUBWF   AFTER_SWITCH, W
    BNZ	    COUNT_ADD
    GOTO    SEND_TMP
    COUNT_ADD
    BANKSEL ATER_SWITCH_TMP
    MOVFW    ATER_SWITCH_TMP
    BANKSEL SWITCH_PUSH_COUNT
    SUBLW   .0
    BNZ	SEND_TMP
    INCF   SWITCH_PUSH_COUNT,F
    BTFSC   SWITCH_PUSH_COUNT, 4
    GOTO    CLEAR_SWITCH_PUSH
    GOTO    SEND_TMP
    CLEAR_SWITCH_PUSH
    MOVLW   .0
    MOVWF   SWITCH_PUSH_COUNT
    
    SEND_TMP
    BANKSEL ATER_SWITCH_TMP
    MOVFW    ATER_SWITCH_TMP
    BANKSEL AFTER_SWITCH
    MOVWF   AFTER_SWITCH
    
    ;;????
    SUBLW   .0
    BZ	RETURN_AFTER
    BANKSEL AFTER_SWITCH
    MOVFW    AFTER_SWITCH
    BANKSEL SEG+0x0
    MOVWF   SEG+0x0
    BANKSEL SWITCH_PUSH_COUNT
    MOVFW    SWITCH_PUSH_COUNT
    BANKSEL SEG+0x1
    MOVWF   SEG+0x1
    
    BANKSEL FLAG
    MOVFW    FLAG
    BANKSEL SEG+0x2
    MOVWF   SEG+0x2
    
    BANKSEL TAG
    MOVFW    TAG
    BANKSEL SEG+0x3
    MOVWF   SEG+0x3
    
    GOTO    RETURN_AFTER
    CLEAR_SCAN_AFTER
    BANKSEL SCAN_SWITCH_INDEX
    MOVFW    SCAN_SWITCH_INDEX
    BANKSEL ATER_SWITCH_TMP
    MOVWF   ATER_SWITCH_TMP
    BANKSEL DELAY_COUNTER2
    MOVLW   .0
    MOVWF   DELAY_COUNTER2
    BANKSEL DELAY_COUNTER1
    MOVLW   .0
    MOVWF   DELAY_COUNTER1
    RETURN_AFTER
    RETURN
    

RUNNUMBER:
    DIELOOP
    MOVLW  .0
    MOVWF   LOOPCOUNT
    
    INCF	LOOPCOUNT,F
    BTFSC	LOOPCOUNT,2 
    NOP
    GOTO    DIELOOP
    RETURN
    
CLOSELED:
    ;;???????
    BANKSEL PORTC
    MOVLW   B'00000000'
    MOVWF   PORTC
    RETURN
    
DELAY:
    MOVLW   19H
    MOVWF   DELAY2
    LOOP2
    MOVLW   22H
    MOVWF   DELAY1
    LOOP1
    DECFSZ  DELAY1, F
    GOTO    LOOP1
    DECFSZ  DELAY2, F
    GOTO    LOOP2
    RETURN  
DELAY_SHORT:
    MOVLW   02H
    MOVWF   DELAY4
    LOOP4
    MOVLW   20H
    MOVWF   DELAY3
    LOOP3
    DECFSZ  DELAY3, F
    GOTO    LOOP3
    DECFSZ  DELAY4, F
    GOTO    LOOP4
    RETURN  
    
DECODER:
    ;;???
    ;CALL    CLOSELED
    MOVLW   B'00000000'
    MOVWF   COUNT
    CALL    COUNTER
    MOVF    SEG+0x0, W
    CALL    SEG_TABLE
    MOVWF   PORTC
    CALL    DELAY
    
    CALL    CLOSELED
    MOVLW   B'00000001'
    MOVWF   COUNT
    CALL    COUNTER
    MOVF    SEG+0x1, W
    CALL    SEG_TABLE
    MOVWF   PORTC
    CALL    DELAY
    
    CALL    CLOSELED
    MOVLW   B'00000010'
    MOVWF   COUNT
    CALL    COUNTER
    MOVF    SEG+0x2, W
    CALL    SEG_TABLE
    MOVWF   PORTC
    CALL    DELAY
    
    CALL    CLOSELED
    MOVLW   B'00000011'
    MOVWF   COUNT
    CALL    COUNTER
    MOVF    SEG+0x3, W
    CALL    SEG_TABLE
    MOVWF   PORTC
    CALL    DELAY
    
    CALL    CLOSELED
    RETURN
    
    
COUNTER:
    ;???????
    BTFSC   OUTINT, 0
    GOTO    AC1
    
    BANKSEL COUNT
    BTFSC   COUNT, 0
    GOTO    COMP3
    GOTO    COMP4
    COMP3
    BTFSC   COUNT, 1
    GOTO    L1
    GOTO    L3
    COMP4
    BTFSC   COUNT, 1
    GOTO    L2
    GOTO    L4
 
    AC1
    BANKSEL COUNT
    BTFSC   COUNT, 0
    GOTO    COMP1
    GOTO    COMP2
    COMP1
    BTFSC   COUNT, 1
    GOTO    L4
    GOTO    L2
    COMP2
    BTFSC   COUNT, 1
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
    RETLW   B'01100110'	;;4
    RETLW   B'10110110' ;;5
    RETLW   B'10111110'	;;6
    RETLW   B'11100000' ;;7
    RETLW   B'11111110' ;;8
    RETLW   B'11110110' ;;9
    RETLW   B'11101110' ;;A
    RETLW   B'11111110' ;;B
    RETLW   B'10011100' ;;C
    RETLW   B'11111100' ;;D
    RETLW   B'10011110' ;;E
    RETLW   B'10001110' ;;F
   
    
    
SWITCH_SCAN:
    BANKSEL SCAN_HAVE
    MOVLW   B'00000000'
    MOVWF   SCAN_HAVE
    
    MOVLW   B'00000001'
    BANKSEL SCAN_STATU_INDEX
    MOVWF   SCAN_STATU_INDEX
    GOTO    SCAN_STATU_CHOOSE
    
    SCAN_STATU_CHOOSE
    BANKSEL SCAN_STATU_INDEX
    BTFSC   SCAN_STATU_INDEX, 0
    GOTO    STEP1
    BTFSC   SCAN_STATU_INDEX, 1
    GOTO    STEP2
    BTFSC   SCAN_STATU_INDEX, 2
    GOTO    STEP3
    GOTO    STEP4
    
    STEP1

    BANKSEL TRISB
    MOVLW   B'00001111'
    MOVWF   TRISB

    GOTO    SCAN_NUMBER0
    
    STEP2
    BANKSEL PORTB
    MOVLW    B'00000111'
    MOVWF   PORTB
    BANKSEL TRISB
    MOVLW   B'00000111'
    MOVWF   TRISB
 
    GOTO    SCAN_NUMBER0
    
    STEP3
    BANKSEL PORTB
    MOVLW    B'00000011'
    MOVWF   PORTB

    BANKSEL TRISB
    MOVLW   B'00000011'
    MOVWF   TRISB
    BANKSEL PORTB
    MOVF    PORTB

    GOTO    SCAN_NUMBER0
    
    STEP4
    BANKSEL PORTB
    MOVLW    B'00000001'
    MOVWF   PORTB

    BANKSEL TRISB
    MOVLW   B'00000001'
    MOVWF   TRISB
    GOTO    SCAN_NUMBER0
    
    ;;get the number of input port 0 and store in the SCAN_COUNT_0
    SCAN_NUMBER0
    CALL    SCAN_HELP
    BANKSEL SCAN_COUNT_0
    MOVLW   B'00000001'
    MOVWF   SCAN_COUNT_0
    SCAN_NUM_1
    BANKSEL SCAN_IN
    LSRF    SCAN_IN, F
    BNC	    MODELSELC
    BANKSEL SCAN_TMP
    LSRF    SCAN_TMP, F
    BC	    SCAN_NUM_1
    BANKSEL SCAN_COUNT_0
    LSLF    SCAN_COUNT_0, F
    GOTO    SCAN_NUM_1
    
    ;;model1 model2 model3 goto
    MODELSELC
    BANKSEL SCAN_COUNT_0
    BTFSC   SCAN_COUNT_0, 0
    GOTO    MODEL0
    BTFSC   SCAN_COUNT_0, 1
    GOTO    MODEL1_PRE
    GOTO    MODEL2
    
    MODEL0
    BANKSEL SCAN_STATU_INDEX
    BTFSC   SCAN_STATU_INDEX, 3   
    GOTO    MODEL0_RETURN
    
    NEXT_STATU
    BANKSEL SCAN_STATU_INDEX
    LSLF    SCAN_STATU_INDEX, F
    GOTO    SCAN_STATU_CHOOSE
    
    MODEL0_RETURN
    BANKSEL SCAN_SWITCH_INDEX
    MOVF   SCAN_SWITCH_INDEX
    SUBLW  .0
    BNZ	    SCAN_COUNT_
    BANKSEL SCAN_COUNT1
    INCF    SCAN_COUNT1, F
    BTFSC   SCAN_COUNT1, 4
    GOTO    SCAN_COUNT_
    GOTO    SCAN_HA
    SCAN_COUNT_
    BANKSEL SCAN_COUNT1
    MOVLW   .0
    MOVWF   SCAN_COUNT1
    SCAN_HA
    BANKSEL SCAN_CHANGE
    BTFSC   SCAN_HAVE, 0
    GOTO    SCAN_RETURN
    GOTO    MODEL2
    
    MODEL1_PRE
    CALL    DELAY_SHORT
    GOTO    MODEL1

    MODEL1
    
    BANKSEL SCAN_HAVE
    MOVLW   B'00000001'
    MOVWF   SCAN_HAVE
    BTFSC   SCAN_STATU_INDEX, 0
    GOTO    MODEL1_STEP1
    BTFSC   SCAN_STATU_INDEX, 1
    GOTO    MODEL1_STEP2
    BTFSC   SCAN_STATU_INDEX, 2
    GOTO    MODEL1_STEP3
    GOTO    MODEL1_STEP4
    
    MODEL1_STEP1
  
    BANKSEL PORTB
    BTFSS   PORTB, 0
    GOTO    SCAN_TEMP1_0
    BTFSS   PORTB, 1
    GOTO    SCAN_TEMP1_1
    BTFSS   PORTB, 2
    GOTO    SCAN_TEMP1_2
    GOTO    SCAN_TEMP1_3

    SCAN_TEMP1_0
    
    BANKSEL SCAN_SWITCH_INDEX
    MOVLW   .1
    MOVWF   SCAN_SWITCH_INDEX
    GOTO    SCAN_RETURN
    SCAN_TEMP1_1
    MOVLW   .2
    MOVWF   SCAN_SWITCH_INDEX
    GOTO    SCAN_RETURN
    SCAN_TEMP1_2
    MOVLW   .3
    MOVWF   SCAN_SWITCH_INDEX
    GOTO    SCAN_RETURN
    SCAN_TEMP1_3
    MOVLW   .4
    MOVWF   SCAN_SWITCH_INDEX
    GOTO    SCAN_RETURN
    
    MODEL1_STEP2

    BANKSEL PORTB
    BTFSS   PORTB, 0
    GOTO    SCAN_TEMP2_0
    BTFSS   PORTB, 1
    GOTO    SCAN_TEMP2_1
    GOTO    SCAN_TEMP2_2
    
    SCAN_TEMP2_0

    BANKSEL SCAN_SWITCH_INDEX
    MOVLW   .5
    MOVWF   SCAN_SWITCH_INDEX
    GOTO    SCAN_RETURN
    SCAN_TEMP2_1
    MOVLW   .6
    MOVWF   SCAN_SWITCH_INDEX
    GOTO    SCAN_RETURN
    SCAN_TEMP2_2
    MOVLW   .7
    MOVWF   SCAN_SWITCH_INDEX
    GOTO    SCAN_RETURN
    
    MODEL1_STEP3
    
    BANKSEL PORTB
    BTFSS   PORTB, 0
    GOTO    SCAN_TEMP3_0
    GOTO    SCAN_TEMP3_1
    SCAN_TEMP3_0
    
    BANKSEL SCAN_SWITCH_INDEX
    MOVLW   .8
    MOVWF   SCAN_SWITCH_INDEX
    GOTO    SCAN_RETURN
    SCAN_TEMP3_1
    MOVLW   .9
    MOVWF   SCAN_SWITCH_INDEX
    GOTO    SCAN_RETURN
    
    MODEL1_STEP4
    BANKSEL SCAN_SWITCH_INDEX
    MOVLW   .10
    MOVWF   SCAN_SWITCH_INDEX
    GOTO    SCAN_RETURN
    
    MODEL2
    BANKSEL SCAN_SWITCH_INDEX
    MOVLW   .0
    MOVWF   SCAN_SWITCH_INDEX
    GOTO SCAN_RETURN
    
    SCAN_RETURN
    RETURN
    
    SCAN_HELP:
    BANKSEL PORTB
    MOVF    PORTB, W
    BANKSEL SCAN_TMP
    MOVWF   SCAN_TMP
    BANKSEL TRISB
    MOVF    TRISB, W
    BANKSEL SCAN_IN
    MOVWF   SCAN_IN
    RETURN
    
    SWITCH_TEST:
    MOVLW   .2
    MOVWF   SCAN_SWITCH_INDEX
    RETURN
   
    END