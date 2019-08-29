// PIC16F1786 Configuration Bit Settings
// 'C' source line config statements

// CONFIG1
#pragma config FOSC = INTOSC    // Oscillator Selection (ECH, External Clock, High Power Mode (4-32 MHz): device clock supplied to CLKIN pin)
#pragma config WDTE = OFF       // Watchdog Timer Enable (WDT disabled)
#pragma config PWRTE = OFF      // Power-up Timer Enable (PWRT disabled)
#pragma config MCLRE = ON       // MCLR Pin Function Select (MCLR/VPP pin function is MCLR)
#pragma config CP = OFF         // Flash Program Memory Code Protection (Program memory code protection is disabled)
#pragma config CPD = OFF        // Data Memory Code Protection (Data memory code protection is disabled)
#pragma config BOREN = ON       // Brown-out Reset Enable (Brown-out Reset enabled)
#pragma config CLKOUTEN = OFF   // Clock Out Enable (CLKOUT function is disabled. I/O or oscillator function on the CLKOUT pin)
#pragma config IESO = ON        // Internal/External Switchover (Internal/External Switchover mode is enabled)
#pragma config FCMEN = ON       // Fail-Safe Clock Monitor Enable (Fail-Safe Clock Monitor is enabled)

// CONFIG2
#pragma config WRT = OFF        // Flash Memory Self-Write Protection (Write protection off)
#pragma config VCAPEN = OFF     // Voltage Regulator Capacitor Enable bit (Vcap functionality is disabled on RA6.)
#pragma config PLLEN = ON       // PLL Enable (4x PLL enabled)
#pragma config STVREN = ON      // Stack Overflow/Underflow Reset Enable (Stack Overflow or Underflow will cause a Reset)
#pragma config BORV = LO        // Brown-out Reset Voltage Selection (Brown-out Reset Voltage (Vbor), low trip point selected.)
#pragma config LPBOR = OFF      // Low Power Brown-Out Reset Enable Bit (Low power brown-out is disabled)
#pragma config LVP = ON         // Low-Voltage Programming Enable (Low-voltage programming enabled)

// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.

#include <xc.h>
#include <pic.h>

// 定义变量
int DELAYTIME1 = 0x00;
int DELAYTIME2 = 0x00;
int KEY_VALUE  = 0x00;
int KEY_VALUE_LAST = 0x00;
int ISPRESS	= 0x00;
int ISPRESS_LAST = 0x00;
int OFFSET = 0x00;
int COFFSET	= 0x00;
int NUM	= 0x00;
int CNUM = 0x00;
int PA	= 0x00;
int CNT	= 0x00;
int KEY_FLAG = 0x00;
int KEY_STATE = 0x00;
int STOP_WATCH = 0x00;
int NUMBER_SHOW = 6789;
int STABLE[] = {0b00000001,0b00000010,0b00000100,0b00001000};
int TABLE[] = {0XFF,0XFF,0XFF,0XF9, // 1
               0XFF,0XFF,0XFF,0XA4, // 2
               0XFF,0XFF,0XFF,0XB0, // 3
               0XFF,0XFF,0XFF,0X99, // 4
               0XFF,0XFF,0XFF,0X92, // 5
               0XFF,0XFF,0XFF,0X82, // 6
               0XFF,0XFF,0XFF,0XF8, // 7
               0XFF,0XFF,0XFF,0X80, // 8
               0XFF,0XFF,0XFF,0X90, // 9
               0XFF,0XFF,0XC0,0XF9,
               0XF9,0XF9,0XF9,0XF9,
               0XA4,0XA4,0XA4,0XA4,
               0XB0,0XB0,0XB0,0XB0,
               0XC0,0XC0,0XC0,0XC0};
int NUMBER_TO_SHOW[] = {0XC0, 0XF9, 0XA4, 0XB0, 0X99, 0X92, 
                        0X82, 0XF8, 0X80, 0X90};               
#define INPUT   1
#define OUTPUT  0
#define I2C_SCL PORTCbits.RC3
#define I2C_SDA PORTCbits.RC4
#define I2C_SCL_IO TRISCbits.TRISC3
#define I2C_SDA_IO TRISCbits.TRISC4

// 函数声明区
void SETORIGIN(void);
void INICIALISE(void);
void SETCOFFSET(void);
void SETPA(void);
void REFRESH_SHOW(void);
void REFRESH_SHOW_2(void);
void SHOW_WITH_NUMBER(int number); 
void DELAY(void);
void SELECT(void);
void i2cInit_2(void);

