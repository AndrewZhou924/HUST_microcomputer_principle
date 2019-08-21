; TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR
#INCLUDE p16f1786.inc
udata_shr    
D1    res 1h               ;定义变量
D2    res 1h
D3    res 1h
RES_VECT  CODE    0x0000            ; processor reset vector
   GOTO    START                   ; go to beginning of program

; TODO ADD INTERRUPTS HERE IF USED

MAIN_PROG CODE                      ; let linker place main program

START

     NOP
     BANKSEL  PORTA       ;找到PORTA对应的bank
     CLRF     PORTA       ;将PORTA数据清零
     BANKSEL  ANSELA       ;找到控制PORTA模式配置寄存器
     CLRF     ANSELA       ;配置PORTA的全部引脚为数字端口模式（0为数字模式，1为模拟模式）
     BANKSEL  TRISA       ;找到PORTA对应的数据方向寄存器
     CLRF   TRISA
     MOVLW    B'00000000' 
     MOVWF    TRISA       ;配置为输出端口 
    LOOP 
	MOVLW 1H
	MOVWF D1
	MOVLW 1H
	MOVWF D2
	MOVLW 1H
	MOVWF D3
      MOVLW 01H            ;送01H到W
      XORWF PORTA,f        ;取反RA0，让LED闪烁，用RA0点亮LED
      CALL DELAY           ;调用0。2S廷时程控
      GOTO LOOP            ;返回不断闪烁
;-------------------------------------以下是0。2S廷时子程序
    DELAY                         
	    MOVLW 2           
	    MOVWF D1        
	DELAY_1
	    MOVLW 200        
	    MOVWF D2      
	DELAY_2
	    MOVLW 200       
	    MOVWF D3       
	DELAY_3
	    DECFSZ D3,1        
	    GOTO DELAY_3      
	    DECFSZ D2,1         
	    GOTO DELAY_2        
	    DECFSZ D1,1         
	    GOTO DELAY_1        
    RETURN            ;子程序返回

	    END               ; 形式上的程序结束
