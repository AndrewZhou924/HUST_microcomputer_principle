; TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR
#INCLUDE p16f1786.inc

 __CONFIG _CONFIG1, _FOSC_ECH & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _CLKOUTEN_OFF & _IESO_ON & _FCMEN_ON
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _WRT_OFF & _VCAPEN_OFF & _PLLEN_ON & _STVREN_ON & _BORV_LO & _LPBOR_OFF & _LVP_ON
;外设使用说明：RA0-7用于显示数码管数字，RC0-3用于选择数码管位
;RB0-3用于读入键盘输入的值
;用timer1做10ms延时


udata_shr    
DELAYTIME1    res 1h               ;???
DELAYTIME2    res 1h
KEY_VALUE     RES 1H
KEY_VALUE_LAST     RES 1H
ISPRESS	    RES 1H
ISPRESS_LAST	   RES 1H
OFFSET	    RES 1
COFFSET	    RES 1
NUM	    RES 1
CNUM	    RES 1
PA	    RES 1
CNT	    RES 1
KEY_FLAG res 1
KEY_STATE res 1
STOP_WATCH res 1
 
RES_VECT  CODE    0x0000            ; processor reset vector
GOTO    INICIALISE                   ; go to beginning of program
MAIN_PROG CODE                      ; let linker place main program

; TODO ADD INTERRUPTS HERE IF USED

 
ISR CODE 0x04 ;所有中断代码
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BTFSC INTCON,2
GOTO TMR0_INT_ISR
NOP
 
BANKSEL INTCON
BCF INTCON,2 ;清除timer0的标志位，重新装入初值
BANKSEL TMR0
MOVLW B'11111100';装入timer0初值
MOVWF TMR0 
 
BTFSC PIR1,TMR1IF;
GOTO TMR1_INT_ISR
RETFIE
 
TMR1_INT_ISR
;;;;;;;;;;;;;;;;;;;;;;;
BANKSEL STOP_WATCH
MOVF STOP_WATCH,0 ; KEY_FLAG == 1，接着判断是否为单击，此处设置时间阈值T1
SUBLW .254
BTFSC STATUS,C
INCF STOP_WATCH ; C == 0, STOP_WATCH < T1,继续增加 STOP_WATCH
NOP C == 1, STOP_WATCH > T1，判为单击
 
BANKSEL PIR1
BCF PIR1,TMR1IF
BANKSEL TMR1H
MOVLW B'11110011'
MOVWF TMR1H ;TMR1H Value
BANKSEL TMR1L
MOVLW B'11000111'
MOVWF TMR1L ;TMR1L Value
;给timer1装入初值 
;;;;;;;;;;;;;;;;;;;;;;;
RETFIE
 
TMR0_INT_ISR
;;;;;;;;;;;;;;;;;;;;
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
 ;;;;;;;;;;;;;;;;;;;;
RETFIE
 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
RETFIE;中断返回
 
CODE
 INICIALISE;初始化代码
 BANKSEL OSCCON
 MOVLW B'01011000'
 MOVWF OSCCON ;设置震荡频率为1Mhz

 BANKSEL OPTION_REG
 MOVLW B'00000111'
 MOVWF OPTION_REG;允许全局弱上拉，设置timer0分频256
 
 BANKSEL PIE1
 MOVLW B'00000001'
 MOVWF PIE1;允许timer1中断
 
 CLRF TMR1
 BANKSEL T1CON 
 MOVLW B'00110001'
 MOVWF T1CON;设置分频比1：8

 BANKSEL PIR1;
 MOVLW B'00000000'
 MOVWF PIR1;清零timer1的标志位

 BANKSEL TMR1H
 MOVLW B'11110011'
 MOVWF TMR1H ;TMR1H Value
 BANKSEL TMR1L
 MOVLW B'11000111'
 MOVWF TMR1L ;TMR1L Value
 ;给timer1装入初值

 BANKSEL TMR0
 MOVLW B'00000000';装入timer0初值
 MOVWF TMR0

 BANKSEL INTCON
 MOVLW B'11101000'
 MOVWF INTCON;使能电平变化中断和总中断和TIMER0中断
 
 BANKSEL TRISA
 CLRF TRISA
 BANKSEL LATA
 CLRF LATA
 BANKSEL ANSELA
 ;CLRF ANSELA
 MOVLW B'00000000'
 MOVWF ANSELA;初始化端口a，端口a设置为输出方式

 BANKSEL TRISB
 MOVLW B'00000000'
 MOVWF TRISB
 BANKSEL LATB
 CLRF LATB
 
 BANKSEL ANSELB
 MOVLW B'00000000'
 MOVWF ANSELB;初始化端口b，端口b设置为输入方式
