#include<pic.h>

__CONFIG(FOSC_INTOSC&WDTE_OFF&PWRTE_ON&MCLRE_OFF&CP_ON&CPD_OFF&BOREN_ON

                   &CLKOUTEN_OFF&IESO_ON&FCMEN_ON);//这个要放到上一行去

__CONFIG(PLLEN_OFF&LVP_OFF) ;

unsigned char RC_DATA;

unsigned char RC_FLAG;

void init_fosc(void)

{

 OSCCON = 0xF0;//32MHz

}

void init_eusart()

{

    APFCONbits.TXCKSEL = 1;//RA0

    APFCONbits.RXDTSEL = 1;//RA1

    TRISA1 = 1;//RA1 RX input

    ANSELAbits.ANSA1=0;

    SPBRGH = 0x00;//

    SPBRGL = 0x44;// Baud rate 115200

    TXSTAbits.BRGH   =1; //high speed

    BAUDCONbits.BRG16  =1; //16bit Baud rate Generator is used

    TXSTAbits.SYNC   =0; //Asynchronous mode

    PIE1bits.RCIE = 1; //enables the USART Receive interrupt

    INTCONbits.PEIE = 1;

    INTCONbits.GIE  = 1;

    RCSTAbits.CREN = 1;//Enables receiver

    TXSTAbits.TXEN = 1;//Transmit enabled

    RCSTAbits.SPEN   =1; //serial port enable

}

void tx_eusart(unsigned char tx_data)

{

    TXREG = tx_data;

    while(TRMT==0);// loop

}

void interrupt isr(void)

{

     if (RCIE && RCIF) {

        RC_DATA=RCREG;

        RC_FLAG=1;

        LATA2 = 1;

    }

}

/*

 * 

 */

int main(int argc, char** argv) {

    init_fosc();

    init_eusart();

    RC_FLAG=0;

    TRISA2 = 0;

    LATA2 = 0;

    while(1)

    {

      

      if(RC_FLAG > 0)

       {

        tx_eusart(RC_DATA);

        RC_FLAG=0;

        LATA2=0;

       }

    }

}