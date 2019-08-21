#INCLUDE p16f1786.inc
; __config _CONFIG1, _LP_OSC & _PWRTE_OFF & _WDT_OFF & _CP_OFF
 __CONFIG _CONFIG1, _FOSC_ECH & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _CLKOUTEN_OFF & _IESO_ON & _FCMEN_ON
 __CONFIG _CONFIG2, _WRT_OFF & _VCAPEN_OFF & _PLLEN_ON & _STVREN_ON & _BORV_LO & _LPBOR_OFF & _LVP_ON

udata_shr    
TIME_COUNT res 8  
 
RES_VECT  CODE    0x0000            ; processor reset vector
   GOTO    START                   ; go to beginning of program
MAIN_PROG CODE                      ; let linker place main program
START
    NOP
    CLRF TMR0
    BANKSEL OPTION_REG 
    MOVLW B'00000111'
    MOVWF OPTION_REG  ;256??

    BANKSEL INTCON;
    MOVLW B'00000111'
    ANDWF INTCON,F ;INTCON bit2?TMR0IF????????

    BANKSEL OSCCON
    MOVLW B'01101000' ;4MHZ??
    MOVWF OSCCON  ;

    BANKSEL ANSELA   ;??A???
    CLRF ANSELA
    BANKSEL TRISA;BANK1
    MOVLW B'00000000'
    MOVWF TRISA
    
    LP
    BANKSEL INTCON
    BTFSS INTCON,2 ;BTFSS???????INTCON?bit2?0????????????1??????????
    GOTO LP
    GOTO LED

    LED
    BCF INTCON,2 ;?????
    DECFSZ TIME_COUNT,1
    GOTO LP
    MOVLW 8
    MOVWF TIME_COUNT
    BANKSEL INTCON
    BANKSEL PORTA
    COMF PORTA,1 ;?????LED?
    
    BANKSEL TMR0
    MOVLW B'00111100'
    MOVWF TMR0 ;????
    GOTO LP
END