;端口b的输入输出模式会在键盘扫描过程中更改
 
BANKSEL WPUB
MOVLW B'11111111'
MOVWF WPUB;设置RB弱上拉
 
BANKSEL TRISC
CLRF TRISC
BANKSEL LATC
CLRF LATC;


MOVLW .0
MOVWF KEY_VALUE_LAST
MOVWF KEY_VALUE
MOVWF ISPRESS
MOVWF ISPRESS_LAST

BANKSEL COFFSET
MOVLW D'24'
MOVWF COFFSET;十个数字显示

BANKSEL CNUM
MOVLW D'1'
MOVWF CNUM;;;;;;;;;;;;;;;;;;;;;;;;;4个数码管

MOVF COFFSET,W
MOVWF PA;;;;;;;;;;;;;;;;;;;;;;;;;;;PA暂时存储COFFSET

MOVLW D'4'
MOVWF CNT;;;;;;;;;;;;;;;;;;;;;;;;;;计数四次
;初始化各标志变量
 
;;;;;;初始化专用变量;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BANKSEL KEY_VALUE  
MOVLW .0
MOVWF KEY_VALUE
 
BANKSEL KEY_VALUE_LAST
MOVLW .0
MOVWF KEY_VALUE_LAST

BANKSEL KEY_FLAG   
MOVLW .0
MOVWF KEY_FLAG
    
BANKSEL KEY_STATE
MOVLW .0
MOVWF KEY_STATE 
 
BANKSEL ISPRESS    
MOVLW .0
MOVWF ISPRESS    
 
BANKSEL ISPRESS_LAST   
MOVLW .0
MOVWF ISPRESS_LAST
    
BANKSEL STOP_WATCH
MOVLW .0
MOVWF STOP_WATCH   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
PAGESEL MAIN
GOTO MAIN;初始化完成后跳转执行主程序
 
;;;;;;;;;;;函数区;;;;;;;;;;;
KEYSCAN:

KEY_1:;第一轮扫描，得到7，8，9，10四个按键是否被按下
    BANKSEL TRISB;
    MOVLW B'11111111'
    MOVWF TRISB;设置RB0-RB3均为输入模式检测外部电平
    BANKSEL WPUB
    MOVLW B'11111111'
    MOVWF WPUB;设置RB弱上拉
    BANKSEL PORTB
    BTFSS PORTB,0;若检测到RB0为低电平
    CALL DELAY;延时消抖
    BTFSS PORTB,0;若检测到RB0为低电平
    GOTO KEY7;则7键被按下
    BTFSS PORTB,1;若检测到RB1为低电平
    CALL DELAY;延时消抖
    BTFSS PORTB,1;若检测到RB1为低电平
    GOTO KEY8;则8键被按下
    BTFSS PORTB,2;若检测到RB2为低电平
    CALL DELAY;延时消抖
    BTFSS PORTB,2;若检测到RB2为低电平
    GOTO KEY9;则9键被按下
    BTFSS PORTB,3;若检测到RB3为低电平
    CALL DELAY;延时消抖
    BTFSS PORTB,3;若检测到RB3为低电平
    GOTO KEY10;则10键被按下
   

	
KEY_2:;按键第二轮扫描，得到5，1，2三个按键的键值
    BANKSEL TRISB;
    MOVLW B'11111110'
    MOVWF TRISB;设置RB1-RB3均为输入模式检测外部电平，RB0为输出模式，输出低电平
    BANKSEL WPUB
    MOVLW B'11111110'
    MOVWF WPUB;设置RB弱上拉
    BANKSEL PORTB
    BTFSS PORTB,1;若检测到RB1为低电平
    CALL DELAY;延时消抖
    BTFSS PORTB,1;若检测到RB1为低电平
    GOTO KEY5;则5键被按下
    BTFSS PORTB,2;若检测到RB2为低电平
    CALL DELAY;延时消抖
    BTFSS PORTB,2;若检测到RB2为低电平
    GOTO KEY1;则1键被按下
    BTFSS PORTB,3;若检测到RB3为低电平
    CALL DELAY;延时消抖
    BTFSS PORTB,3;若检测到RB3为低电平
    GOTO KEY2;则1键被按下
    


