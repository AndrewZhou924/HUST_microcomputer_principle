#include<p16f883.inc>

; origin : https://my.oschina.net/u/185037/blog/64800

__CONFIG    _CONFIG1, _LVP_OFF & _FCMEN_ON & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_ON & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT

__CONFIG    _CONFIG2, _WRT_OFF & _BOR21V

 

udata_shr

counter res 1 ;计数个位

counter0 res 1 ;计数十位

counter1 res 1 ;扫描按键变量

counter2 res 1 ;延时程序微调参数

key_state res 1 ;按键状态

keynum res 1 ;按键标号

swap res 1 ;确认按键转换值

keypress res 1

keypressbak res 1

keyrelease res 1

LED1 res 1

LED2 res 1

LED3 res 1

LED4 res 1

    UDATA

counter3 res 1

counter4 res 1

sign res 1

 

reset code 0x0000

pagesel start

goto start

 

;int_vector code 0x0004

code

start

banksel ANSEL ;设置PORTA为数字模式

clrf ANSEL

banksel ANSELH ;设置PORTB为数字模式

clrf ANSELH

banksel TRISB ;设置PORTB为输入模式

movlw b'11111111'

movwf TRISB

banksel WPUB ;设置PORTB弱上拉

movlw b'11111111'

movwf WPUB

banksel OPTION_REG

movlw b'01000101' ;TMR0 64分频

movwf OPTION_REG

banksel T1CON

movlw b'10010001' ;打开TMR1，设置1:8预分频，内部时钟源1:4分频

movwf T1CON

banksel TRISA ;设置PORTA<3:0>为输出，接数码管的共阴极

movlw b'11110000'

movwf TRISA

banksel PORTA

clrf PORTA

banksel TRISC

movlw b'00000000' ;设置PORTC为输出，接8段数码管

movwf TRISC

clrf counter1

 

loop

movlw HIGH Table1

movwf PCLATH

movf counter1,0

call Table1

banksel TRISB

movwf TRISB

movf counter1,0

call Table1

banksel PORTB

movwf PORTB

movf PORTB,0

movwf key_state

movlw b'11001000'

iorwf key_state,1

movf counter1,0

call Table1

 

xorwf key_state,0

movwf swap

comf swap,1

incfsz swap,1

goto case1

 

incf counter1,1

movf counter1,0

call Table1

banksel TRISB

movwf TRISB

movf counter1,0

call Table1

banksel PORTB

movwf PORTB

movf PORTB,0 ;读取I/O状态

movwf key_state

movlw b'11001000'

iorwf key_state,1

movf counter1,0

call Table1

xorwf key_state,0

movwf swap

comf swap,1

incfsz swap,1

goto case2

 

incf counter1,1

movf counter1,0

call Table1

banksel TRISB

movwf TRISB

movf counter1,0

call Table1

banksel PORTB

movwf PORTB

movf PORTB,0 ;读取I/O状态

movwf key_state

movlw b'11001000'

iorwf key_state,1

movf counter1,0

call Table1

xorwf key_state,0

movwf swap

comf swap,1

incfsz swap,1

goto case3

 

incf counter1,1

movf counter1,0

call Table1

banksel TRISB

movwf TRISB

movf counter1,0

call Table1

banksel PORTB

movwf PORTB

movf PORTB,0 ;读取I/O状态

movwf key_state

movlw b'11001000'

iorwf key_state,1

movf counter1,0

call Table1

xorwf key_state,0

movwf swap

comf swap,1

incfsz swap,1

goto case4

goto continue

 

case1

btfsc key_state,4

goto key2

movlw d'1'

movwf keynum

call DealKeyPress

goto continue

key2

btfsc key_state,2

goto key3

movlw d'2'

movwf keynum

call DealKeyPress

goto continue

key3

btfsc key_state,1

goto key4

movlw d'3'

movwf keynum

call DealKeyPress

goto continue

key4

btfsc key_state,0

goto continue

movlw d'4'

movwf keynum

call DealKeyPress

goto continue

 

 

 

 

case2

;-------------------------------------------------

;下面代码实现K10\K8\K5的按键处理

btfsc key_state,2

goto key8

movlw d'10'

movwf keynum

call DealKeyPress

goto continue

;------------------------------------

;处理K8

key8

btfsc key_state,1

goto key5

movlw d'8'

movwf keynum

call DealKeyPress

goto continue

;------------------------------------

;处理K5

key5

btfsc key_state,0

goto case3

movlw d'5'

movwf keynum

call DealKeyPress

goto continue

 

case3

;----------------------------------

;处理K6/K9

btfsc key_state,1

goto key6

movlw d'9'

movwf keynum

call DealKeyPress

goto continue

key6

btfsc key_state,0

goto case4

movlw d'6'

movwf keynum

call DealKeyPress

goto continue

case4

;-----------------------------------------

;处理K7

btfsc key_state,0

goto continue

movlw d'7'

movwf keynum

call DealKeyPress

 

continue

call display

clrf counter1

goto loop

 

 

;-----------------------------------

