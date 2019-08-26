#INCLUDE p16f1786.inc  
__CONFIG _CONFIG1, _FOSC_ECH & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _CLKOUTEN_OFF & _IESO_ON & _FCMEN_ON
 __CONFIG _CONFIG2, _WRT_OFF & _VCAPEN_OFF & _PLLEN_ON & _STVREN_ON & _BORV_LO & _LPBOR_OFF & _LVP_ON
 
UDATA_SHR
KEY_VALUE res 1
KEY_VALUE_LAST res 1
KEY_FLAG res 1
KEY_STATE res 1
ISPRESS res 1
ISPRESS_LAST res 1
STOP_WATCH res 1
 
RES_VECT  CODE    0x0000            ; processor reset vector
GOTO FIRST                   ; go to beginning of program
MAIN_PROG CODE                      ; let linker place main program

CODE
FIRST;初始化单片机各个外设代码
;;;;;;;;;;;;;;;;;;;;开始初始化;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BANKSEL KEY_VALUE  
MOVLW .2
MOVWF KEY_VALUE
 
BANKSEL KEY_VALUE_LAST
MOVLW .5
MOVWF KEY_VALUE_LAST

BANKSEL KEY_FLAG   
MOVLW .1
MOVWF KEY_FLAG
    
BANKSEL KEY_STATE
MOVLW .2
MOVWF KEY_STATE 
 
BANKSEL ISPRESS    
MOVLW .0
MOVWF ISPRESS    
 
BANKSEL ISPRESS_LAST   
MOVLW .1
MOVWF ISPRESS_LAST
    
BANKSEL STOP_WATCH
MOVLW .60
MOVWF STOP_WATCH    
 
PAGESEL MAIN
GOTO MAIN
;;;;;;;;;;;;;;;;;;;;结束初始化;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 

MAIN
LOOP
    
;;;;;;;;;;; change number ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;注：此函数不能每次循环都被使用，否则数码管无法正常显示图案    
;CALL REFRESH_SHOW
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
;JUDGE
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
MOVF STOP_WATCH ; KEY_FLAG == 1，接着判断是否为单击，此处设置时间阈值T1
SUBLW .20
BTFSC STATUS,C
GOTO MAIN ; C == 0, STOP_WATCH < T1
MOVLW .1
MOVWF KEY_STATE ; C == 1, STOP_WATCH > T1，判为单击
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
    
    
GOTO LOOP
END