KEY_3:;按键第三轮扫描，得到3，4按键的键值
    BANKSEL TRISB;
    MOVLW B'11111101'
    MOVWF TRISB;设置RB0，RB2,RB3均为输入模式检测外部电平，RB1为输出模式，输出低电平
    BANKSEL WPUB
    MOVLW B'11111101'
    MOVWF WPUB;设置RB弱上拉
    BANKSEL PORTB
    BTFSS PORTB,2;若检测到RB2为低电平
    CALL DELAY;延时消抖
    BTFSS PORTB,2;若检测到RB2为低电平
    GOTO KEY3;则3键被按下
    BTFSS PORTB,3;若检测到RB2为低电平
    CALL DELAY;延时消抖
    BTFSS PORTB,3;若检测到RB2为低电平
    GOTO KEY4;则4键被按下
    
   

KEY_4:;按键第四轮扫描，得到6按键的键值
    BANKSEL TRISB;
    MOVLW B'11111011'
    MOVWF TRISB;设置RB0，RB2,RB3均为输入模式检测外部电平，RB1为输出模式，输出低电平
    BANKSEL WPUB
    MOVLW B'11111011'
    MOVWF WPUB;设置RB弱上拉
    BANKSEL PORTB
    BTFSS PORTB,3;若检测到RB2为低电平
    CALL DELAY;延时消抖
    BTFSS PORTB,3;若检测到RB2为低电平
    GOTO KEY6;则3键被按下
    
BANKSEL KEY_VALUE_LAST
MOVF KEY_VALUE_LAST,0
BANKSEL KEY_VALUE
MOVWF KEY_VALUE
BANKSEL ISPRESS
CLRF ISPRESS;

RETURN
   
KEY7:
MOVLW .7
MOVWF KEY_VALUE
MOVLW .1
MOVWF ISPRESS

RETURN
KEY8:
MOVLW .8
MOVWF KEY_VALUE
MOVLW .1
MOVWF ISPRESS

RETURN
KEY9:
MOVLW .9
MOVWF KEY_VALUE
MOVLW .1
MOVWF ISPRESS

RETURN
KEY10:
MOVLW .10
MOVWF KEY_VALUE
MOVLW .1
MOVWF ISPRESS

RETURN   
KEY5:
MOVLW .5
MOVWF KEY_VALUE
MOVLW .1
MOVWF ISPRESS

RETURN
KEY1:
MOVLW .1
MOVWF KEY_VALUE
MOVLW .1
MOVWF ISPRESS

RETURN
KEY2:
MOVLW .2
MOVWF KEY_VALUE
MOVLW .1
MOVWF ISPRESS

RETURN    
KEY3:
MOVLW .3
MOVWF KEY_VALUE
MOVLW .1
MOVWF ISPRESS

RETURN
KEY4:
MOVLW .4
MOVWF KEY_VALUE
MOVLW .1
MOVWF ISPRESS

RETURN
KEY6:
MOVLW .6
MOVWF KEY_VALUE
MOVLW .1
MOVWF ISPRESS

RETURN
    
    
DELAY:                         
MOVLW .1          
MOVWF DELAYTIME1        
DELAY_1
MOVLW .5     
MOVWF DELAYTIME2      
DELAY_2      
DECFSZ DELAYTIME2,1         
GOTO DELAY_2        
DECFSZ DELAYTIME1,1         
GOTO DELAY_1        
RETURN            ;延时函数，主要用于按键消抖

    
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
    
DELAY1:
BANKSEL PIR1
BTFSS PIR1,0 ;judge target bit
GOTO DELAY1
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
    
    
TMR0_INT:
BCF INTCON,TMR0IF
DECF COFFSET
BTFSC STATUS,Z
CALL SETCOFFSET ;COFFSET减一
RETURN
 
