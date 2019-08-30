#include "config.h"

void interrupt irs_routine(void){
    // init_eusart();
    RCSTAbits.CREN = 0;
    RCSTAbits.CREN = 1;
    if (INTCONbits.TMR0IF && INTCONbits.TMR0IE){
        _switch_scan_count_unshake(); //catch true_switch_
        
        change_people();
        random_show(0,2,3);
        score = successchi(0,0,1,2,3,score);
        
        if (true_switch_ != 0 )
        {
            //seg_index[0] = true_switch_;
            PIE1bits.TXIE=1;
        }
        //_count_show(999);
        led_show(seg_index);
        INTCONbits.TMR0IF = 0;
        TMR0 = 0;
    }
    if (PIE1bits.RCIE && PIR1bits.RCIF)
    {
        LATA4 = ~LATA4;
        RC_DATA = RCREG;
        seg_index[0] = RCREG;
    }
    if (PIR1bits.TXIF && PIE1bits.TXIE){
        data_send(true_switch_);
        PIE1bits.TXIE=0;
    }
}

//set the fosc of pic
void init_fosc(void)
{
    OSCCON= 0xff;
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
    APFCON1bits.TXSEL = 1;
    APFCON1bits.RXSEL = 1;

    TXSTAbits.SYNC = 0;

    PIE1bits.RCIE = 1;
    INTCONbits.PEIE = 1;
    INTCONbits.GIE = 1;

    TXSTAbits.BRGH = 1;
    BAUDCONbits.BRG16 = 1;
    SPBRGH = 0x00;
    SPBRGL = 0x2f;  

    RCSTAbits.CREN = 1;
    TXSTAbits.TXEN = 1;  
    RCSTAbits.SPEN = 1;  //enable serial port
    
    INTCONbits.GIE=1;
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


void delay_(int delay_time){
    int i = 0;
    for(;delay_time > 0;delay_time--)
        for(i=0;i<255;i++) ;
}

void led_show(int seg_index[]){
    int delay_time = 1;
    PORTA = 0x0e;
    PORTC = seg_table[seg_index[0]];
    delay_(delay_time);
    PORTC = 0;
    
    PORTA = 0x0d;
    PORTC = seg_table[seg_index[1]];
    delay_(delay_time);
    PORTC = 0;
    
    PORTA = 0x0b;
    PORTC = seg_table[seg_index[2]];
    delay_(delay_time);
    PORTC = 0;
    
    PORTA = 0x07;
    PORTC = seg_table[seg_index[3]];
    delay_(delay_time);
    PORTC = 0;
}


//return which switch closed
int _switch_scan_step(void){
    TRISB = 0x8f;
    WPUBbits.WPUB0=1;
    WPUBbits.WPUB1=1;
    WPUBbits.WPUB2=1;
    WPUBbits.WPUB3=1;
    WPUBbits.WPUB7=1;
    if (PORTBbits.RB0 == 0) return 1;
    else if (PORTBbits.RB1 == 0) return 2;
    else if (PORTBbits.RB2 == 0) return 3;
    else if (PORTBbits.RB3 == 0) return 4;
    else{
        TRISB = 0x87;
        WPUBbits.WPUB0=1;
        WPUBbits.WPUB1=1;
        WPUBbits.WPUB2=1;
        WPUBbits.WPUB7=1;
        if (PORTBbits.RB0 == 0) return 5;
        else if (PORTBbits.RB1 == 0) return 6;
        else if (PORTBbits.RB2 == 0) return 7;
        else{
            TRISB = 0x83;
            WPUBbits.WPUB0=1;
            WPUBbits.WPUB1=1;
            WPUBbits.WPUB7=1;
            if (PORTBbits.RB0 == 0) return 8;
            else if (PORTBbits.RB1 == 0) return 9;
            else{
                TRISB = 0x81;
                WPUBbits.WPUB0=1;
                WPUBbits.WPUB7=1;
                if(PORTBbits.RB0 == 0) return 10;
                else return 0;
            }
        }
    }
}

//switch count
void _switch_scan_count_unshake(void){
    int switch_now = _switch_scan_step();
    if (switch_now == pre_switch){
        _unshake_switch_delay_count++;
        if (_unshake_switch_delay_count == 2){
            _unshake_switch_delay_count = 0;
            if (true_switch_ == 0 && switch_now!=0){ 
                _count_of_switch++;
            }
            true_switch_ = switch_now;
            return;
        }
        else return;
    } 
    pre_switch = switch_now;
    return;
}

void _count_show(int max_number_show){
    if (_count_of_switch > max_number_show)
        _count_of_switch = 0;
    int bit_count_tmp = _count_of_switch;
     for (int i = 3; i >= 1; i--){
         seg_index[i] = bit_count_tmp % 10;
         bit_count_tmp = bit_count_tmp / 10;
    }
}


void data_send(unsigned char data){
    TXREG = data;
    while(TRMT == 0) ;
}



//?????
unsigned char random(unsigned char xxx)
{
    unsigned char value;
    srand(xxx);
    value = rand() % (9 + 1 - 0) + 0; //???????(0-9)
    return value;
}

void random_show(unsigned char seed, unsigned char whitch_seg1, unsigned char whitch_seg2)
{
    unsigned char chi_index_x = random(seed);
    unsigned char chi_index_y = random(seed + 1);
    seg_index[whitch_seg1] = chi_index_x;
    seg_index[whitch_seg2] = chi_index_y;
}

unsigned char successchi(unsigned char seed,unsigned char snake_x, unsigned char snake_y, unsigned char doudou_x,  unsigned char doudou_y, unsigned char score)
{
    if ((seg_index[snake_x] == seg_index[doudou_x]) && (seg_index[snake_y] == seg_index[doudou_y]))
    {
        random_show(seed,doudou_x, doudou_y);
        score++;
    }
    return score;
}


void change_people(){
    if (true_switch_ != 0)
    {             
        switch(true_switch_)
            {
            case 2:
                if(people_position[0]!=0&&seg_index[0]!=people_position[0]) people_position[0]-=1;
                break;
            case 5:
                if(people_position[1]!=0&&seg_index[1]!=people_position[1]) people_position[1]-=1;
                break;
            case 7:
                if(people_position[1]!=9&&seg_index[1]!=people_position[1]) people_position[1]+=1;
                break;
            case 9:
                if(people_position[0]!=9&&seg_index[0]!=people_position[0]) people_position[0]+=1;
                break;
            default:
                people_position[0]=people_position[0];
                people_position[1]=people_position[1];
                break;
            }
    }
    seg_index[0] = people_position[0];
    seg_index[1] = people_position[1];
}