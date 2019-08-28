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

int OFFSET = 0x00;
int COFFSET	= 0x00;
int NUM	= 0x00;
int CNUM = 0x00;
int PA	= 0x00;
int CNT	= 0x00;
int ADC_VALUE = 0X00;
long ADC_H = 0x00;
long ADC_L = 0x00;

void INICIALISE(void);
void SELECT(void);
void WRITE(void);
void ADCSCAN(void);
void DELAY(void);

int STABLE[] ={0b00000001,0b00000010,0b00000100,0b00001000};
int TABLE[] = {0xc0,0xf9,0xa4,0xb0,0x99,0x92,0x82,0xf8,0x80,0x90};

int main() {
    INICIALISE();
    ADCON0 = 0B10110101;
    ADCON1 = 0B01000000;
    //ADCON2 = 0B00001111;
    ADRESH = 0B00000000;
    ADRESL = 0B00000000;
   
    ADCSCAN();
}

void INICIALISE() {
    OSCCON = 0b01101000;//41Mhz
    TRISA = 0;
    LATA  = 0;
    ANSELA = 0b00000000;
    TRISB = 0b111111111;//RB5输入 AN13
    ANSELB = 0b11111111;//RB5模拟
    WPUB = 0b11111111;//弱上啦
    TRISC = 0;
    LATC = 0;
    
    ADCON0 = 0B10110101;
    ADCON1 = 0B01000000;
//    ADCON2 = 0B00001111;
    
    COFFSET = 10;
    CNUM = 1;
    PA = COFFSET;
    CNT = 4;
}
void DELAY(void) {
//    for (int i=0; i<10; i++) {
//        for (int j=0; j<6; j++) {
////            pass;
//        }
//    }
        for (int i=0; i<1; i++) {
            for (int j=0; j<10; j++) {
//            pass;
        }
    }
}

void ADCSCAN() {
    ADCON0 = 0B10110101;
    ADCON1 = 0B01000000;
    //ADCON2 = 0B00001111;
    ADCON0bits.GO_nDONE=1;//启动ADC
    do {}
    while( ADCON0bits.GO_nDONE);
    
    ADC_H = ADRESH;
    ADC_L = ADRESL;
    ADC_H = ADC_H<<2;
    ADC_VALUE = ADC_L|ADC_H;
}