/*
 * File:   main.c
 * Author: LiuYi
 *
 * Created on 2019年8月27日, 下午7:25
 */

#include <xc.h>
#include <pic16f1786.h>

// Config 1
#pragma config FOSC = INTOSC
#pragma config WDTE = OFF
#pragma config PWRTE = OFF
#pragma config MCLRE = ON
#pragma config CP = OFF
#pragma config CPD = OFF
#pragma config BOREN = OFF
#pragma config CLKOUTEN = OFF
#pragma config IESO = OFF
#pragma config FCMEN = ON
// Config 2
#pragma config WRT = OFF
#pragma config VCAPEN = OFF
#pragma config PLLEN = ON
#pragma config STVREN = ON
#pragma config BORV = LO
#pragma config LPBOR = OFF
#pragma config LVP = ON



#define SYSFREQ 500000
#define TMR1FREQ (SYSFREQ)
#define TMR1CNT (TMR1FREQ/200)
#define TMR1VALUE (65536-TMR1CNT)

static unsigned char placeNum = 0;
static unsigned char seg[4];
static unsigned char index = 0;
static unsigned char rectemp = 0;
static unsigned char pressed = 0;
static unsigned char btn = 0;

const unsigned char kSegs[] = {
    0xc0, // 0
    0xf9,
    0xa4,
    0xb0,
    0x99,
    0x92, // 5
    0x82,
    0xf8,
    0x80,
    0x90,
    0x88, // a
    0x83,
    ~0x39,
    ~0x5e,
    ~0x79,
    ~0x71
};

void tmr0_int(void);
void tmr1_int(void);
void rec_int(void);
void uart_write(unsigned char value);
unsigned char uart_read(void);

void main(void) {
    init:{
        // Timer 0
        /*
         * CS: INTOSC/4
         * Prescaler: 256
         */
        OPTION_REGbits.nWPUEN = 0;
        OPTION_REGbits.INTEDG = 1;
        OPTION_REGbits.TMR0CS = 0;
        OPTION_REGbits.PSA = 0;
        OPTION_REGbits.PS = 0b111;
        // GPIO

        WPUB = 0xff;
        WPUA = 0xff;
        TRISC = 0b10011011;
        TRISB = 0b11001111;
        TRISA = 0x00;
        ANSELA = 0x00;
        ANSELB = 0x00;

        // Timer 1
        T1CONbits.TMR1CS = 0b01; // INTOSC required 
        T1CONbits.T1CKPS = 0b00; // 1:1 prescaler
        TMR1 = 0;
        T1GCONbits.TMR1GE = 0;
        PIR1bits.TMR1IF = 0;
        // Oscillator
        OSCCONbits.IRCF = 0b1101; //4Mhz
        OSCCONbits.SCS1 = 1; // INTOSC required
        // Interrupt
        PIE1bits.TMR1IE = 1;
        INTCONbits.GIE = 1;
        INTCONbits.PEIE = 1;
        INTCONbits.TMR0IE = 1;
        
        //EUSART
        APFCON1bits.TXSEL = 0;
        APFCON1bits.RXSEL = 0;
        TXSTAbits.TXEN = 1;
        RCSTAbits.CREN = 1;
        TXSTAbits.SYNC = 0;
        RCSTAbits.SPEN = 1;
        PIE1bits.RCIE = 1;
//        PIE1bits.TXIE = 1;
        //BRG
        BAUDCONbits.BRG16 = 1;
        TXSTAbits.BRGH = 1;
        SPBRGH = 0xff;
        SPBRGL = 0xff;
        
        // Special setup
        T1CONbits.TMR1ON = 1; // Trigger the TMR1
        seg[0] = 0xff;
        seg[1] = 0xff;
        seg[2] = 0xff;
        seg[3] = 0xff;
    }
    while(1){};
}

void interrupt irs(void) {
    if(INTCONbits.TMR0IF) tmr0_int();
    else if(PIR1bits.TMR1IF) tmr1_int();
    else if(PIR1bits.RCIF) rec_int();

    return;
}