SETCOFFSET:
MOVLW D'10'
MOVWF COFFSET
RETURN 
    
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
    
REFRESH_SHOW:
;TODO 根据KEY_VALUE计算COFFSET
BANKSEL KEY_VALUE
MOVF KEY_VALUE,0
ADDWF KEY_VALUE,0
ADDWF KEY_VALUE,0
ADDWF KEY_VALUE,0
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
    
TM0_INT:
;timer0中断执行程序 TODO 用TIMER0进行刷新
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
RETURN    
    
TM1_INT:
    BANKSEL STOP_WATCH
    INCF STOP_WATCH
    BANKSEL PIR1
    BCF PIR1,TMR1IF
    BANKSEL TMR1H
    MOVLW B'11111110'
    MOVWF TMR1H ;TMR1H Value
    BANKSEL TMR1L
    MOVLW B'11000111'
    MOVWF TMR1L ;TMR1L Value
    ;给timer1装入初值
    RETURN
    
    
CASE1:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ISPRESS_LAST == 0 and  ISPRESS == 0
; 此时表示按键两次都没被按下，需检测是否是单击

; if FLAG == 1 and STOP_WATCH > T1
; KEY_STATE = 1
;
; 1. X , Y 代表两个数
; 2. MOVLW Y  // 把 Y 放入 W 内
; 3. SUBLW X   // (X-Y)-->W 及设定旗号
; 4. 如果 Z=1，则两数相等
; 5. 如果 C=1，则 X>Y, 如 C=0, 则Y>X
BTFSS KEY_FLAG,0
GOTO MAIN ; KEY_FLAG == 0，直接进入下一步循环
BANKSEL STOP_WATCH     
MOVF STOP_WATCH,0 ; KEY_FLAG == 1，接着判断是否为单击，此处设置时间阈值T1
SUBLW .20
BTFSC STATUS,C
GOTO MAIN ; C == 0, STOP_WATCH < T1
MOVLW .1
MOVWF KEY_STATE ; C == 1, STOP_WATCH > T1，判为单击
; 更改数码管的显示图案   
MOVLW .44    
MOVWF COFFSET   
BANKSEL CNUM
MOVLW D'1'
MOVWF CNUM;;;;;;;;;;;;;;;;;;;;;;;;;4个数码管
MOVF COFFSET,W
MOVWF PA;;;;;;;;;;;;;;;;;;;;;;;;;;;PA暂时存储COFFSET
MOVLW D'4'
MOVWF CNT;;;;;;;;;;;;;;;;;;;;;;;;;;计数四次    
GOTO MAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CASE2:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ISPRESS_LAST == 0 and  ISPRESS == 1
; 初次被按下，判断是否为双击
; 若KEY_VALUE == KEY_VALUE_LAST 且 STOP_WATCH < T2，则判为双击
BANKSEL KEY_FLAG    
MOVLW B'00000001'
MOVWF KEY_FLAG ; 先给KEY_FLAG赋值为1
    
; 判断KEY_VALUE == KEY_VALUE_LAST？    
BANKSEL KEY_VALUE     
MOVF KEY_VALUE,0 
BANKSEL KEY_VALUE_LAST      
SUBWF KEY_VALUE_LAST
       
BTFSS STATUS,Z 
GOTO CASE2_RESET_STOP_WATCH ; Z == 0, KEY_VALUE != KEY_VALUE_LAST
BANKSEL STOP_WATCH ; z == 1, KEY_VALUE == KEY_VALUE_LAST，此处设置时间阈值T2，应满足T2<T1    
MOVF STOP_WATCH,0
SUBLW .10
    
BTFSS STATUS,C
GOTO CASE2_RESET_STOP_WATCH ; C == 1, STOP_WATCH > T2
BANKSEL KEY_STATE ; C == 0, STOP_WATCH < T2    
MOVLW .2  
MOVWF KEY_STATE ; 判为双击
BANKSEL KEY_FLAG      
MOVLW B'00000000' ; 将KEY_FLAG置为0
MOVWF KEY_FLAG

