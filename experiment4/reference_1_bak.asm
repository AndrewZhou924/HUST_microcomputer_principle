#INCLUDE p16f1786.inc
; __config _CONFIG1, _LP_OSC & _PWRTE_OFF & _WDT_OFF & _CP_OFF
 __CONFIG _CONFIG1, _FOSC_ECH & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _CLKOUTEN_OFF & _IESO_ON & _FCMEN_ON
 __CONFIG _CONFIG2, _WRT_OFF & _VCAPEN_OFF & _PLLEN_ON & _STVREN_ON & _BORV_LO & _LPBOR_OFF & _LVP_ON

CONTEXT_SAVING UDATA_SHR
W_TMP RES 1
S_TMP RES 1
OFFSET RES 1
COFFSET RES 1
NUM RES 1
CNUM RES 1
PA RES 1
CNT RES 1
LP0 RES 1
LP1 RES 1
ISBLACK RES 1

RES_VECT CODE 0x0000
GOTO START                 ; go to beginning of program
MAIN_PROG CODE 

ISR CODE 0x04 ;电平变化中断的作用则是重新选择字符
 ;interrupt code
MOVWF W_TMP
SWAPF STATUS,W
MOVWF S_TMP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PB_INT
;BTFSC INTCON,RBIF
BTFSC INTCON,IOCIF
CALL PORTB_INT
TM0_INT
BTFSC INTCON,T0IF
CALL TMR0_INT;;;;;;;;;;;;;;;;;;;;;
;COMF ISBLACK
;BTFSS ISBLACK,0
;CALL DECRESE_COFFSET
;NOP
;BTFSC ISBLACK,0
CALL BLACK
BANKSEL INTCON
BCF INTCON,2 ;;;;;;;;;;;;;清除TMR0中断标志位
BANKSEL TMR0
MOVLW B'01111111'
MOVWF TMR0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
SWAPF S_TMP,W
MOVWF STATUS
SWAPF W_TMP,F
SWAPF W_TMP,W
RETFIE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

START
BANKSEL TMR0
MOVLW B'01111111'
MOVWF TMR0

BANKSEL OPTION_REG
MOVLW B'00000111'
MOVWF OPTION_REG ;;;;;;;;;;;;;;;;;;;;;TMR0设置为256分频

BANKSEL INTCON
BSF INTCON,GIE
BSF INTCON,T0IE ;;;;;;;;;;;;;;;;;;;;;总中断使能，TMR0中断使能
 
;BSF INTCON,RBIE;;;;;;;;;;;;;;;;;;;;;;PORTB电平变化中断使能
BANKSEL IOCBN
MOVLW B'00100000'
MOVWF IOCBN;falling edge 

BANKSEL TRISC
CLRF TRISC
BANKSEL PORTC
MOVLW B'11111111'
MOVWF PORTC
BANKSEL TRISA
CLRF TRISA
BANKSEL PORTA
CLRF PORTA
BANKSEL ANSELA
CLRF ANSELA
BANKSEL TRISB
MOVLW B'00100000'
MOVWF TRISB
;??????????
;BANKSEL IOCB
;MOVLW B'00100000'
;MOVWF IOCB
;???????????
BANKSEL PORTB
CLRF PORTB
BANKSEL WPUB
MOVLW B'00100000'
MOVWF WPUB

BANKSEL OSCCON
MOVLW B'00010011'
MOVWF OSCCON ;;;;;;;;;;;;;;;;;;;;;;振荡器设置为125KHz，内部振荡器

BANKSEL COFFSET
MOVLW D'22'
MOVWF COFFSET;;;;;;;;;;;;;;;;;;;;10个数字

BANKSEL CNUM
MOVLW D'1'
MOVWF CNUM;;;;;;;;;;;;;;;;;;;;;;;;;4个数码管

MOVF COFFSET,W
MOVWF PA;;;;;;;;;;;;;;;;;;;;;;;;;;;PA暂时存储COFFSET

MOVLW D'4'
MOVWF CNT;;;;;;;;;;;;;;;;;;;;;;;;;;计数四次

CLRF ISBLACK

