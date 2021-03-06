#INCLUDE p16f1786.inc  
__CONFIG _CONFIG1, _FOSC_ECH & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _CLKOUTEN_OFF & _IESO_ON & _FCMEN_ON
 __CONFIG _CONFIG2, _WRT_OFF & _VCAPEN_OFF & _PLLEN_ON & _STVREN_ON & _BORV_LO & _LPBOR_OFF & _LVP_ON
 
UDATA_SHR
OFFSET RES 1
COFFSET RES 1
NUM RES 1
CNUM RES 1
PA RES 1
CNT RES 1
DELAYTIME1 RES 1
DELAYTIME2 RES 1
DELAYTIME3 RES 1 
ISBLACK RES 1
ISPRESS RES 0
KEY_NUM RES 0
 
RES_VECT  CODE    0x0000            ; processor reset vector
GOTO    FIRST                   ; go to beginning of program
MAIN_PROG CODE                      ; let linker place main program

ISR CODE 0x04 ;所有中断代码
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TM0_INT;timer0中断执行程序 TODO 用TIMER0进行刷新
MOVF CNUM,W
MOVWF NUM;数码管
MOVF PA,W
MOVWF OFFSET;图案

;DRAW NUM
CALL SELECT;数码管
CALL WRITE;图案
 
DECF PA
BTFSC STATUS,Z;PA偏移量减一,若为零则重新赋值
CALL SETPA;
INCF CNUM
DECF CNT
BTFSC STATUS,Z
CALL SETORIGIN 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
 
BANKSEL INTCON
BCF INTCON,2 ;清除timer0的标志位，重新装入初值
BANKSEL TMR0
MOVLW B'11111100';装入timer0初值
MOVWF TMR0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
RETFIE;

CODE
FIRST;初始化单片机各个外设代码
;;;;;;;;;;;;;;;;;;;;开始初始化;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BANKSEL OPTION_REG
MOVLW B'00000111'
MOVWF OPTION_REG ;;;;;;;;;;;;;;;;;;;;;TMR0设置为256分频
CLRF TMR1
BANKSEL T1CON 
MOVLW B'00110001'
MOVWF T1CON;1:8

BANKSEL PIR1;
MOVLW B'00000000'
MOVWF PIR1;PIR1_BIT0 target bit

BANKSEL TMR1H
MOVLW B'11111111'
MOVWF TMR1H ;TMR1H Value
BANKSEL TMR1L
MOVLW B'11110000'
MOVWF TMR1L ;TMR1L Value

BANKSEL TMR0
MOVLW B'00000000';装入timer0初值
MOVWF TMR0

BANKSEL INTCON
MOVLW B'11101000'
MOVWF INTCON;使能电平变化中断和总中断和TIMER0中断

BANKSEL TRISC
CLRF TRISC
BANKSEL PORTC
MOVLW B'11111111'
MOVWF PORTC;初始化端口C，将端口C设为输出模式
 
BANKSEL TRISA
CLRF TRISA
BANKSEL LATA
CLRF LATA
BANKSEL ANSELA
;CLRF ANSELA
MOVLW B'00000000'
MOVWF ANSELA

BANKSEL TRISB
MOVLW B'00100000'
MOVWF TRISB
;RB5为输入模式
BANKSEL IOCBN
MOVLW B'00100000'
MOVWF IOCBN
;RB5为下降沿触发
BANKSEL PORTB
CLRF PORTB
BANKSEL WPUB
MOVLW B'00100000'
MOVWF WPUB;弱上拉RB5，IO电平变化中断为RB5引脚触发

BANKSEL OSCCON
MOVLW B'01011000'
MOVWF OSCCON ;;;;;;;;;;;;;;;;;;;;;;振荡器设置为?KHZ，内部振荡器

BANKSEL COFFSET
MOVLW D'20'
MOVWF COFFSET;十个数字显示

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
;;;;;;;;;;;;;;;;;;;;结束初始化;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;函数区;;;;;;;;;;;;;;;;;
SELECT:
BANKSEL LATA
MOVLW B'00000000'
MOVWF  LATA
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
RETLW B'00000001';1
RETLW B'00000010';2
RETLW B'00000100';3
RETLW B'00001000';4    

WRITE:
MOVLW LOW TABLE ;获得TABLE的低8位
ADDWF OFFSET,F;TABLE值加上偏移量
MOVLW HIGH TABLE;获得TABLE的高5位
BTFSC STATUS,C;检测是否翻页
ADDLW 1;翻页则在TABLE的高5位加一
MOVWF PCLATH;将TABLE的高5位写入PCLATH
MOVF OFFSET,W;将需要调用的信号的地址写入W
CALL TABLE;
MOVWF LATA
RETURN

