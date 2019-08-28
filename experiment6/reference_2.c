#include<pic.h>

__CONFIG(FOSC_INTOSC&WDTE_OFF&PWRTE_ON&MCLRE_OFF&CP_ON&CPD_OFF&BOREN_ON&CLKOUTEN_OFF&IESO_ON&FCMEN_ON);
__CONFIG(PLLEN_OFF&LVP_OFF) ;

/**********RA*********/
//B'1111,1000'H F8
#define LED_SW  RA5//IN
#define UP_SW   RA4//IN
#define DOWN_SW RA3//IN
#define LED     RA2//OUT
//RA1
//RA0
/**********RC***********/
//H FF
//RC0   SCL
//RC1   SDA
#define input 1
#define LED_VALUE  1
#define UP_VALUE   2
#define DOWN_VALUE 3
#define key_delay  300

void tx_pro(unsigned char tx_db);
unsigned char DB_VALUE;
void init_fosc(void)
{
 OSCCON = 0xF0;//32MHZ
}
void init_gpio(void)
{
 PORTA=0;
 LATA =0;
 ANSELA=0x00;
 TRISA =0xF8;


 PORTC=0;
 LATC=0;
 ANSELC = 0x00;
 TRISC =0xFF;
}
void init_i2c_master()
{
    TRISC0 = input;
    TRISC1 = input;
    SSP1CON1bits.SSPM0 = 0;
    SSP1CON1bits.SSPM1 = 0;
    SSP1CON1bits.SSPM2 = 0;
    SSP1CON1bits.SSPM3 = 1;// I2C Master mode ,clock=Fosc/(4*(SSPxADD+1))
    SSP1STATbits.SMP = 1;
    SSP1ADD = 0x9F;//SCL CLOCK Frequency 50KHZ
    SSP1CON1bits.SSPEN = 1;
}
void i2c_master_tx(unsigned char tx_data)
{
    SSP1CON2bits.SEN = 1;//Start condition
    while(SSP1CON2bits.SEN == 1);//waiting for Start condition completed.


    PIR1bits.SSP1IF = 0;
    SSP1BUF = 0x88;//Device Address
    while(PIR1bits.SSP1IF == 0);
    PIR1bits.SSP1IF = 0;
    // ~ACK
    
    SSP1BUF = tx_data;//Data 10db level
    while(PIR1bits.SSP1IF == 0);
    PIR1bits.SSP1IF = 0;
    
   //  ~ACK
    SSP1BUF = 0xD0;//Data 1db level
    while(PIR1bits.SSP1IF == 0);
    PIR1bits.SSP1IF = 0;
   //  ~ACK
    SSP1CON2bits.PEN = 1;//Stop condition
}
void delay(unsigned int n)
{
    while(n--);
}
unsigned char key_board(void)
{
    if(LED_SW==1)
    {
        delay(key_delay);
        if(LED_SW==1)
        {
            while(LED_SW==1);
            return LED_VALUE;
        }
    }
    if(UP_SW==1)
    {
        delay(key_delay);
        if(UP_SW==1)
        {
            while(UP_SW==1);
            return UP_VALUE;
        }
    }
    if(DOWN_SW==1)
    {
        delay(key_delay);
         if(DOWN_SW==1)
        {
            while(DOWN_SW==1);
            return DOWN_VALUE;
        }


    }
    return 0;


}
void DB_INC(void)
{
    if(DB_VALUE < 7)
    {
        DB_VALUE++;
        eeprom_write(0x00, DB_VALUE);//将音量值保存到EEPROM这样掉电后数据也不会丢失。
        tx_pro(DB_VALUE);
    }




}
void DB_DEC(void)
{
    if(DB_VALUE  > 0)
    {
        DB_VALUE --;
        eeprom_write(0x00, DB_VALUE);
        tx_pro(DB_VALUE);
    }
}
void tx_pro(unsigned char tx_db)
{
    tx_db |= 0xE0;           //将高三位设置为1。表示两个音频通道，以10dB为单位降低或增加音量
    i2c_master_tx(tx_db);//I2C发送数据程序
}
/*
 * 
 */
int main(int argc, char** argv) {


    unsigned char keyvalue;
    init_fosc();
    init_gpio();
    init_i2c_master();
    LED=0;
    DB_VALUE= eeprom_read(0x00);//读eeprom 中保存的音量值
    if(DB_VALUE > 7)//如果之前没有设置过则音量不衰减
    {
      DB_VALUE = 0;
    }
    tx_pro(DB_VALUE);//用I2C通信设置RSM2257的音量
    while(1)
    {
         keyvalue=key_board();//判断按键程序，
         switch(keyvalue) 
         {
             case LED_VALUE://LED按键按下
             {
                 LED = ~LED;
             };break;
             case UP_VALUE://音量加
             {
                 DB_INC();
                 
             };break;
             case DOWN_VALUE://音量减
             {
                 DB_DEC();
                 
             };break;
         }


    }


}