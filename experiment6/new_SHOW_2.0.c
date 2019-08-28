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
int NUMBER_SHOW = 9876;
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

// 函数声明区
void SETORIGIN(void);
void INICIALISE(void);
void SETCOFFSET(void);
void SETPA(void);
void SELECT(void);
void WRITE(void);
void REFRESH_SHOW(void);
void REFRESH_SHOW_2(void);
void KEYSCAN(void);
void SHOW_WITH_NUMBER(int number); 

void KEY_1(void);
void KEY_2(void);
void KEY_3(void);
void KEY_4(void);

void KEY1(void);
void KEY2(void);
void KEY3(void);
void KEY4(void);
void KEY5(void);
void KEY6(void);
void KEY7(void);
void KEY8(void);
void KEY9(void);
void KEY10(void);
void DELAY(void);

void CASE1(void);
void CASE2(void);
void CASE3(void);
void CASE4(void);

int ReadEE(char addr);
void WriteEE(char addr,int data);
int EEPROM_buf; //读写数据的储存空间
int EEPROM_ADDR = 0x15;


int main() {
    INICIALISE();
    INTCONbits.GIE=1; 
          
    INTCONbits.TMR0IF=0;
    INTCONbits.TMR0IE=1;
    
    INTCONbits.PEIE=1;
    T1CONbits.TMR1ON=1;
    PIR1bits.TMR1IF=0;
    PIE1bits.TMR1IE=1;

    // test EEPROM
    char temp_char = 'k';
    char temp_int = 9;
    
    // WriteEE(EEPROM_ADDR,temp_int); //将0x66写入EEPROM_ADDR地址的EEROM中
    EEPROM_buf = ReadEE(EEPROM_ADDR); //将EEPROM_ADDR地址中的数据读出，并将他放到BUF中
    if (EEPROM_buf >= 1 && EEPROM_buf <= 10)
        COFFSET = 4*EEPROM_buf;

    
    while(1) {
        KEY_VALUE_LAST = KEY_VALUE;
        ISPRESS_LAST   = ISPRESS;

        KEYSCAN();
      
        if (KEY_VALUE != KEY_VALUE_LAST) 
            REFRESH_SHOW_2();
            // REFRESH_SHOW();

        if (ISPRESS == 0){
            if (ISPRESS_LAST == 0) CASE1();
            else CASE4();
        } else {
            if (ISPRESS_LAST == 0) CASE2();
            else CASE3();
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
    // WRITE();
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

void SELECT(void) {
    LATA  = 0b11111111;
    PORTC = 0b11111111;   
    
    PORTC = STABLE[NUM-1];
}

void WRITE(void) {
    LATA = TABLE[OFFSET-1];
}

void KEYSCAN(void) {
    ISPRESS = 0;
    KEY_1();
    KEY_2();
    KEY_3();
    KEY_4();
}

void KEY_1(void) {
    TRISB = 0b11111111;
    WPUB  = 0b11111111;
    if (ISPRESS==1){
        return;
    }
    if (PORTBbits.RB0 == 0)
        DELAY();  
    if (PORTBbits.RB0 == 0)
        KEY7();    
    if (ISPRESS==1){
        return;
    }
    if (PORTBbits.RB1 == 0)
        DELAY();  
    if (PORTBbits.RB1 == 0)
        KEY8();   
    if (ISPRESS==1){
        return;
    }
    if (PORTBbits.RB2 == 0)
        DELAY();  
    if (PORTBbits.RB2 == 0)
        KEY9(); 
    if (ISPRESS==1){
        return;
    }
    if (PORTBbits.RB3 == 0)
        DELAY();  
    if (PORTBbits.RB3 == 0)
        KEY10();          
}

void KEY_2(void) {
    TRISB = 0b11111110;
    WPUB  = 0b11111110;  
    if (ISPRESS==1){
        return;
    }
    if (PORTBbits.RB1 == 0)
        DELAY();  
    if (PORTBbits.RB1 == 0)
        KEY5();   
    if (ISPRESS==1){
        return;
    }
    if (PORTBbits.RB2 == 0)
        DELAY();  
    if (PORTBbits.RB2 == 0)
        KEY1(); 
    if (ISPRESS==1){
        return;
    }
    if (PORTBbits.RB3 == 0)
        DELAY();  
    if (PORTBbits.RB3 == 0)
        KEY2();  
}

void KEY_3(void) {
    TRISB = 0b11111101;
    WPUB  = 0b11111101; 
    if (ISPRESS==1){
        return;
    }
    if (PORTBbits.RB2 == 0)
        DELAY();  
    if (PORTBbits.RB2 == 0)
        KEY3(); 
    if (ISPRESS==1){
        return;
    }
    if (PORTBbits.RB3 == 0)
        DELAY();  
    if (PORTBbits.RB3 == 0)
        KEY4();  
}

void KEY_4(void) {
    TRISB = 0b11111011;
    WPUB  = 0b11111011;
    if (ISPRESS==1){
        return;
    }
    if (PORTBbits.RB3 == 0)
        DELAY();  
    if (PORTBbits.RB3 == 0)
        KEY6();  
}

void KEY1(void) {
    KEY_VALUE = 1;
    ISPRESS   = 1;
    WriteEE(EEPROM_ADDR,1);
}

void KEY2(void) {
    KEY_VALUE = 2;
    ISPRESS   = 1;
    WriteEE(EEPROM_ADDR,2);
    
}

void KEY3(void) {
    KEY_VALUE = 3;
    ISPRESS   = 1;
    WriteEE(EEPROM_ADDR,3);
    
}

void KEY4(void) {
    KEY_VALUE = 4;
    ISPRESS   = 1;
    WriteEE(EEPROM_ADDR,4);
}

void KEY5(void) {
    KEY_VALUE = 5;
    ISPRESS   = 1;
    WriteEE(EEPROM_ADDR,5);
}

void KEY6(void) {
    KEY_VALUE = 6;
    ISPRESS   = 1;
    WriteEE(EEPROM_ADDR,6);
}

void KEY7(void) {
    KEY_VALUE = 7;
    ISPRESS   = 1;
    WriteEE(EEPROM_ADDR,7);
}

void KEY8(void) {
    KEY_VALUE = 8;
    ISPRESS   = 1;
    WriteEE(EEPROM_ADDR,8);
}

void KEY9(void) {
    KEY_VALUE = 9;
    ISPRESS   = 1;
    WriteEE(EEPROM_ADDR,9);
}

void KEY10(void) {
    KEY_VALUE = 10;
    ISPRESS   = 1;
    WriteEE(EEPROM_ADDR,10);
}

void DELAY(void) {
//    for (int i=0; i<10; i++) {
//        for (int j=0; j<6; j++) {
////            pass;
//        }
//    }
        for (int i=0; i<1; i++) {
            for (int j=0; j<5; j++) {
//            pass;
        }
    }
}

void CASE1(void) {
    if (KEY_FLAG == 0)
        return;
    if (STOP_WATCH >= 30) { // T1
        KEY_STATE = 1;
        COFFSET   = 44;
        NUMBER_SHOW = 1111;
    }
    return;   
}

void CASE2(void) {
    // REFRESH_SHOW();
    REFRESH_SHOW_2();
    if (KEY_FLAG != 0) {
        KEY_FLAG  = 1;
        KEY_STATE = 0;

        if (KEY_VALUE == KEY_VALUE_LAST) {
            if (STOP_WATCH <= 20) { // T2
                KEY_STATE = 2;
                KEY_FLAG = 0;

                NUMBER_SHOW = 2222;
                COFFSET = 48;
                CNUM = 1;
                PA = COFFSET;
                CNT = 4;
            } 
        }
    } else {
        KEY_FLAG  = 1;
        KEY_STATE = 0;
    }

    STOP_WATCH = 0;
    return;
}

void CASE3(void) {
    if (KEY_VALUE == KEY_VALUE_LAST) {
        if (KEY_FLAG == 0)
            return;
        if (STOP_WATCH < 50) // T3 
            return;

        KEY_STATE = 3;  
        COFFSET = 52;
        CNUM = 1;
        PA = COFFSET;
        CNT = 4;
        NUMBER_SHOW = 3333;
        return;    

    } else {
        // TODO bug fix
        // if (STOP_WATCH > 20)
        //     return;
        // KEY_STATE = 0;
        // KEY_FLAG = 0;   
        // COFFSET = 56;
        // CNUM = 1;
        // PA = COFFSET;
        // CNT = 4;
        return;
    }
}

void CASE4(void) {
    if (KEY_STATE == 3) {
        STOP_WATCH = 15;
        KEY_FLAG = 0;
    } else {
        STOP_WATCH = 0;
    }
}

void REFRESH_SHOW(void) {
    COFFSET = KEY_VALUE*4;
    CNUM = 1;
    PA = COFFSET;
    CNT = 4;
}

//EEPROM读数据函数
int ReadEE(char addr) {
    int num;
    do{}
    while(RD == 1); //等待读完成
    EEADR = addr; //写入要读的址址
    EEPGD = 0;    //操作EEPROM
    RD = 1;       //执行读操作
    do{}
    while(RD == 1); //等待读完成
    num = EEDATA;
    return num;//返回读取的数据
}

//EEPROM写数据函数
void WriteEE(char addr,int data) {
    do{}
    while(WR == 1);//等待写完成
    EEADR = addr;//写入地址信息
    EEDATA = data;//写入数据信息
    EEPGD = 0;//操作EEPROM
    WREN = 1; //写EEPROM允许
    EECON2 = 0x55;//写入特定时序
    EECON2 = 0xaa;
    WR = 1; //执行写操作
    do{}
    while(WR == 1);//等待写完成
    WREN = 0;//禁止写入EEPROM
}

void SHOW_WITH_NUMBER(int number) {
    int index;
    
    switch (NUM) {
    case 1: //最高位
        index = (int)(number/1000) % 10;
        break;
    case 2:
        index = (int)(number/100) % 10;
        break;
    case 3:
        index = (int)(number/10) % 10;
        break;        
    case 4: // 最低位，个位
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