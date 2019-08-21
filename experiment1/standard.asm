RST code 0x0
    pagesel main
    goto main
    code
main
    movlw b'01111111'
    banksel TRISC
    movwf TRISC
loop
    banksel PORTC
    movlw 0x80
    xorwf PORTC, f
delayloop
    decfsz delayvar1, f
    goto delayloop
    decfsz delayvar2, f
    goto delayloop
    goto loop
end