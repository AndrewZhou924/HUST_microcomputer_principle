; TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR
#INCLUDE p16f1786.inc
 __CONFIG _CONFIG1, _FOSC_ECH & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _CLKOUTEN_OFF & _IESO_ON & _FCMEN_ON
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _WRT_OFF & _VCAPEN_OFF & _PLLEN_ON & _STVREN_ON & _BORV_LO & _LPBOR_OFF & _LVP_ON

udata_shr    
D1    res 1h               ;????
D2    res 1h
D3    res 1h
RES_VECT  CODE    0x0000            ; processor reset vector
   GOTO    START                   ; go to beginning of program

; TODO ADD INTERRUPTS HERE IF USED

MAIN_PROG CODE                      ; let linker place main program

START
     NOP
     BANKSEL  PORTA       ;??PORTA???bank
     CLRF     PORTA       ;?PORTA????
     BANKSEL  ANSELA       ;????PORTA???????
     CLRF     ANSELA       ;??PORTA?????????????0??????1??????
     BANKSEL  TRISA       ;??PORTA??????????
     CLRF   TRISA
     MOVLW    B'00000000' 
     MOVWF    TRISA       ;??????? 
    LOOP 
	MOVLW 1H
	MOVWF D1
	MOVLW 1H
	MOVWF D2
	MOVLW 1H
	MOVWF D3
      MOVLW 01H            ;?01H?W
      XORWF PORTA,f        ;??RA0??LED????RA0??LED
      CALL DELAY           ;??0?2S????
      GOTO LOOP            ;??????
;-------------------------------------???0?2S?????
    DELAY                         
	    MOVLW 2           
	    MOVWF D1        
	DELAY_1
	    MOVLW 60     
	    MOVWF D2      
	DELAY_2
	    MOVLW 60       
	    MOVWF D3       
	DELAY_3
	    DECFSZ D3,1        
	    GOTO DELAY_3      
	    DECFSZ D2,1         
	    GOTO DELAY_2        
	    DECFSZ D1,1         
	    GOTO DELAY_1        
    RETURN            ;?????

	    END               ; ????????
