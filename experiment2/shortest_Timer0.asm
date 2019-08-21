    #INCLUDE p16f1786.inc
    __CONFIG _CONFIG1, _FOSC_ECH & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _CLKOUTEN_OFF & _IESO_ON & _FCMEN_ON
    __CONFIG _CONFIG2, _WRT_OFF & _VCAPEN_OFF & _PLLEN_ON & _STVREN_ON & _BORV_LO & _LPBOR_OFF & _LVP_ON
    udata_shr    
    TIME_COUNT res .8
    org 0 
        CLRF TMR0
        BANKSEL OPTION_REG 
        MOVLW B'00000111'
        MOVWF OPTION_REG 
        
        MOVLW B'01101000' ;set Oscillating frequency to 4MHZ
        MOVWF OSCCON  ;

        MOVLW B'00000000'
        MOVWF TRISA
        
        LP
        BTFSS INTCON,2 
        GOTO LP
        GOTO LED

        LED
        BCF INTCON,2
        DECFSZ TIME_COUNT,1
        GOTO LP
        MOVLW .8
        MOVWF TIME_COUNT

        BANKSEL PORTA
        COMF PORTA,1 
        MOVLW B'01010111'
        MOVWF TMR0 
        GOTO LP
    END