// ===== I2C ===========================
void delay_(int delay_time);
void led_show(int seg_index[]);
int _switch_scan_step(void);
void _switch_scan_count_unshake(void);
void _count_show(int max_number_show);
void _i2c_start(void);
void _i2c_stop(void);
void _i2c_writeack(void);
void _i2c_writenoack(void);
unsigned char _i2c_writebyte(unsigned char bus_data_byte);
unsigned char _i2c_readbyte(void);
void _i2c_readmutibyte(unsigned char other_addr, unsigned char store_addr, unsigned char *addrpoint, unsigned char bytenum);
float _get_lm75b();
void temp_show(float temp);
void delayI2C();
float read_temprature();
void send_byte(unsigned char data);
// void delay();
unsigned char receive_ACK(void);
unsigned char read_byte(void);
void stop_I2C(void);
void send_NACK(void);
void send_ACK(void);
void init_I2C(void);
void start_I2C(void);
void init_ADC(void);
void init_touch(void);
void init_temperature(void);
void restart_ADC(void);
void restart_touch(void);
void data_output(void);
// =====================================

int main() {
    INICIALISE();
    INTCONbits.GIE=1; 
          
    INTCONbits.TMR0IF=0;
    INTCONbits.TMR0IE=1;
    
    INTCONbits.PEIE=1;
    T1CONbits.TMR1ON=1;
    PIR1bits.TMR1IF=0;
    PIE1bits.TMR1IE=1;
    
    i2cInit_2();

    // test temperature
    float temperature;
    while(1) {
        NOP();
        temperature = _get_lm75b();
        NUMBER_SHOW = temperature / 4;
    };
}

// 中断服务函数
void interrupt irs_routine(void) {
    if (INTCONbits.TMR0IF == 1) 
        goto TMR0_INT_ISR;
    // 清除timer0的标志位，重新装入初值
    INTCONbits.TMR0IF=0;
    TMR0 = 254;
    if (PIR1bits.TMR1IF == 1) 
        goto TMR1_INT_ISR;
    return;

    TMR1_INT_ISR:
    if (STOP_WATCH <= 254) 
        STOP_WATCH++;
    PIR1bits.TMR1IF = 0;
    TMR1H = 0b00000000;
    TMR1L = 0b11000111;
    return;

    TMR0_INT_ISR:
    NUM = CNUM;
    OFFSET = PA;
    
    SELECT();
    SHOW_WITH_NUMBER(NUMBER_SHOW);

    PA--;
    CNUM++;
    CNT--;
    if (PA <= 0)
        SETPA();
    if (CNT <= 0)
        SETORIGIN();   
    INTCONbits.TMR0IF=0;    
    TMR0 = 254;     
    return;
}

// 程序初始化
void INICIALISE(void) {
    OSCCON = 0b01101000;

    OPTION_REG = 0b00000111;
    PIE1 = 0b00000001;
    TMR1 = 0b00110001;
    PIR1 = 0b00000000;
    TMR1H = 0b11110011;
    TMR1L = 0b11000111;
    TMR0  = 0b00000000;
    INTCON = 0b11101000;

    TRISA = 0;
    LATA  = 0;
    ANSELA = 0b00000000;
    TRISB = 0b00000000;
    LATB = 0;
    ANSELB = 0b00000000;
    WPUB = 0b11111111;
    TRISC = 0;
    LATC = 0;

    KEY_VALUE_LAST = 0;
    KEY_VALUE = 0;
    ISPRESS = 0;
    ISPRESS_LAST = 0;

    KEY_STATE = 0;
    STOP_WATCH = 0;

    COFFSET = 56;
    CNUM = 1;
    PA = COFFSET;
    CNT = 4;
}

void SETORIGIN(void) {
    CNUM = 1;
    CNT = 4;
    PA = COFFSET;
}

void SETCOFFSET(void) {
    COFFSET = 10;
}

void SETPA(void) {
    PA = 10;
} 

 void DELAY(void) {
         for (int i=0; i<1; i++) {
             for (int j=0; j<5; j++) {
 //            pass;
         }
     }
 }

void REFRESH_SHOW(void) {
    COFFSET = KEY_VALUE*4;
    CNUM = 1;
    PA = COFFSET;
    CNT = 4;
}


void SHOW_WITH_NUMBER(int number) {
    int index;
    
//    switch (NUM) {
//    case 1: //最高位
//        index = (int)(number/1000) % 10;
//        break;
//    case 2:
//        index = (int)(number/100) % 10;
//        break;
//    case 3:
//        index = (int)(number/10) % 10;
//        break;        
//    case 4: // 最低位，个位
//        index = number % 10;
//        break;
//    default:
//        break;
//    }
    
    switch (NUM) {
    case 4: 
        index = (int)(number/1000) % 10;
        break;
    case 3:
        index = (int)(number/100) % 10;
        break;
    case 2:
        index = (int)(number/10) % 10;
        break;        
    case 1: // 最低位，个位
        index = number % 10;
        break;
    default:
        break;
    }

    LATA = NUMBER_TO_SHOW[index];
    return;
}

