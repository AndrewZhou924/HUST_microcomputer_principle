;本程序用于PIC 单片机 外接键盘的识别，通过汇编程序，使按下K1键时第一个数码管显示1，按下K2键时第一  
;个数码管上显示2，按下K3键时第一个数码管上显示3，按下K4键时第一个数码管上显示4，  
;汇编程序对键盘的扫描采用查询方式  
;origin : http://www.51hei.com/mcu/576.html

LIST P=18F458  
INCLUDE "P18F458.INC"  

;所用的寄存器  
JIANR EQU 0X20  
FLAG EQU JIANR+1 ;标志寄存器  
DEYH EQU JIANR+2  
DEYL EQU JIANR+3  
F0 EQU 0 ;FLAG的第0位定义为F0  
ORG 0X00  
GOTO MAIN  
ORG 0X30  
;*************以下为键盘码值转换表******************  
CONVERT ADDWF PCL，1  
RETLW 0XC0 ;0，显示段码与具体的硬件连接有关  
RETLW 0XF9 ;1  
RETLW 0XA4 ;2  
RETLW 0XB0 ;3  
RETLW 0X99 ;4  
RETLW 0X92 ;5  
RETLW 0X82 ;6  
RETLW 0XD8 ;7  
RETLW 0X80 ;8  
RETLW 0X90 ;9  
RETLW 0X88 ;A  
RETLW 0X83 ;B  
RETLW 0XC6 ;C  
RETLW 0XA1 ;D  
RETLW 0X86 ;E  
RETLW 0X8E ;F  
RETLW 0X7F ;"."  
RETLW 0XBF ;"-"  
RETLW 0X89 ;H  
RETLW 0XFF ;DARK  
RETURN  
;***************PIC 单片机 键盘扫描汇编程序初始化子程序*****************  
INITIAL  
BCF TRISA，5 ;置RA5为输出方式，以输出锁存信号  
BCF TRISB，1  
BCF TRISA，3  
BCF TRISE，0  
BCF TRISE，1  
BSF TRISB，4 ;设置与键盘有关的各口的输入输出方式  
BCF TRISC，5  
BCF TRISC，3 ;设置SCK与SDO为输出方式  
BCF INTCON，GIE ;关闭所有中断  
MOV LW 0XC0  
MOV WF SSPSTAT ;设置SSPSTAT寄存器  
MOV LW 0X30  
MOV WF SSPCON1 ;设置SPI的控制方式，允许SSP方式，并且时钟下降  
;沿发送数据，与"74HC595当其SCLK从低到高电平  
;跳变时，串行输入数据(DI)移入寄存器"的特点相对应  
MOV LW 0X01   
MOV WF JIANR ;显示值寄存器（复用为键值寄存器）赋初值  
CLRF FLAG ;清除标志寄存器  
RETURN ;返回  
;**************显示子程序*****************  
DISPLAY  
CLRF PORTA  
MOV WF SSPBUF  
AGAIN  
BTFSS PIR1，SSPIF  
GOTO AGAIN  
NOP  
BCF PIR1，SSPIF  
BSF PORTA，5 ;详细的程序语句请参考http://www.51hei.com pic 单片机 教程语句部分，可在首页搜索。  
RETURN  
;**************查键子程序*****************  
KEYSCAN  
BCF PORTB，1  
BCF PORTA，3  
BCF PORTE，0  
BCF PORTE，1 ;K1，K2，K3，K4四条列线置0  
NOP   
NOP ;延时，使引脚的电平稳定  
BTFSC PORTB，4  
BCF FLAG，F0 ;RB4为1，表示没键按下，清除标志F0  
NOP  
BTFSS PORTB，4  
BSF FLAG，F0 ;RB4为0，表示有键按下，建立标志F0  
RETURN   
;**********键盘去抖子程序(约8ms的延时)** ***************  
KEYDELAY  
MOV LW 0X0A  
MOV WF DEYH  
AGAIN2  MOV LW 0XFF  
MOV WF DEYL  
AGAIN1 DECFSZ DEYL，1  
GOTO AGAIN1  
DECFSZ DEYH，1  
GOTO AGAIN2  
RETURN   
;***************键服务子程序****************  
;确定键值的子程序  
KEYSERVE  
JIANZHI BCF PORTB，1   
BCF PORTA，3  
MOV LW 0X03  
MOV WF PORTE ;K1，K2置低电平，K3，K4置高电平  
NOP  
NOP ;使引脚电平稳定  
BTFSS PORTB，4  
GOTO K1K2 ;RB4为0，表示按键为K1，K2中的一个  
GOTO K3K4 ;RB4为1，表示按键为K3，K4中的一个  

K1K2 BCF PORTB，1  
BSF PORTA，3 ;K1置低电平，K2置高电平  
NOP  
NOP ;使引脚电平稳定  
BTFSS PORTB，4  
GOTO K1 ;RB4为0，表示按键为K1  
GOTO K2 ;RB4为1，表示按键为K2  

K3K4 BCF PORTE，0  
BSF PORTE，1 ;K3置低电平，K4置高电平  
NOP  
NOP ;使引脚电平稳定  
BTFSS PORTB，4  
GOTO K3 ;RB4为0，表示按键为K3  
GOTO K4 ;RB4为1，表示按键为K4  

K1  MOV LW 0X03  
MOV WF JIANR  
GOTO JIANW  
K2  MOV LW 0X05  
MOV WF JIANR  
BCF PORTA，3  
GOTO JIANW  
K3  MOV LW 0X07  
MOV WF JIANR  
GOTO JIANW  
K4  MOV LW 0X09  
MOV WF JIANR ;以上根据按下的键把相应的值送给JIANR  
BCF PORTE，1   
JIANW BTFSS PORTB，4  
GOTO JIANW ;为了防止一次按键多次识别，等键松开才返回  
RETURN  
;****************************************  
MAIN NOP  
CALL INITIAL ;调用初始化子程序  
LOOP   
CALL KEYSCAN ;查键  
BTFSC FLAG，F0  
CALL KEYDELAY ;若检测到有键按下，则调用软件延时子程序去抖动  
BTFSC FLAG，F0  
CALL KEYSCAN ;若第一次扫描到有键按下，则经过前面的延时去抖后  
;再次进行键扫描  
BTFSC FLAG，F0   
CALL KEYSERVE ;若确认有键按下，则需要调用键服务程序  
BTFSS FLAG，F0  
GOTO LOOP ;如果无键按下，则反复进行键扫描   
MOV F JIANR，W  
CALL CONVERT ;把按键对应的数字转换成待显示的段码  
CALL DISPLAY ;调用显示子程序  
GOTO LOOP  
END  