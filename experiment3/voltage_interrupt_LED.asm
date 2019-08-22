#INCLUDE p16f1786.inc
 __CONFIG _CONFIG1, _FOSC_ECH & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _CLKOUTEN_OFF & _IESO_ON & _FCMEN_ON
 __CONFIG _CONFIG2, _WRT_OFF & _VCAPEN_OFF & _PLLEN_ON & _STVREN_ON & _BORV_LO & _LPBOR_OFF & _LVP_ON
CONTEXT_SAVING UDATA_SHR

W_TMP RES 1
S_TMP RES 1
delayvar1 EQU .10
delayvar2 EQU .10
 
RES_VECT  CODE    0x0000            ; processor reset vector
GOTO    START                   ; go to beginning of program
MAIN_PROG CODE                      ; let linker place main program
 
ISR CODE 0X04;interrupt code address
MOVWF W_TMP
SWAPF STATUS,W
MOVWF S_TMP
;interrupt code
BANKSEL IOCBF
BCF IOCBF,5 ;CLEAN RB5 target_bit
 
BANKSEL PORTA
COMF PORTA,1 ;invert PortA
;CALL delayloop;delay for a while
 
;interrupt code
SWAPF S_TMP,W
MOVWF STATUS
SWAPF W_TMP,F
SWAPF W_TMP,W
RETFIE


; TODO ADD INTERRUPTS HERE IF USED   
;MAIN_PROG CODE 0X0                     ; let linker place main program

START
NOP
BANKSEL TRISC
MOVLW B'11110111'
MOVWF TRISC
BANKSEL PORTC
MOVLW B'00000000'
MOVWF PORTC 
;XORWF PORTC,F;check wether program is running
 
BANKSEL OSCCON
MOVLW B'01101000'
MOVWF OSCCON;osc frequency = 4MHZ
 
BANKSEL ANSELA
CLRF ANSELA
BANKSEL TRISA;BANK1
MOVLW B'00000000'
MOVWF TRISA
BANKSEL PORTA
CLRF PORTA;initialise PortA
 
BANKSEL INTCON
MOVLW B'11011000'
MOVWF INTCON;enable voltage interrupt 
 
BANKSEL IOCBN
MOVLW B'00100000'
MOVWF IOCBN;falling edge 

BANKSEL TRISB;BANK1
MOVLW B'11111111'
MOVWF TRISB 
BANKSEL ANSELB
CLRF ANSELB
BANKSEL PORTB
CLRF PORTB;initialise PortB
 
LP
 NOP
GOTO LP
   

delayloop
    decfsz delayvar1, f
    goto delayloop
    decfsz delayvar2, f
    goto delayloop
    return
END