;按键去抖，约8mS

delay

movlw d'4'

movwf counter2

LOOP2

banksel TMR0

clrf TMR0

LOOP1

banksel INTCON

btfss INTCON,T0IF

goto LOOP1

bcf INTCON,T0IF

decfsz counter2,1

goto LOOP2

return

 

delay2

incfsz counter3,1

goto delay2

return

 

;--------------------------------

;按键处理程序

;

DealKeyPress

clrf LED1

clrf LED2

clrf LED3

clrf LED4

call delay

 

banksel TMR1H

clrf TMR1H

banksel TMR1L

clrf TMR1L

clrf keypress

presstime

banksel PIR1

btfss PIR1,TMR1IF

goto next

bcf PIR1,TMR1IF

incf keypress

movlw d'2'

subwf keypress,0

banksel STATUS

btfsc STATUS,C

goto longpress

next

movf counter1,0

call Table1

banksel TRISB

movwf TRISB

banksel PORTB

movwf PORTB

movf PORTB,0 ;读取I/O状态

movwf key_state

movlw b'11001000'

iorwf key_state,1

movf counter1,0

call Table1

xorwf key_state,0

movwf swap

comf swap,1

incfsz swap,1

goto presstime


call delay

 

banksel TMR1H

clrf TMR1H

banksel TMR1L

clrf TMR1L

clrf keyrelease

releasetime

banksel PIR1

btfss PIR1,TMR1IF

goto next1

bcf PIR1,TMR1IF

incf keyrelease

movlw d'1'

subwf keyrelease,0

banksel STATUS

btfsc STATUS,C

goto click

next1

movf counter1,0

call Table1

banksel TRISB

movwf TRISB

banksel PORTB

movwf PORTB

movf PORTB,0 ;读取I/O状态

movwf key_state

movlw b'11001000'

iorwf key_state,1

movf counter1,0

call Table1

xorwf key_state,0

movwf swap

comf swap,1

incfsz swap,1

goto over

goto releasetime

over

call delay

banksel TMR1H

clrf TMR1H

banksel TMR1L

clrf TMR1L

clrf keypress

presstime1

banksel PIR1

btfss PIR1,TMR1IF

goto next2

bcf PIR1,TMR1IF

incf keypress

movlw d'1'

subwf keypress,0

banksel STATUS

btfsc STATUS,C

goto click

next2

movf counter1,0

call Table1

banksel TRISB

movwf TRISB

banksel PORTB

movwf PORTB

movf PORTB,0 ;读取I/O状态

movwf key_state

movlw b'11001000'

iorwf key_state,1

movf counter1,0

call Table1

xorwf key_state,0

movwf swap

comf swap,1

incfsz swap,1

goto presstime1

movf keynum,0                    ;双击

movwf LED1

movlw d'10'

movwf LED2

incf counter

goto back

longpress                         ;长按

movf keynum,0

movwf LED2

movlw d'10'

movwf LED1

goto back

click                         ;单击

movf keynum,0

movwf LED1

movwf LED2

 

back

call CountNum

return

 

;----------------------------

;按键计数

;

 

CountNum

movlw d'9'

subwf counter,0

banksel STATUS

btfsc STATUS,C

goto add

incf counter

goto over1

add

incf counter0

clrf counter

movlw d'10'

subwf counter0,0

banksel STATUS

btfsc STATUS,C

goto clear

goto over1

clear

clrf counter0

over1

movf counter,0

movwf LED4

movf counter0,0

movwf LED3

return

 

 

 

 

;--------------------------------

;显示数码管

;

display

 

banksel PORTA

movlw b'11111110'

movwf PORTA

movf LED1,0

call Table3

banksel PORTC

movwf PORTC

call delay2

 

banksel PORTA

movlw b'11111101'

movwf PORTA

movf LED2,0

call Table3

banksel PORTC

movwf PORTC

call delay2

 

banksel PORTA

movlw b'11111011'

movwf PORTA

movf LED3,0

call Table3

banksel PORTC

movwf PORTC

call delay2

 

banksel PORTA

movlw b'11110111'

movwf PORTA

movf LED4,0

call Table3

banksel PORTC

movwf PORTC

call delay2

return

;----------------------

;Table真值表

;

Table1 ;PORTB、TRISB扫描配置信息

    ADDWF   PCL,f

    RETLW   B'11111111' 

    RETLW   B'11101111'

    RETLW   B'11111011'

    RETLW   B'11111101'

     

Table3 ;PORTC设置，数码管真值表

    ADDWF   PCL,f

; RETLW B'01001001' ;三条横线

    RETLW   B'10111111' ;0

    RETLW   B'00000110' ;1

    RETLW   B'01011011' ;2

    RETLW   B'01001111' ;3

    RETLW   B'01100110' ;4

    RETLW   B'01101101' ;5

    RETLW   B'01111101' ;6

    RETLW   B'00000111' ;7

    RETLW   B'01111111' ;8

    RETLW   B'01101111' ;9

RETLW B'00000000' ;黑屏

end