/***********************************************************************
*** 功能：键盘矩阵扫描
*** 实验内容：数码管显示相应的按键,开始的时候显示------，按下按键以后显示按键的编号
*** 开发板连接方法： J3接到2-3位置  J2不要接上。
***********************************************************************/
#include<pic.h>              //包含单片机内部资源预定义
__CONFIG(0xFF32);
//芯片配置字，看门狗关，上电延时开，掉电检测关，低压编程关，加密，4M晶体HS振荡
const unsigned char TABLE[] = {0x3f, 0x6, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x7, 0x7f, 0x6f, 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71};
int result=0x00,preres=0x00;
void delay();                      //delay函数申明
void init();                       //I/O口初始化函数申明
void scan();                       //按键扫描程序申明
void display();                       //显示函数申明

/****************************************************************************
* 名    称：main（）
* 功    能：主程序
* 入口参数：
* 出口参数：
****************************************************************************/
void main()
{
        init();                                //调用初始化子程序
        while (1)                   //循环工作
        {

                scan();                //调用按键扫描子程序
                display(result);       //调用结果显示子程序
        }
}

/****************************************************************************
* 名    称：init()
* 功    能：初始化
* 入口参数：
* 出口参数：
****************************************************************************/
void init()
{
        ADCON1 = 0X07;               //设置A口为普通I/O口
        TRISB = 0X0F;                                   //设置B口低4位为输入//高四位为输出
        TRISD = 0;                                   //portd 输出
        TRISA = 0;                                   //porta 输出
        PORTA = 0x00;                                 //先关闭所有显示
        PORTD = 0x40;
        TRISC = 0Xf0;
        PORTC = 1;

}

/****************************************************************************
* 名    称：scan()
* 功    能：按键扫描
* 入口参数：
* 出口参数：
* 说    明：便于初学者学习，我们采用一一行的扫面方式
****************************************************************************/
void scan()
{
        PORTB = 0X7f;                 //B7输出低电平，其他三位输出高电平
        asm("nop");                 //插入一定延时，确保电平稳定
        result = PORTB;               //读回B口低4位结果
        result = result & 0x0f;         //清除高4位
        if (result != 0x0f)            //判断低4位是否为全1（全1代表没按键按下）？
        {
                result = result | 0x70;     //否，加上高4位0x70，做为按键扫描的结果
        }
        else                        //是，改变低4位输出，重新判断是否有按键按下
        {
                PORTB = 0Xbf;               //B6输出低电平，其他三位输出高电平
                asm("nop");               //插入一定延时，确保电平稳定
                result = PORTB;             //读回B口高低4位结果
                result = result & 0x0f;       //清除高4位
                if (result != 0xf)           //判断低4位是否为全1（全1代表没按键按下）
                {
                        result = result | 0xb0;     //否，加上高4位0xb0，做为按键扫描的结果
                }
                else                      //是，改变低4位输出，重新扫描
                {
                        PORTB = 0Xdf;           //B5输出低电平，其他三位输出高电平
                        asm("nop");           //插入一定延时，确保电平稳定
                        result = PORTB;         //读回B口低4位结果
                        result = result & 0x0f;   //清除高4位
                        if (result != 0x0f)      //判断低4位是否为全1（全1代表没按键按下）
                        {
                                result = result | 0xd0;  //否，加上高4位0xd0，做为按键扫描的结果
                        }
                        else                  //是，改变高4位的输出，重新扫描
                        {
                                PORTB = 0Xef;        //B4输出低电平，其他三位输出高电平
                                asm("nop");        //插入一定延时，确保电平稳定
                                result = PORTB;      //读回B口低4位结果
                                result = result & 0x0f; //清除高4位
                                if (result != 0x0f)   //判断低四位是否为全1（全1代表没有按键按下）
                                {
                                        result = result | 0xe0; //否，加上高4位0x0e，做为按键扫描的结果
                                }
                                else               //是，全部按键扫描结束，没有按键按下，置无按键按下标志位
                                {
                                        result = 0xff;    //扫描结果为0xff，做为没有按键按下的标志
                                }
                        }
                }
        }
        if(result==0xff)
                result=preres;
        else
                preres=result;


}

/****************************************************************************
* 名    称：display()
* 功    能：显示
* 入口参数：
* 出口参数：
****************************************************************************/
void display()
{
        switch (result)
        {
        case 0xe7:
                PORTD = TABLE[3];PORTA = 0XFF;delay();break;           //K3
        case 0xeb:
                PORTD = TABLE[2];PORTA = 0XFF;delay();break;           //K2
        case 0xed:
                PORTD = TABLE[1];PORTA = 0XFF;delay();break;           //K1
        case 0xee:
                PORTD = TABLE[0];PORTA = 0XFF;delay();break;           //K0
        case 0xd7:
                PORTD = TABLE[7];PORTA = 0XFF;delay();break;           //K7
        case 0xdb:
                PORTD = TABLE[6];PORTA = 0XFF;delay();break;           //K6
        case 0xdd:
                PORTD = TABLE[5];PORTA = 0XFF;delay();break;           //K5
        case 0xde:
                PORTD = TABLE[4];PORTA = 0XFF;delay();break;           //K4
        case 0xb7:
                PORTD = TABLE[11];PORTA = 0XFF;delay();break;   //KB
        case 0xbb:
                PORTD = TABLE[10];PORTA = 0XFF;delay();break;   //KA
        case 0xbd:
                PORTD = TABLE[9];PORTA = 0XFF;delay();break;           //K9
        case 0xbe:
                PORTD = TABLE[8];PORTA = 0XFF;delay();break;           //K8
        case 0x77:
                PORTD = TABLE[15];PORTA = 0XFF;delay();break;   //KF
        case 0x7b:
                PORTD = TABLE[14];PORTA = 0XFF;delay();break;   //KE
        case 0x7d:
                PORTD = TABLE[13];PORTA = 0XFF;delay();break;   //KD
        case 0x7e:
                PORTD = TABLE[12];PORTA = 0XFF;delay();break;   //KC
        case 0x00:
                PORTD = 0x40; PORTA = 0xFF; delay();      //无按键按下显示------
        }
}

/****************************************************************************
* 名    称：delay()
* 功    能：延时
* 入口参数：
* 出口参数：
****************************************************************************/
void delay()
{
        int i;                                 //定义整形变量
        for (i = 0x100;i--;);             //延时
}