DELAY:
BANKSEL PIR1
BTFSS PIR1,0 ;judge target bit
GOTO DELAY
BANKSEL TMR1H
MOVLW B'00000000'
MOVWF TMR1H ;TMR1H Value
BANKSEL TMR1L
MOVLW B'00000000'
MOVWF TMR1L ;TMR1L Value
RETURN


TABLE:
MOVWF PCL;转到偏移的地址

RETLW B'11111111';NULL
RETLW B'11111111';NULL
RETLW B'11111111';NULL
RETLW B'11111001';1

RETLW B'11111111';NULL
RETLW B'11111111';NULL
RETLW B'11111111';NULL
RETLW B'10100100';2

RETLW B'11111111';NULL
RETLW B'11111111';NULL
RETLW B'11111111';NULL
RETLW B'10110000';3

RETLW B'11111111';NULL
RETLW B'11111111';NULL
RETLW B'11111111';NULL
RETLW B'10011001';4

RETLW B'11111111';NULL
RETLW B'11111111';NULL
RETLW B'11111111';NULL
RETLW B'10010010';5

RETLW B'11111111';NULL
RETLW B'11111111';NULL
RETLW B'11111111';NULL
RETLW B'10000010';6

RETLW B'11111111';NULL
RETLW B'11111111';NULL
RETLW B'11111111';NULL
RETLW B'11111000';7

RETLW B'11111111';NULL
RETLW B'11111111';NULL
RETLW B'11111111';NULL
RETLW B'10000000';8

RETLW B'11111111';NULL
RETLW B'11111111';NULL
RETLW B'11111111';NULL
RETLW B'10010000';9

RETLW B'11111111';NULL
RETLW B'11111111';NULL
RETLW B'11000000';NULL
RETLW B'11111001';10    

RETLW B'11111001';NULL
RETLW B'11111001';NULL
RETLW B'11111001';NULL
RETLW B'11111001';11 显示1111，表示单击    

RETLW B'10100100';NULL
RETLW B'10100100';NULL
RETLW B'10100100';NULL
RETLW B'10100100';12 显示2222，表示双击 
    
RETLW B'10110000';NULL
RETLW B'10110000';NULL
RETLW B'10110000';NULL
RETLW B'10110000';13 显示3333，表示长按     

SETORIGIN:
MOVLW D'1'
MOVWF CNUM
MOVLW D'4'
MOVWF CNT

MOVF COFFSET,W
MOVWF PA;注释这两行可以改变其显示值
RETURN

SETPA:
MOVLW D'10'
MOVWF PA
RETURN

;TODO set COFFSET through KEY_NUM
SETCOFFSET:
MOVLW D'10'
MOVWF COFFSET
RETURN

; 熄灭灯光 TODO ?
BLACK:
BANKSEL LATA
CLRF LATA
CALL DELAY ; TODO?
RETURN

; TODO 改为刷新而不是更换图案(COFFSET)
TMR0_INT:
BCF INTCON,TMR0IF
DECF COFFSET
BTFSC STATUS,Z
CALL SETCOFFSET ;COFFSET减一
RETURN

PORTB_INT:
BANKSEL PORTB
BCF PORTB,4
BANKSEL IOCBF
BCF IOCBF,5 ;;;;;;;;;;;;;;;;;;;;;;;;;;;PORTB中断标志清除
MOVLW D'10'
MOVWF COFFSET
RETURN
    
REFRESH_SHOW:
;TODO 根据KEY_VALUE计算COFFSET
MOVLW KEY_VALUE
ADDWF KEY_VALUE
ADDWF KEY_VALUE
ADDWF KEY_VALUE
MOVWF KEY_VALUE
BANKSEL COFFSET
MOVWF COFFSET;KEY_VALUE * 4      [1-10 + 3] * 4;十个数字显示

    
BANKSEL CNUM
MOVLW D'1'
MOVWF CNUM;;;;;;;;;;;;;;;;;;;;;;;;;4个数码管

MOVF COFFSET,W
MOVWF PA;;;;;;;;;;;;;;;;;;;;;;;;;;;PA暂时存储COFFSET

MOVLW D'4'
MOVWF CNT;;;;;;;;;;;;;;;;;;;;;;;;;;计数四次    
RETURN    
;;;;;;;;;;函数区到此为止;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



MAIN
LOOP
    
;;;;;;;;;;; change number ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;注：此函数不能每次循环都被使用，否则数码管无法正常显示图案    
;CALL REFRESH_SHOW
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   

GOTO LOOP
END