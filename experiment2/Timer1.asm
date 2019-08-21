#INCLUDE p16f1786.inc
; __config _CONFIG1, _LP_OSC & _PWRTE_OFF & _WDT_OFF & _CP_OFF
 __CONFIG _CONFIG1, _FOSC_ECH & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _CLKOUTEN_OFF & _IESO_ON & _FCMEN_ON
 __CONFIG _CONFIG2, _WRT_OFF & _VCAPEN_OFF & _PLLEN_ON & _STVREN_ON & _BORV_LO & _LPBOR_OFF & _LVP_ON

 
RES_VECT  CODE    0x0000            ; processor reset vector
   GOTO    START                   ; go to beginning of program
MAIN_PROG CODE                      ; let linker place main program
START
    NOP
    CLRF TMR1
    BANKSEL T1CON 
    MOVLW B'00110001'
    MOVWF T1CON;1:8

    BANKSEL PIR1;
    MOVLW B'00000000'
    MOVWF PIR1;PIR1_BIT0 target bit

    BANKSEL OSCCON
    MOVLW B'01101000' ;4MHZ
    MOVWF OSCCON  ;

    BANKSEL ANSELA;initialize portA
    CLRF ANSELA
    BANKSEL TRISA;BANK1
    MOVLW B'00000000'
    MOVWF TRISA
    
    LP
    BANKSEL PIR1
    BTFSS PIR1,0 ;judge target bit
    GOTO LP
    GOTO LED

    LED
    BCF PIR1,0 ;clean target bit
    BANKSEL INTCON
    BANKSEL PORTA
    COMF PORTA,1 ;invert LED
    
    BANKSEL TMR1H
    MOVLW B'00001011'
    MOVWF TMR1H ;TMR1H Value
    BANKSEL TMR1L
    MOVLW B'11011100'
    MOVWF TMR1L ;TMR1L Value
    GOTO LP
END