void REFRESH_SHOW_2(void) {
    NUMBER_SHOW = KEY_VALUE;
}

void SELECT(void) {
    LATA  = 0b11111111;
    PORTB = 0b11111111;   
    
    PORTB = STABLE[NUM-1];
}

// void delay(){
//     int i = 2;
//     while(--i)
//     {
//         NOP();
//     }
// }

void _i2c_start(void){
    I2C_SDA_IO = 0;
    I2C_SCL_IO = 0;
    I2C_SDA = 1;
    delayI2C();
    I2C_SCL = 1;
    delayI2C();
    I2C_SDA = 0;
    delayI2C();
    I2C_SCL = 0;
    delayI2C();
}

void _i2c_stop(void){
    I2C_SDA = 0;
    delayI2C();
    I2C_SCL = 1;
    delayI2C();
    I2C_SDA = 1;
    delayI2C();
    I2C_SCL = 0;
    delayI2C();
}

//Data Get success
void _i2c_writeack(void){
    I2C_SDA_IO = 0;
    I2C_SDA = 0;
    delayI2C();
    I2C_SCL = 1;
    delayI2C();
    I2C_SCL = 0;
    delayI2C();
}

//Data Get Error ack
void _i2c_writenoack(void){
    I2C_SDA_IO = 0;
    I2C_SDA = 1;
    delayI2C();
    I2C_SCL = 1;
    delayI2C();
    I2C_SCL = 0;
    delayI2C();
}

void delayI2C()
{
    int i = 2;
    while(--i)
    {
        NOP();
    }
}

unsigned char  _i2c_writebyte(unsigned char bus_data_byte){
    unsigned char status_ack = 1;
    I2C_SDA_IO = 0;
    for(unsigned char i=0;i<8;i++){
        I2C_SCL = 0;
        delayI2C();
        if((bus_data_byte & 0x80) == 0x80) I2C_SDA = 1;
        else I2C_SDA = 0;
        delayI2C();
        I2C_SCL = 1;
        bus_data_byte <<= 1;
        delayI2C();
    }
    I2C_SCL = 0;
    delayI2C();
    I2C_SDA = 1;
    delayI2C();
    //2C_SDA = 0;
    I2C_SDA_IO = 1;
    delayI2C();
    I2C_SCL = 1;
    delayI2C();
    for(unsigned char j=0;j<10;j++){
        if (!I2C_SDA){
            status_ack = 0;
            break;
        }
    }
    //I2C_SCL = 0;
    I2C_SDA_IO = 0;
    return status_ack;
}


unsigned char _i2c_readbyte(void){
    unsigned char read_data ;
    I2C_SDA_IO = 1;
    //I2C_SDA = 1;
    delayI2C();
    I2C_SDA_IO = 0;
    I2C_SCL = 0;
    delayI2C();
    for(unsigned char i=0;i<8;i++){
        I2C_SCL = 1;
        delayI2C();
        read_data <<= 1;
        read_data |= I2C_SDA;
        I2C_SCL = 0;
        delayI2C();
    }
    I2C_SDA_IO = 0;
    return read_data;
}

void _i2c_readmutibyte(unsigned char other_addr, unsigned char store_addr, unsigned char* addrpoint, unsigned char bytenum){
    unsigned char status_ack;
    _i2c_start();
    status_ack = _i2c_writebyte(other_addr);
    if(!status_ack) status_ack = _i2c_writebyte(store_addr);
    if(!status_ack) {
        _i2c_start();
        status_ack = _i2c_writebyte(other_addr + 0x01);
    }
    if(!status_ack)
    for(unsigned char i = 0;i< bytenum; i++){
        if(!status_ack){
            addrpoint[i] = _i2c_readbyte();
            if(i < (bytenum - 1)) _i2c_writeack();
            else _i2c_writenoack();
        }
    }
    _i2c_stop();
    // delay_(2);
    DELAY();
    return ;
}

//get number of temp
float _get_lm75b(){
    float temp_result;
    unsigned char temp_regist[2];
    _i2c_readmutibyte(0x91, 0x00, temp_regist, 2);
    int temp = 0;
    temp = temp_regist[0];
    temp <<= 8;
    temp += temp_regist[1];
    temp >>= 5;
    temp_result = temp * 0.125;
    return temp_result;
}

void i2cInit_2(void) {
    I2C_SCL = 1;
    I2C_SDA = 1;

    SSP1CON1bits.SSPM0 = 0;
    SSP1CON1bits.SSPM1 = 0;
    SSP1CON1bits.SSPM2 = 0;
    SSP1CON1bits.SSPM3 = 1;// I2C Master mode ,clock=Fosc/(4*(SSPxADD+1))
    SSP1STATbits.SMP = 1;
    SSP1ADD = 0x2F;     //SCL CLOCK Frequency 50KHZ
    SSP1CON1bits.SSPEN = 1;
}
