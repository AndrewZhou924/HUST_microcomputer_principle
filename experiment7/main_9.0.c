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
int NUMBER_SHOW = 6784;
int STABLE[] = {0b00000001,0b00000010,0b00000100,0b00001000};
int NUMBER_TO_SHOW[] = {0XC0, 0XF9, 0XA4, 0XB0, 0X99, 0X92, 
                        0X82, 0XF8, 0X80, 0X90};   
static unsigned char RC_DATA ;
static int DATA_TO_SEND = 0;

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
// ============= ex7 =============================
void init_fosc(void);
void init_initcont(void);
void init_gpio(void);
void init_timer0(void);
void init_eusart(void);
void data_send(unsigned char data);
// ===============================================
// ========== keyboard ===========================
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
// ===============================================
int main() {
    
    INICIALISE();

    // init_fosc();
    // init_gpio();
    // init_timer0();
    // init_initcont();
    init_eusart();
    
    INTCONbits.GIE=1;       
    INTCONbits.TMR0IF=0;
    INTCONbits.TMR0IE=1;
    INTCONbits.PEIE=1;
    T1CONbits.TMR1ON=1;
    PIR1bits.TMR1IF=0;
    PIE1bits.TMR1IE=1;

    while(1) {    
        // send message
        PIE1bits.RCIE = 1;
        
//        PIE1bits.TXIE=1;
        DATA_TO_SEND = 3;
        data_send(DATA_TO_SEND);
//        PIE1bits.TXIE=0;

        // scan keyboard
        KEY_VALUE_LAST = KEY_VALUE;
        ISPRESS_LAST   = ISPRESS;

        KEYSCAN();
        DATA_TO_SEND = KEY_VALUE;
        
        if (ISPRESS == 1)
            NUMBER_SHOW = KEY_VALUE;
        
    };
}

void interrupt irs_routine(void) {
    // init_eusart();
//    RCSTAbits.CREN = 0;
    RCSTAbits.CREN = 1;

    if (INTCONbits.TMR0IF == 1) {
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
    }

    if (PIR1bits.TMR1IF == 1) {
        if (STOP_WATCH <= 254) 
        STOP_WATCH++;
        PIR1bits.TMR1IF = 0;
        TMR1H = 0b11110011;
        TMR1L = 0b11000111;
    }
    
     if (PIE1bits.RCIE && PIR1bits.RCIF) {
//          TODO 控制灯亮与灭
//          LATA4 = ~LATA4;
         RC_DATA = RCREG;
         if (RC_DATA != 0 && RC_DATA)
            NUMBER_SHOW = (int)RC_DATA;
         
//         PIE1bits.RCIE = 0;
     }

    if (PIR1bits.TXIF && PIE1bits.TXIE) {
        data_send(DATA_TO_SEND);
        PIE1bits.TXIE=0;
    }
    
//    TMR0 = 254;  
//    INTCONbits.TMR0IF=0;
}

//set the fosc of pic
void init_fosc(void)
{
    // OSCCON= 0xff;
    OSCCON = 0b01101000;
}

//set initcontrol of pic
void init_initcont(void){
    INTCONbits.GIE=1;       
    INTCONbits.TMR0IF=0;
    INTCONbits.TMR0IE=1;
}

//set io porta,portc as output, portb as input
void init_gpio(void)
{
    PORTA = 0;
    LATA = 0;
    ANSELA = 0;
    TRISA=0;
    
    PORTC = 0;
    LATC = 0;
    TRISC = 0;

    PORTB = 0xff;
    LATB = 0;
    ANSELB = 0;
    TRISB = 0x8f;
    WPUBbits.WPUB0=1;
    WPUBbits.WPUB1=1;
    WPUBbits.WPUB2=1;
    WPUBbits.WPUB3=1;
    WPUBbits.WPUB7=1;
    WPUBbits.WPUB7=1;
}

//set timer0
void init_timer0(void)
{
    OPTION_REG=0x40;
}

void init_eusart(void){
    APFCON1bits.TXSEL = 0;
    APFCON1bits.RXSEL = 0;//选择RC6为TX，选择RC7为RX

    TXSTAbits.SYNC = 0;//异步方式
    TXSTAbits.BRGH = 1;//高波特率
    BAUDCONbits.BRG16 = 1;//16位波特率
    
    PIE1bits.RCIE = 1;//允许接收中断
    INTCONbits.PEIE = 1;
    INTCONbits.GIE = 1;//允许全局中断
    
    SPBRGH = 0x03;
    SPBRGL = 0x41;  //波特率4800

    RCSTAbits.CREN = 1;//使能接收
    TXSTAbits.TXEN = 1;//使能发送
    RCSTAbits.SPEN = 1;  //enable serial port
    
    INTCONbits.GIE=1;
    PORTB = 0x0;
    LATB = 0;
    ANSELB = 0;
    TRISB = 0xff;
    WPUB = 0x11111111;
    
    PORTA = 0x0;
    LATA = 0;
    ANSELA = 0;
    TRISA = 0x0;

    TRISC = 0x80;  //RC6输出，RC7输入
}


