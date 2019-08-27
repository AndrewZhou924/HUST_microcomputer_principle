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
//int[] STABLE = {};
//int[] TABLE  = {}

// 函数声明区
void SETORIGIN(void);
void INICIALISE(void);
void SETCOFFSET(void);
void SETPA(void);
void SELECT(void);
void WRITE(void);
void REFRESH_SHOW(void);
void KEYSCAN(void);

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

int main() {
    INICIALISE();
    
    while(1) {
        KEY_VALUE_LAST = KEY_VALUE;
        ISPRESS_LAST   = ISPRESS;

        KEYSCAN();

        if (KEY_VALUE != KEY_VALUE_LAST) 
            REFRESH_SHOW();

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
    TMR0 = 252;
    if (PIR1bits.TMR1IF == 1) 
        goto TMR1_INT_ISR;
    return;

    TMR1_INT_ISR:
    if (STOP_WATCH <= 254) 
        STOP_WATCH++;
    PIR1bits.TMR1IF = 0;
    TMR1H = 243;
    TMR1L = 199;
    return;

    TMR0_INT_ISR:
    NUM = CNUM;
    OFFSET = PA;

    SELECT();
    WRITE();

    PA--;
    CNUM++;
    CNT--;
    if (PA <= 0)
        SETPA();
    if (CNT <= 0)
        SETORIGIN();   
    INTCONbits.TMR0IF=0;    
    TMR0 = 252;     
    return;
}

// 程序初始化
void INICIALISE(void) {
    // OSCCON = ob01011000;
    OSCCON = 0x58;

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

//    PORTC = ?
}

void WRITE(void) {
//    LATA = ?
}

void KEYSCAN(void) {
    KEY_1();
    KEY_2();
    KEY_3();
    KEY_4();

    // ?
    ISPRESS = 0;
}

void KEY_1(void) {
    TRISB = 0b11111111;
    WPUB  = 0b11111111;
    if (PORTBbits.RB0 == 0)
        DELAY();  
    if (PORTBbits.RB0 == 0)
        KEY7();    

    if (PORTBbits.RB1 == 0)
        DELAY();  
    if (PORTBbits.RB1 == 0)
        KEY8();   

    if (PORTBbits.RB2 == 0)
        DELAY();  
    if (PORTBbits.RB2 == 0)
        KEY9(); 

    if (PORTBbits.RB3 == 0)
        DELAY();  
    if (PORTBbits.RB3 == 0)
        KEY10();          
}

void KEY_2(void) {
    TRISB = 0b11111110;
    WPUB  = 0b11111110;  

    if (PORTBbits.RB1 == 0)
        DELAY();  
    if (PORTBbits.RB1 == 0)
        KEY5();   

    if (PORTBbits.RB2 == 0)
        DELAY();  
    if (PORTBbits.RB2 == 0)
        KEY1(); 

    if (PORTBbits.RB3 == 0)
        DELAY();  
    if (PORTBbits.RB3 == 0)
        KEY2();  
}

void KEY_3(void) {
    TRISB = 0b11111101;
    WPUB  = 0b11111101; 

    if (PORTBbits.RB2 == 0)
        DELAY();  
    if (PORTBbits.RB2 == 0)
        KEY3(); 

    if (PORTBbits.RB3 == 0)
        DELAY();  
    if (PORTBbits.RB3 == 0)
        KEY4();  
}

void KEY_4(void) {
    TRISB = 0b11111011;
    WPUB  = 0b11111011;

    if (PORTBbits.RB3 == 0)
        DELAY();  
    if (PORTBbits.RB3 == 0)
        KEY6();  
}

void KEY1(void) {
    KEY_VALUE = 1;
    ISPRESS   = 1;
}

void KEY2(void) {
    KEY_VALUE = 2;
    ISPRESS   = 1;
}

void KEY3(void) {
    KEY_VALUE = 3;
    ISPRESS   = 1;
}

void KEY4(void) {
    KEY_VALUE = 4;
    ISPRESS   = 1;
}

void KEY5(void) {
    KEY_VALUE = 5;
    ISPRESS   = 1;
}

void KEY6(void) {
    KEY_VALUE = 6;
    ISPRESS   = 1;
}

void KEY7(void) {
    KEY_VALUE = 7;
    ISPRESS   = 1;
}

void KEY8(void) {
    KEY_VALUE = 8;
    ISPRESS   = 1;
}

void KEY9(void) {
    KEY_VALUE = 9;
    ISPRESS   = 1;
}

void KEY10(void) {
    KEY_VALUE = 10;
    ISPRESS   = 1;
}

void DELAY(void) {
    // sleep ???
    for (int i=0; i<1; i++) {
        for (int j=0; j<5; j++) {
//            pass;
        }
    }
}

void CASE1(void) {
    if (KEY_FLAG == 0)
        return;
    if (STOP_WATCH >= 15) {
        KEY_STATE = 1;
        COFFSET   = 44;
    }
    return;   
}

void CASE2(void) {
    REFRESH_SHOW();
    if (KEY_FLAG != 0) {
        KEY_FLAG  = 1;
        KEY_STATE = 0;

        if (KEY_VALUE == KEY_VALUE_LAST) {
            if (STOP_WATCH <= 10) {
                KEY_STATE = 2;
                KEY_FLAG = 0;
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
        if (STOP_WATCH < 20)
            return;

        KEY_STATE = 3;  
        COFFSET = 52;
        CNUM = 1;
        PA = COFFSET;
        CNT = 4;
        return;    

    } else {
        if (STOP_WATCH > 5)
            return;
        KEY_STATE = 0;
        KEY_FLAG = 0;   
        COFFSET = 56;
        CNUM = 1;
        PA = COFFSET;
        CNT = 4;
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