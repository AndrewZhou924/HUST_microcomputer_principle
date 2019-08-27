//开发环境MPLAB X IDE ，单片机PIC16LF1823. 

#include <pic.h>

__CONFIG(FOSC_INTOSC&WDTE_OFF&PWRTE_ON&MCLRE_OFF&CP_ON&CPD_OFF&BOREN_ON

                   &CLKOUTEN_OFF&IESO_ON&FCMEN_ON);//这个要放到上一行去


__CONFIG(PLLEN_OFF&LVP_OFF) ;
#define  ADC_NUM   8 //转换的次数
#define  LED       LATA1
void init_GPIO(void)
{
    TRISA =  0x01;//端口设置为输入
    ANSELA = 0x01;//设置为模拟输入
    PORTA = 0x00;
    LATA  = 0x00;
}
void init_fosc(void)
{
    OSCCON = 0xF0;//32MHZ
}
void init_AD(void)
{
 ADCON1= 0xA0;//右对齐，AD时钟为Fosc/32,参考电压为电源电压，
 ADCON0= 0x00;//选择通道AN0
 ADCON0bits.ADON = 1;//开启模块
}
unsigned int ADC_BAT_ONE(void)//转换一次
{
    unsigned int value;
    value=0;
    ADCON0bits.CHS =0;//选择通道AN0
    ADCON0bits.ADGO=1;//开始转换
    while(ADCON0bits.GO==1);//等待转换结束


    value=(unsigned int)ADRESH;//强制类型转换，因为ADRESH是字符型的只能表示8位二进制。所以必须转换成可以容纳10位二进制的整型。
    value= value<<8;// 将高两位左移8位
    value += ADRESL;//低八位加入ADRESL的值。
    return value;
}
unsigned int ADC_BAT_contiue(void)
{
    unsigned int ADV_MCU[ADC_NUM],ADV_CNT,ADV_ALL;
    ADV_ALL=0;
    for(ADV_CNT=0;ADV_CNT<ADC_NUM;ADV_CNT++)//进行多次AD转换
    {
     ADV_MCU[ADV_CNT]=ADC_BAT_ONE();
    }
     for(ADV_CNT=0;ADV_CNT<ADC_NUM;ADV_CNT++)//计算多次AD转换的平均值
    {
        ADV_ALL += ADV_MCU[ADV_CNT];
    }
    ADV_ALL= ADV_ALL/ADC_NUM;
    return ADV_ALL;//得到结果返回
}
/*
 *
 */
int main(int argc, char** argv) {
     init_fosc();//设置时钟
     init_GPIO();//设置I/O口
     init_AD();//设置AD
     while(1)
     {
         if( ADC_BAT_contiue()>400)//判断输入电压是否大于1.2V
         {
             LED=1;//灯亮
         }
         else
         {
             LED=0;//灯灭
         }


     }
}
 ———————————————— 
版权声明：本文为CSDN博主「superanters」的原创文章，遵循CC 4.0 by-sa版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/superanters/article/details/8806970