CASE2_RESET_STOP_WATCH
BANKSEL STOP_WATCH 
MOVLW B'00000000' ; 重置 STOP_WATCH
MOVWF STOP_WATCH
GOTO MAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CASE3:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ISPRESS_LAST == 1 and  ISPRESS == 1
; 此时按键一直被按下，判断是否为长按
BANKSEL KEY_FLAG    
BTFSS KEY_FLAG,0
GOTO MAIN ; KEY_FLAG == 0，直接进入下一步循环
;再判断KEY_VALUE == KEY_VALUE_LAST?    
BANKSEL KEY_VALUE     
MOVF KEY_VALUE,0 
BANKSEL KEY_VALUE_LAST      
SUBWF KEY_VALUE_LAST
BTFSS STATUS,Z     
GOTO MAIN ; Z == 0, KEY_VALUE != KEY_VALUE_LAST    
BANKSEL STOP_WATCH    
MOVF STOP_WATCH,0 ; KEY_VALUE == KEY_VALUE_LAST 且KEY_FLAG == 1，接着判断是否为长按，此处设置时间阈值T3
SUBLW .50
BTFSC STATUS,C
GOTO MAIN ; STOP_WATCH < T3
MOVLW .3  ; STOP_WATCH > T3，判为长按
MOVWF KEY_STATE 
GOTO MAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CASE4:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ISPRESS_LAST == 1 and  ISPRESS == 0
; 此时按键被抬起，需要做多种判断
; 判断KEY_STATE是否为3，即此前是否是长按

BANKSEL KEY_STATE    
MOVF KEY_STATE,0 ; 判断KEY_STATE == 3？
SUBLW .3
BTFSS STATUS,Z 
GOTO CASE4_RESET_STOP_WATCH ; Z == 0, KEY_STATE != 3
; z == 1, KEY_STATE == 3
MOVLW .11 ; 重置 STOP_WATCH为T2+1，使得下次被按下不会被判断为双击
MOVWF STOP_WATCH  ; TODO，清空TMR1
MOVLW B'00000000' ; 重置 STOP_WATCH为T2+1，使得下次被按下不会被判断为双击
MOVWF KEY_FLAG  ; 将KEY_FLAG置0，从而跳过单击判断
GOTO MAIN    

CASE4_RESET_STOP_WATCH
MOVLW B'00000000' ; 重置 STOP_WATCH
MOVWF STOP_WATCH  ; TODO，清空TMR1
GOTO MAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
;;;;;;;;;;函数区到此为止;;;;;;;;;;;;;;;;;;;    

MAIN
BANKSEL KEY_VALUE
MOVF KEY_VALUE,0
BANKSEL KEY_VALUE_LAST
MOVWF KEY_VALUE_LAST;保留上一次扫描中的键值
BANKSEL ISPRESS
MOVF ISPRESS,0
BANKSEL ISPRESS_LAST
MOVWF ISPRESS_LAST;保留上一次扫描中的键值
LOOP:
    CALL KEYSCAN
;    MOVLW 0X1
;    ANDWF ISPRESS;
;    BTFSC STATUS,Z
;GOTO LOOP
    
;CALL KEYSCAN
    
; 如果KEY_VALUE != KEY_VALUE_LAST，则刷新显示
BANKSEL KEY_VALUE     
MOVF KEY_VALUE,0 
BANKSEL KEY_VALUE_LAST      
SUBWF KEY_VALUE_LAST       
BTFSC STATUS,Z 
GOTO MAINCASE1 ; KEY_VALUE == KEY_VALUE_LAST
CALL REFRESH_SHOW ; KEY_VALUE != KEY_VALUE_LAST，此处设置时间阈值T2，应满足T2<T1    


MAINCASE1:
BTFSC ISPRESS,0
GOTO JUDGE_ISPRESS_1
GOTO JUDGE_ISPRESS_0

JUDGE_ISPRESS_1:
BTFSC ISPRESS_LAST,0
GOTO CASE3 ; 1 - 1
GOTO CASE2 ; 0 - 1

JUDGE_ISPRESS_0:
BTFSC ISPRESS_LAST,0
GOTO CASE4 ; 1 - 0
GOTO CASE1 ; 0 - 0
    
GOTO MAIN   
END  