PAGESEL MAIN
GOTO MAIN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;这里是函数区;;;;;;;;;;;;;;;;;
SELECT:
BANKSEL PORTA
CLRF PORTA
BANKSEL PORTC
MOVLW B'11111111'
MOVWF PORTC
MOVLW LOW STABLE ;获得TABLE的低8位
ADDWF NUM,F;TABLE值加上偏移量
MOVLW HIGH STABLE;获得TABLE的高5位
BTFSC STATUS,C;检测是否翻页
ADDLW 1;翻页则在TABLE的高5位加一
MOVWF PCLATH;将TABLE的高5位写入PCLATH
MOVF NUM,W;将需要调用的信号的地址写入W
CALL STABLE;
MOVWF PORTC
RETURN

STABLE:
MOVWF PCL;转到偏移的地址
RETLW B'11111110';1
RETLW B'11111101';2
RETLW B'11111011';3
RETLW B'11110111';4

WRITE:
MOVLW LOW TABLE ;获得TABLE的低8位
ADDWF OFFSET,F;TABLE值加上偏移量
MOVLW HIGH TABLE;获得TABLE的高5位
BTFSC STATUS,C;检测是否翻页
ADDLW 1;翻页则在TABLE的高5位加一
MOVWF PCLATH;将TABLE的高5位写入PCLATH
MOVF OFFSET,W;将需要调用的信号的地址写入W
CALL TABLE;
MOVWF PORTA
RETURN

TABLE: ;列表
MOVWF PCL;转到偏移的地址
RETLW B'01101111';9
RETLW B'01111111';8
RETLW B'00000111';7
RETLW B'01111101';6
RETLW B'01101101';5
RETLW B'01100110';4
RETLW B'01001111';3
RETLW B'01011011';2
RETLW B'00000110';1
RETLW B'00111111';0
RETLW B'00000000';NULL——11
RETLW B'00000000';NULL——12
RETLW B'00000000';NULL——13
RETLW B'00000000';NULL——14
RETLW B'01011110';d——15
RETLW B'01111001';E——16
RETLW B'01111001';E————17
RETLW B'01101101';S——18
RETLW B'00000000';NULL——19
RETLW B'00000000';NULL——20
RETLW B'00000000';NULL——21
RETLW B'00000000';NULL——22

SETORIGIN:
MOVLW D'1'
MOVWF CNUM
MOVLW D'4'
MOVWF CNT
MOVF COFFSET,W
MOVWF PA
RETURN

SETPA:
MOVLW D'10'
MOVWF PA
RETURN

SETCOFFSET:
MOVLW D'10'
MOVWF COFFSET
RETURN

DELAY: 
MOVLW 01FH
MOVWF LP0
L0 MOVLW 01FH
MOVWF LP1
L1 DECFSZ LP1,F
GOTO L1
DECFSZ LP0,F
GOTO L0
RETURN

DECRESE_COFFSET:
DECF COFFSET
BTFSC STATUS,Z
CALL SETCOFFSET
RETURN

BLACK:
BANKSEL PORTA
CLRF PORTA
CALL DELAY
RETURN

TMR0_INT:
DECF COFFSET
BTFSC STATUS,Z
CALL SETCOFFSET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;COFFSET减一
RETURN

PORTB_INT:
BANKSEL PORTB
BCF PORTB,4
BANKSEL INTCON
;BCF INTCON,RBIF;;;;;;;;;;;;;;;;;;;;;;;;;;PORTB中断标志清除
BCF INTCON,IOCIF;;;;;;;;;;;;;;;;;;;;;;;;;;PORTB中断标志清除    
MOVLW D'10'
MOVWF COFFSET

RETURN
;;;;;;;;;;函数区到此为止;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MAIN
LOOP
MOVF CNUM,W
MOVWF NUM;数码管 CNUM => NUM
MOVF PA,W
MOVWF OFFSET;图案 PA => OFFSET

CALL SELECT;;;;;;;;;;;;;;;;;;;;;;;;;数码管
CALL WRITE;;;;;;;;;;;;;;;;;;;;;;;;;;图案

DECF PA
BTFSC STATUS,Z;;;;;;;;;;;;;;;;;;;;;;
CALL SETPA;;;;;;;;;;;;;;;;;;;;;;;;;;

INCF CNUM

DECF CNT
BTFSC STATUS,Z
CALL SETORIGIN

GOTO LOOP
END