void delay_(int delay_time){
    int i = 0;
    for(;delay_time > 0;delay_time--)
        for(i=0;i<255;i++) ;
}

void data_send(unsigned char data) {
    while(TRMT == 0) ;
    TXREG = 123;
    
}

// //return which switch closed
// int _switch_scan_step(void){
//     TRISB = 0x8f;
//     WPUBbits.WPUB0=1;
//     WPUBbits.WPUB1=1;
//     WPUBbits.WPUB2=1;
//     WPUBbits.WPUB3=1;
//     WPUBbits.WPUB7=1;
//     if (PORTBbits.RB0 == 0) return 1;
//     else if (PORTBbits.RB1 == 0) return 2;
//     else if (PORTBbits.RB2 == 0) return 3;
//     else if (PORTBbits.RB3 == 0) return 4;
//     else{
//         TRISB = 0x87;
//         WPUBbits.WPUB0=1;
//         WPUBbits.WPUB1=1;
//         WPUBbits.WPUB2=1;
//         WPUBbits.WPUB7=1;
//         if (PORTBbits.RB0 == 0) return 5;
//         else if (PORTBbits.RB1 == 0) return 6;
//         else if (PORTBbits.RB2 == 0) return 7;
//         else{
//             TRISB = 0x83;
//             WPUBbits.WPUB0=1;
//             WPUBbits.WPUB1=1;
//             WPUBbits.WPUB7=1;
//             if (PORTBbits.RB0 == 0) return 8;
//             else if (PORTBbits.RB1 == 0) return 9;
//             else{
//                 TRISB = 0x81;
//                 WPUBbits.WPUB0=1;
//                 WPUBbits.WPUB7=1;
//                 if(PORTBbits.RB0 == 0) return 10;
//                 else return 0;
//             }
//         }
//     }
// }

//switch count
// void _switch_scan_count_unshake(void){
//     int switch_now = _switch_scan_step();
//     if (switch_now == pre_switch){
//         _unshake_switch_delay_count++;
//         if (_unshake_switch_delay_count == 2){
//             _unshake_switch_delay_count = 0;
//             if (true_switch_ == 0 && switch_now!=0){ 
//                 _count_of_switch++;
//             }
//             true_switch_ = switch_now;
//             return;
//         }
//         else return;
//     } 
//     pre_switch = switch_now;
//     return;
// }

// void _count_show(int max_number_show){
//     if (_count_of_switch > max_number_show)
//         _count_of_switch = 0;
//     int bit_count_tmp = _count_of_switch;
//      for (int i = 3; i >= 1; i--){
//          seg_index[i] = bit_count_tmp % 10;
//          bit_count_tmp = bit_count_tmp / 10;
//     }
// }

// unsigned char random(unsigned char xxx)
// {
//     unsigned char value;
//     srand(xxx);
//     value = rand() % (9 + 1 - 0) + 0; //???????(0-9)
//     return value;
// }

// void random_show(unsigned char seed, unsigned char whitch_seg1, unsigned char whitch_seg2)
// {
//     unsigned char chi_index_x = random(seed);
//     unsigned char chi_index_y = random(seed + 1);
//     seg_index[whitch_seg1] = chi_index_x;
//     seg_index[whitch_seg2] = chi_index_y;
// }

// unsigned char successchi(unsigned char seed,unsigned char snake_x, unsigned char snake_y, unsigned char doudou_x,  unsigned char doudou_y, unsigned char score)
// {
//     if ((seg_index[snake_x] == seg_index[doudou_x]) && (seg_index[snake_y] == seg_index[doudou_y]))
//     {
//         random_show(seed,doudou_x, doudou_y);
//         score++;
//     }
//     return score;
// }


// void change_people(){
//     if (true_switch_ != 0)
//     {             
//         switch(true_switch_)
//             {
//             case 2:
//                 if(people_position[0]!=0&&seg_index[0]!=people_position[0]) people_position[0]-=1;
//                 break;
//             case 5:
//                 if(people_position[1]!=0&&seg_index[1]!=people_position[1]) people_position[1]-=1;
//                 break;
//             case 7:
//                 if(people_position[1]!=9&&seg_index[1]!=people_position[1]) people_position[1]+=1;
//                 break;
//             case 9:
//                 if(people_position[0]!=9&&seg_index[0]!=people_position[0]) people_position[0]+=1;
//                 break;
//             default:
//                 people_position[0]=people_position[0];
//                 people_position[1]=people_position[1];
//                 break;
//             }
//     }
//     seg_index[0] = people_position[0];
//     seg_index[1] = people_position[1];
// }

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

    // TRISA = 0;
    // LATA  = 0;
    // ANSELA = 0b00000000;
    // TRISB = 0b00000000;
    // LATB = 0;
    // ANSELB = 0b00000000;
    // WPUB = 0b11111111;
    // TRISC = 0;
    // LATC = 0;

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

void SELECT(void) {
    // LATA  = 0b11111111;
    // PORTB = 0b11111111;   
    // PORTB = STABLE[NUM-1];

    LATA  = 0b11111111;
    PORTC = 0b11111111;   
    PORTC = STABLE[NUM-1];
}

// keyboard
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
