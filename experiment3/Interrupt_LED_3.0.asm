#INCLUDE p16f1786.inc
 __CONFIG _CONFIG1, _FOSC_ECH & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _CLKOUTEN_OFF & _IESO_ON & _FCMEN_ON
 __CONFIG _CONFIG2, _WRT_OFF & _VCAPEN_OFF & _PLLEN_ON & _STVREN_ON & _BORV_LO & _LPBOR_OFF & _LVP_ON
CONTEXT_SAVING UDATA_SHR

 
RES_VECT  CODE    0x0000            ; processor reset vector
GOTO    START                   ; go to beginning of program
MAIN_PROG CODE                      ; let linker place main program
 
ISR CODE 0X04 ;interrupt code address
;interrupt code
BCF INTCON,2 ;??TMR0?????
BANKSEL PORTA
COMF PORTA,1 ;invert PortA 
MOVLW B'00001100'
MOVWF TMR0 ;????
RETFIE

;MAIN CODE
START

BANKSEL OPTION_REG
MOVLW B'00000111'
MOVWF OPTION_REG ;;;;;;;;;;;;;;;;;;;;;TMR0???16??
 
MOVLW B'01010011'
MOVWF OSCCON ;;;;;;;;;;;;;;;;;;;;;;??????310KHz??????
 
BANKSEL TMR0
MOVLW B'00000000'
MOVWF TMR0 ;;;;;;;;;;;;;;;;;;;;;;;TMR0???
 
BSF INTCON,GIE
BSF INTCON,T0IE ;;;;;;;;;;;;;;;;;;;;;??????TMR0????
 
BANKSEL ANSELA
CLRF ANSELA
 
BANKSEL TRISA;
MOVLW B'00000000'
MOVWF TRISA
BANKSEL PORTA
CLRF PORTA ;;;;;;;;;;;;;;;;;;;;;??PORTA???
LP
 NOP
GOTO LP
END