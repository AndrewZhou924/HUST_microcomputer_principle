;#include <p16f1786.inc>
; LIST
; __CONFIG _CONFIG1, _FOSC_ECH & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _CLKOUTEN_OFF & _IESO_ON & _FCMEN_ON
;; CONFIG2
;; __config 0xFFFF
; __CONFIG _CONFIG2, _WRT_OFF & _VCAPEN_OFF & _PLLEN_ON & _STVREN_ON & _BORV_LO & _LPBOR_OFF & _LVP_ON
; 
;rst code 0x0
; pagesel main
; goto main
; 
;ONE equ b'00110001'
;TWO equ b'00110010'
;THREE equ b'00110011'
;FOUR equ b'00110100'
; 
;;ONE equ 0x7E
;;TWO equ 0xA2
;;THREE equ 0x62
;;FOUR equ 0x74
; 
;isr code 0x04
; 
; btfsc INTCON,2
; call one_isr 
; retfie
; 
;timer0_isr
; banksel LATA
; movlw 0x01
; xorwf LATA
;; banksel TMR0
;; movlw 0x0c
;; movwf TMR0
;; bcf INTCON,2
; return
; 
;one_isr
; banksel LATB
; movlw ONE
; xorwf LATB
;; banksel TMR0
;; movlw 0x0c
;; movwf TMR0
;; bcf INTCON,2
; return
; 
; two_isr
; banksel LATB
; movlw TWO
; xorwf LATB
;; banksel TMR0
;; movlw 0x0c
;; movwf TMR0
;; bcf INTCON,2
; return
; 
; three_isr
; banksel LATB
; movlw THREE
; xorwf LATB
;; banksel TMR0
;; movlw 0x0c
;; movwf TMR0
;; bcf INTCON,2
; return
; 
; four_isr
; banksel LATA
; movlw FOUR
; xorwf LATA
; banksel TMR0
; movlw 0x0c
; movwf TMR0
; bcf INTCON,2
; return
; 
;main
; nop
; ;init PORTA
; banksel TRISA
; clrf TRISA
; banksel ANSELA
; clrf ANSELA
; banksel LATA
; movlw 0xff
; movwf LATA
;
; ;init PORTB
; banksel TRISB
; clrf TRISB
; banksel ANSELB
; clrf ANSELB
; banksel LATB
; movlw 0xff
; movwf LATB
; 
; banksel INTCON  
; movlw b'10100000'
; movwf INTCON
;
; BANKSEL OPTION_REG
; movlw 0x07
; movwf OPTION_REG
;
; call one_isr
; 
;delay
; nop
; goto delay
;
; GOTO $ ; loop forever
; END
    
#include <p16f1786.inc>
 LIST
 __CONFIG _CONFIG1, _FOSC_ECH & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _CLKOUTEN_OFF & _IESO_ON & _FCMEN_ON
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _WRT_OFF & _VCAPEN_OFF & _PLLEN_ON & _STVREN_ON & _BORV_LO & _LPBOR_OFF & _LVP_ON
 
rst code 0x0
 pagesel main
 goto main
 
ONE equ b'00110001'  ;
TWO equ b'00110010'
THREE equ b'00110011'
FOUR equ b'00110100'

isr code 0x04
 
 banksel LATA
 BTFSS LATA, 4   ;dump if 0
 call one_isr
 
 BTFSS LATA, 5
 call two_isr
 
 BTFSS LATA, 6
 call three_isr
 
 BTFSS LATA, 7
 call four_isr
 
 
 banksel INTCON
 bcf INTCON,2
 
 banksel TMR0
 movlw 0x0c
 movwf TMR0
 
retfie 
  
one_isr
 banksel LATB
 clrf LATB
 movlw ONE
 IORWF LATB, f
 
 banksel LATA
 LSLF LATA, 1
 return

two_isr
 banksel LATB
 clrf LATB
 movlw TWO
 IORWF LATB, f
 
 banksel LATA
 LSLF LATA, 1
 return

three_isr
 banksel LATB
 clrf LATB
 movlw THREE
 IORWF LATB, f
 
 banksel LATA
 LSLF LATA, 1
 return
 
four_isr
 banksel LATB
 clrf LATB
 movlw FOUR
 IORWF LATB, f
 
 banksel LATA
 movlw b'11101111'
 movwf LATA
 return
 
main
 nop
 banksel TRISA
 movlw 0x00
 movwf TRISA
 BANKSEL LATA
 MOVLW 0x00
 movwf LATA
 
 banksel TRISB
 movlw 0x00
 movwf TRISB
 BANKSEL LATB
 MOVLW 0x00
 movwf LATB
 
 banksel INTCON  
 movlw b'11111000'   
 movwf INTCON

 BANKSEL OPTION_REG   
 movlw 0x07
 movwf OPTION_REG
 
 banksel LATA
 movlw b'00010000'
 movwf LATA
 
 banksel LATB
 movlw b'00000000'
 movwf LATB
 
delay
 nop
 goto delay

 GOTO $ ; loop forever
 END

    
    
    
    
    
    
