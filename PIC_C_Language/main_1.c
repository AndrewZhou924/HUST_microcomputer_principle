＃include＜pic.h＞？／／包含头文件 Pic.h
 ／／＝＝＝＝／／程序段分隔
 ＃define PORTDIT（add，bit）（（un－
signed）（＆add）＊8＋（bit））／／位定义
 static bit PORT_0 ＠PORTDIT
（PORTD，0）；／／定义 PORTD 的 0 位
 static bit PORT_1 ＠PORTDIT
（PORTD，1）；／／定义 PORTD 的第 1 位
 static bit PORT_2 ＠PORTDIT
（PORTD，2）；／／定义 PORTD 的第 2 位
 static bit PORT_3 ＠PORTDIT
（PORTD，3）；／／定义 PORTD 的第 3 位
 void delay（）／／定义 delay 延时子函数
 ｛／／子函数开始
 Unsigned longint i；
／／定义 i 为无符号的整型变量
 for（i＝0；i＜＝45000；i＋＋）／／由 for 语句引
导，指定次数 1 秒延时
 continue；／／转移下次循环
 ｝／／子函数结束
 ／／＝＝／／程序段分隔（可不用）
 main（）／／定义 main 主函数
 ｛／／主函数开始
 TRISD＝0x00；／／给 TRISD 赋值 0，设
D 口为输出
 INTCON＝0x00；／／给
INTCON 赋值 0，关中断
 PORTD＝0x00；／／给
PORTD 赋值 0，清 0D 口
 while（1）／／while 循环语句，这里是
无限循环
 ｛／／while 语句开始
 PORT 0＝1；／／给 PIC16F877 的 RD0
位赋值 1，外接／／LED 亮。
 delay（）；／／调延时子函数 delag
 PORT 0＝1；／／给 RD1 位赋值 1，外
接 LED 亮
 delay（）；／／调延时子函数 delay
 RD2＝1；／／RD2 位置 1，外接 LED 亮
 delay（）；／／调延时子函数 delay
 RD3＝1；／／RD3 位置 1，外接 LED 亮
 delay（）；／／调延时子函数 delay
 PORTD＝0；／／给 PORTD 赋值 0（字
节），清 0D 口
 delay（）；／／调延时子函数 delay
 ｝／／循环语句结束
 ｝／／主函数结束