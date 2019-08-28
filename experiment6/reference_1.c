/*
 * File:   int.c
 * Author: sunhaohai
 *
 * Created on 2018?8?26?, ??11:52
 */

#include "int.h"
#include <pic.h>
#include <xc.h>

//interrupt 
void interrupt irs_routine(void){
    //float temp = read_temprature();
    //temp_show(temp);
    //led_show_dian(seg_index);
    /*
    _count_of_switch = eeprom_read(0x20);
    _switch_scan_count_unshake();
    seg_index[0] = eeprom_read(0x00);
    if (true_switch_ != 0){
      seg_index[0] = true_switch_;
      eeprom_write(0x00,seg_index[0]);
    }
     
    if(seg_index[0] == 2){
        
    }
    
    if(seg_index[0] == 3){
        _count_show(999);
    }
    
    if(seg_index[0] == 4){
        init_ADC();
        data_output();
        if (_count_of_AD == Time_of_AD_cycle && ADCON0bits.GO == 0)
        {
            restart_ADC();
            //restart_touch();
        }
        else
            _count_of_AD = _count_of_AD + 1;
        led_show(seg_index);
    }
    */
    
     _count_of_switch = eeprom_read(0x20);
    _switch_scan_count_unshake();
    seg_index[0] = eeprom_read(0x00);
    if (true_switch_ != 0){
        seg_index[0] = true_switch_;
        eeprom_write(0x00,seg_index[0]);
    }
    _count_show(999);
    
    led_show(seg_index);
    INTCONbits.TMR0IF=0;
    TMR0 = 0;
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

void led_show_dian(int seg_index[]){
    int delay_time = 1;
    PORTA = 0x0e;
    PORTC = seg_table[seg_index[0]];
    delay_(delay_time);
    PORTC = 0;
    
    PORTA = 0x0d;
    PORTC = seg_table_count[seg_index[1]];
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
    TRISB = 0x0f;
    PORTB = 0x0f;
    if (PORTBbits.RB0 == 0) return 1;
    else if (PORTBbits.RB1 == 0) return 2;
    else if (PORTBbits.RB2 == 0) return 3;
    else if (PORTBbits.RB3 == 0) return 4;
    else{
        TRISB = 0x07;
        PORTB = 0x07;
        if (PORTBbits.RB0 == 0) return 5;
        else if (PORTBbits.RB1 == 0) return 6;
        else if (PORTBbits.RB2 == 0) return 7;
        else{
            TRISB = 0x03;
            PORTB = 0x03;
            if (PORTBbits.RB0 == 0) return 8;
            else if (PORTBbits.RB1 == 0) return 9;
            else{
                TRISB = 0x01;
                PORTB = 0x01;
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
                eeprom_write(0x20, _count_of_switch);
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
    delay_(2);
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

void temp_show(float temp_f){
    int temp = temp_f*100;
    for(unsigned char i = 0;i<4;i++){
        seg_index[3-i] = temp % 10;
        temp = temp / 10;
    }
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


unsigned char RECOVER_DATA(unsigned char  addr_2){
    EEADRL = addr_2;
    CFGS = 0;
    EEPGD = 0;
    RD = 1;
    unsigned char result= EEDATL;
    return result;
}
void SAVE_DATA(unsigned char addr_2, unsigned char data){
    PORTA = 0b11111111; //close the tub
    EEADRL = addr_2;
    EEDATL = data;
    CFGS = 0;
    EEPGD = 0;
    WREN = 1;
    EECON2 = 0x55;
    EECON2 = 0xAA;
    WR = 1;
    GIE = 1;
    WREN = 0;
    while(WR);
    return;
}

void init_ADC(void)
{
    FVRCON = 0b11000010; //???????????2.048v??????
    ADCON0 = 0b11111111; //??FVR????????????ADC
    ADCON1 = 0b01110000; //????????????????????????
    ADCON2 = 0b11111111; //???????
}

void init_touch(void)
{
    TRISAbits.TRISA5 = 1;
    ANSELAbits.ANSA5 = 1;
    FVRCON = 0b11000011; //???????????2.048v??????
    ADCON0 = 0b10010011; //??FVR????????????ADC
    ADCON1 = 0b01110011; //????????????????????????
    ADCON2 = 0b11111111; //???????
    /*TRISBbits.TRISB1=1;
    ANSELBbits.ANSB1=1;
    FVRCON=0b11000011; //???????????2.048v??????
    ADCON0=0b10101011; //??FVR????????????ADC
    ADCON1=0b01110011; //????????????????????????
    ADCON2=0b11111111; //???????*/
}

void init_temperature(void)
{
    FVRCON = 0b11000011; //???????????FVR4.096v??????
    ADCON0 = 0b11110111; //??FVR????????????ADC
    ADCON1 = 0b01110011; //正参考电压设为FVR
    ADCON2 = 0b11111111; //???????
}

void restart_ADC(void)
{
    _count_of_AD = 0;
    FVRCON = 0b11000010; //???????????2.048v??????
    ADCON0 = 0b11111111; //??FVR????????????ADC
    ADCON1 = 0b01110000; //????????????????????????
    ADCON2 = 0b11111111; //???????
}

void restart_touch(void)
{
    if (tag == 0)
    {
        _count_of_AD = 0;
        TRISAbits.TRISA5 = 1;
        ANSELAbits.ANSA5 = 1;
        TRISBbits.TRISB1 = 0;
        ANSELBbits.ANSB1 = 0;
        FVRCON = 0b11000011; //???????????2.048v??????
        ADCON0 = 0b10010011; //??FVR????????????ADC
        ADCON1 = 0b01110011; //????????????????????????
        ADCON2 = 0b11111111; //???????
    }
    /*else
    {
    _count_of_AD=0;
    FVRCON=0b11000010; //???????????2.048v??????
    ADCON0=0b10010011; //??FVR????????????ADC
    ADCON1=0b01110011; //????????????????????????
    ADCON2=0b11111111; //???????
    }*/
    else //??????
    {
        _count_of_AD = 0;
        TRISAbits.TRISA5 = 0;
        ANSELAbits.ANSA5 = 0;
        TRISBbits.TRISB1 = 1;
        ANSELBbits.ANSB1 = 1;
        FVRCON = 0b11000011;
        ADCON0 = 0b10101011;
        ADCON1 = 0b01110011;
        ADCON2 = 0b11111111;
    }
}

void data_output(void)
{
    float data;
    int data_l, data_h;
    int Data[4];
    if (ADCON0bits.GO == 0) //??AD????
    {
        data_l = ADRESL;
        data_h = ADRESH * 16;
        data_l = (data_l && 0b11110000) / 16;
        data = data_h + data_l;
        //data=(4096*2.048)/data;
        //if(tag==0) data=(data*4.096)/4096;
        data = (4096 * 2.048) / data;
        //if(tag==0) data1=data;
        //else data2=data;
        Data[0] = (int)(data);
        data = 10 * (data - (int)(data));
        Data[1] = (int)(data);
        data = 10 * (data - (int)(data));
        Data[2] = (int)(data);
        data = 10 * (data - (int)(data));
        Data[3] = (int)(data);
        data = 10 * (data - (int)(data));
    }
    seg_index[0] = Data[0];
    seg_index[1] = Data[1];
    seg_index[2] = Data[2];
    seg_index[3] = Data[3];
}
