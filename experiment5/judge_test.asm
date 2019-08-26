KEY_VALUE
KEY_VALUE_LAST
KEY_FLAG
KEY_STATE
ISPRESS
ISPRESS_LAST
STOP_WATCH

;初始化变量 在MAIN之外

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
MOVLW .20 ; KEY_FLAG == 1，接着判断是否为单击，此处设置时间阈值T1
SUBLW STOP_WATCH
BTFSS STATUS,C
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
MOVLW B'00000001'
MOVWF KEY_FLAG ; 先给KEY_FLAG赋值为1
MOVLW KEY_VALUE ; 判断KEY_VALUE == KEY_VALUE_LAST？
SUBLW KEY_VALUE_LAST
BTFSS STATUS,Z 
GOTO CASE2_RESET_STOP_WATCH ; Z == 0, KEY_VALUE != KEY_VALUE_LAST
MOVLW .10; z == 1, KEY_VALUE == KEY_VALUE_LAST，此处设置时间阈值T2，应满足T2<T1
SUBLW STOP_WATCH
BTFSC STATUS,C
GOTO CASE2_RESET_STOP_WATCH ; C == 1, STOP_WATCH > T2
MOVLW .2  ; C == 0, STOP_WATCH < T2
MOVWF KEY_STATE ; 判为双击
MOVLW B'00000000' ; 将KEY_FLAG置为0
MOVWF KEY_FLAG

CASE2_RESET_STOP_WATCH
MOVLW B'00000000' ; 重置 STOP_WATCH
MOVWF STOP_WATCH
GOTO MAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CASE3:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ISPRESS_LAST == 1 and  ISPRESS == 1
; 此时按键一直被按下，判断是否为长按
BTFSS KEY_FLAG,0
GOTO MAIN ; KEY_FLAG == 0，直接进入下一步循环
MOVLW .50 ; KEY_FLAG == 1，接着判断是否为长按，此处设置时间阈值T3
SUBLW STOP_WATCH
BTFSS STATUS,C
GOTO MAIN ; C == 0, STOP_WATCH < T3
MOVLW .3
MOVWF KEY_STATE ; C == 1, STOP_WATCH > T3，判为长按
GOTO MAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CASE4:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ISPRESS_LAST == 1 and  ISPRESS == 0
; 此时按键被抬起，需要做多种判断
; 判断KEY_STATE是否为3，即此前是否是长按

MOVLW .3 ; 判断KEY_VALUE == 3？
SUBLW KEY_VALUE
BTFSS STATUS,Z 
GOTO CASE4_RESET_STOP_WATCH ; Z == 0, KEY_VALUE != 3
; z == 1, KEY_VALUE == 3
MOVLW .11 ; 重置 STOP_WATCH为T2+1，使得下次被按下不会被判断为双击
MOVWF STOP_WATCH  ; TODO，清空TMR1
MOVLW B'00000000'' ; 重置 STOP_WATCH为T2+1，使得下次被按下不会被判断为双击
MOVWF KEY_FLAG  ; 将KEY_FLAG置0，从而跳过单击判断

CASE4_RESET_STOP_WATCH
MOVLW B'00000000' ; 重置 STOP_WATCH
MOVWF STOP_WATCH  ; TODO，清空TMR1

GOTO MAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; TODO 写测试用例