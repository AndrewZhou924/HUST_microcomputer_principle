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
// I2C
#define SCL PORTCbits.RC3
#define SDA PORTCbits.RC4
#define SCL_IO TRISCbits.TRISC3
#define SDA_IO TRISCbits.TRISC4
#define INPUT   1
#define OUTPUT  0

// 函数声明区
void SETORIGIN(void);
void INICIALISE(void);
void SETCOFFSET(void);
void SETPA(void);
void REFRESH_SHOW(void);
void SHOW_WITH_NUMBER(int number); 
void DELAY(void);
void SELECT(void);
// ===== I2C ===========================
float read_temprature();
void send_byte(unsigned char data);
void delay();
unsigned char receive_ACK(void);
unsigned char read_byte(void);
void stop_I2C(void);
void send_NACK(void);
void send_ACK(void);
void init_I2C(void);
void start_I2C(void);
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

    // test I2C
    float temperature = 0;
    
    while(1) {
        temperature = read_temprature();
        if (temperature > 0 && temperature < 100) {
            NUMBER_SHOW = (int) 100 * temperature;
        }
        

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


void SELECT(void) {
    LATA  = 0b11111111;
    PORTB = 0b11111111;   
    
    PORTB = STABLE[NUM-1];
}

float read_temprature(){
    unsigned char dataH,dataL;
    float result = 0.0;
    init_I2C();
    start_I2C();
    send_byte(0b10010001);
    if(receive_ACK() == 1){
        dataH = read_byte();
        send_ACK();
        dataL = read_byte();
        send_NACK();
        result = ((dataH & 0x7f) * 8.0 + (float)dataL / 32.0) / 8.0;
    }
    stop_I2C();
    return result;
}


void delay(){
    int i = 2;
    while(--i)
    {
        NOP();
    }
}
void init_I2C(void){
    SDA_IO = OUTPUT;
    delay();
    SCL_IO = OUTPUT;
    delay();
    SDA = 1;
    delay();
    SCL = 1;
    delay();
}

void start_I2C(void){
    SDA = 1;
    delay();
    SCL = 1;
    delay();
    SDA = 0;
    delay();
    SCL = 0;
    delay();
}

void stop_I2C(void){
    SCL = 0;
    delay();
    SDA_IO = OUTPUT;
    delay();
    SDA = 0;
    delay();
    SCL = 1;
    delay();
    SDA = 1;
    delay();
}

void send_byte(unsigned char data){
    SDA_IO = OUTPUT;
    unsigned char i;
    for (i = 0; i < 8; i++){
        delay();
        SCL = 0;
        delay();
        SDA = data>>(7-i) & 0x01;
        delay();
        SCL = 1;
    }
    SCL = 0;
    delay();
    SDA = 1;
    delay();
}

unsigned char read_byte(void){
    SDA_IO = INPUT;
    delay();
    SCL = 0;
    delay();
    unsigned char i,data=0;
    for(i=0;i<8;i++){
        delay();
        SCL = 1;
        delay();
        if(i >= 1)
            data <<= 1;
        if(SDA == 1){
            data += 1;
        }
        delay();
        SCL = 0;
        delay();
    }
    return data;
}

void send_ACK(void){
    SDA_IO = OUTPUT;
    delay();
    SDA = 0;
    delay();
    SCL = 1;
    delay();
    SCL = 0;
    delay();
}

void send_NACK(void){
    SDA_IO = OUTPUT;
    delay();
    SDA = 1;
    delay();
    SCL = 1;
    delay();
    SCL = 0;
    delay();
}

unsigned char receive_ACK(void){
    unsigned char result = 0; 
    SDA_IO = INPUT;
    delay();
    SCL = 1;
    delay();
    unsigned char i = 0;
    while(i < 5){
        i++;
        if(!SDA){
            result = 1;
            break;
        }
    }
    SCL = 0;
    delay();
    SDA_IO = OUTPUT;
    delay();
    return result;
}