void rec_int(){
    rectemp = uart_read();
    seg[0] = kSegs[rectemp];    
    return;
}

void uart_wait(void){
    return;
}

void uart_write(unsigned char value){
    while(TXSTAbits.TRMT == 0);
    TXREG = value;
    return;
}

unsigned char uart_read(void){
    return RCREG;
}


void tmr0_int(void){
    //check1234
    {

        TRISBbits.TRISB1 = 1;
        TRISBbits.TRISB2 = 1;
        TRISCbits.TRISC0 = 1;
        TRISCbits.TRISC1 = 1;
       
        pressed = 0x0;
        
        //check1
        if(PORTCbits.RC1 == 0){
            pressed = 0x1;
            btn = 0x1;
        }
        //check2
        else if(PORTCbits.RC0 == 0){
            pressed = 0x1;
            btn = 0x2;
        }
        //check3
        else if(PORTBbits.RB2 == 0){
            pressed = 0x1;
            btn = 0x3;
        }
        //check4
        else if(PORTBbits.RB1 == 0){
            pressed = 0x1;
            btn = 0x4;
        }    
    }
    
    //check567
    if(pressed == 0x0){
        
        TRISBbits.TRISB1 = 1;
        TRISBbits.TRISB2 = 1;
        TRISCbits.TRISC0 = 1;
        TRISCbits.TRISC1 = 0;
        
        PORTCbits.RC1 = 0;
        
        //check5
        if(PORTCbits.RC0 == 0){
            pressed = 0x1;
            btn = 0x5;
        }
        //check6
        else if(PORTBbits.RB2 == 0){
            pressed = 0x1;
            btn = 0x6;
        }
        //check7
        else if(PORTBbits.RB1 == 0){
            pressed = 0x1;
            btn = 0x7;
        }
    }
    
    //check89
    if(pressed == 0x0){
        
        TRISBbits.TRISB1 = 1;
        TRISBbits.TRISB2 = 1;
        TRISCbits.TRISC0 = 0;
        TRISCbits.TRISC1 = 0;
        
        PORTCbits.RC0 = 0;
        
        //check8
        if(PORTBbits.RB2 == 0){
            pressed = 0x1;
            btn = 0x8;
        }
        //check9
        else if(PORTBbits.RB1 == 0){
            pressed = 0x1;
            btn = 0x9;
        }
    }
    
    //check10
    if(pressed == 0x0){
        
        TRISBbits.TRISB1 = 1;
        TRISBbits.TRISB2 = 0;
        TRISCbits.TRISC0 = 0;
        TRISCbits.TRISC1 = 0;
        
        PORTBbits.RB2 = 0;
        
        //check10
        if(PORTBbits.RB1 == 0){
            pressed = 0x1;
            btn = 0x0a;
        }
    }

//    seg[0] = kSegs[btn];
    if(pressed)
        uart_write(btn);
    
    INTCONbits.TMR0IF = 0;
}

void tmr1_int(void){
    T1CONbits.TMR1ON = 0;
    TMR1 = TMR1VALUE;
    
    LATA = 0xff;
    switch(placeNum){
        case 0:
            LATBbits.LATB5 = 1;
            LATBbits.LATB4 = 0;
            LATCbits.LATC5 = 0;
            LATCbits.LATC2 = 0;
            break;
        case 1:
            LATBbits.LATB5 = 0;
            LATBbits.LATB4 = 1;
            LATCbits.LATC5 = 0;
            LATCbits.LATC2 = 0;
            break;
        case 2:
            LATBbits.LATB5 = 0;
            LATBbits.LATB4 = 0;
            LATCbits.LATC5 = 1;
            LATCbits.LATC2 = 0;
            break;
        case 3:
            LATBbits.LATB5 = 0;
            LATBbits.LATB4 = 0;
            LATCbits.LATC5 = 0;
            LATCbits.LATC2 = 1;
            break;
    };
    
    LATA = seg[placeNum];
    placeNum = (placeNum+1)%4;
    
    PIR1bits.TMR1IF = 0;
    T1CONbits.TMR1ON = 1;
}
