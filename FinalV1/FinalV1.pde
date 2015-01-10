#include <Wire.h>
#include "RTClib.h"
#include "LCD_driver.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include "WProgram.h"
#include "HardwareSerial.h"

int second; 
int minute;
int hour;  
int monthDay; 
int month; 
int year; 
int s1, s2, s3, st;
DateTime now;
RTC_DS1307 RTC;

int duty = 0;
int steps = 64;
int sunrisespeed = 5000;
int k;
int j;
int pulsepin = 11;

int speakerPin = 10;
int length = 12; // the number of notes
char notes[] = " CbgCbe CcgaC";
int beats[] = {2, 1, 2, 1, 1, 2, 1, 2, 2, 2, 1, 1};
int tempo = 300;

int lookup[64] = {1,2,4,6,9,12,16,20,25,30,36,
42,49,56,64,72,81,90,100,110,121,132,
144,156,169,182,196,210,225,240,256,272,289,
306,324,342,361,380,400,420,441,462,484,506,
529,552,576,600,625,650,676,702,729,756,784,
812,841,870,900,930,961,992,992,992};

int alarmHour = 8;
int alarmMinute = 15;

void setup () {
  Wire.begin();
  RTC.begin();

  ioinit();           //Initialize I/O
  LCDInit();	    //Initialize the LCD
  LCDClear(BLACK);
  LCDPutStr("Press:", 0, 0, GREEN, BLACK);
  LCDPutStr("S3 for time.", 18, 0, GREEN, BLACK);
  LCDPutStr("S2 for date.", 36, 0, GREEN, BLACK);
  LCDPutStr("S1 for alarm.", 52, 0, GREEN, BLACK);
  if (! RTC.isrunning()) {
    RTC.adjust(DateTime(__DATE__, __TIME__));
  }
  
  pinMode(10, OUTPUT);
}

void loop () {
  now = RTC.now();

  getTime();
  s1 = !digitalRead(kSwitch1_PIN);
  s2 = !digitalRead(kSwitch2_PIN);
  s3 = !digitalRead(kSwitch3_PIN);

  if (s1){
    LCDClear(BLACK);
    st = 1;
  }else if (s2){
    LCDClear(BLACK);
    st = 2; 
  }else if (s3){
    LCDClear(BLACK);
    st = 3;
  }
  if (st == 1){
   LCDPutStr("set?", 0, 0, MAGENTA, BLACK);
   alarm();
  }else if (st == 2){
    LCDPutStr("Current date is:", 0, 0, MAGENTA, BLACK);
    printDate();
  }else if (st == 3){
    LCDPutStr("Current time is:", 0, 0, ORANGE, BLACK); // Write information on display
    printTime();
  }
  
}
void getTime(){
  second = now.second(); 
  minute = now.minute();
  hour = now.hour();
  monthDay = now.day();
  month = now.month();
  year = now.year();

}
void printTime(){
  char hourA[4];
  char buf[4];
  itoa(hour, buf, 10);
  if (hour < 10) {
    hourA[0]='0'; hourA[1]= buf[0]; hourA[2]=buf[1];
  } else {
    hourA[0]=buf[0]; hourA[1]=buf[1]; hourA[2]=buf[2]; 
  }
  
  char minuteA[4];
  itoa(minute,buf,10);
  if (minute < 10) {
    minuteA[0] ='0'; minuteA[1] = buf[0]; minuteA[2]=buf[1];
  } else {
    minuteA[0] = buf[0]; minuteA[1] = buf[1]; minuteA[2] = buf[2]; 
  }
  char secondA[3];
  
  itoa(second, buf, 10);
  if (second < 10) {
    secondA[0]='0'; secondA[1]=buf[0]; secondA[2]=buf[1]; 
  } else {
    secondA[0]=buf[0]; secondA[1]=buf[1]; secondA[2]=buf[2]; 
  }
  LCDPutStr(hourA, 36, 0, GREEN, BLACK);
  LCDPutStr(":", 36, 16, GREEN, BLACK);
  LCDPutStr(minuteA, 36, 24, GREEN, BLACK);
  LCDPutStr(":", 36, 40 , GREEN, BLACK);
  LCDPutStr(secondA, 36, 46, GREEN, BLACK);
}

void printDate(){
  char buf[3];
  char yearBuf[5];
  if (month == 1){
    LCDPutStr("January", 16, 0, GREEN, BLACK);
  } else if(month == 2){
    LCDPutStr("February", 16, 0, GREEN, BLACK);
  } else if(month == 3){
    LCDPutStr("March", 16, 0, GREEN, BLACK);
  }else if(month == 4){
    LCDPutStr("April", 16, 0, GREEN, BLACK);
  }else if(month == 5){
    LCDPutStr("May", 16, 0, GREEN, BLACK);
  }else if(month == 6){
    LCDPutStr("June", 16, 0, GREEN, BLACK);
  }else if(month == 7){
    LCDPutStr("July", 16, 0, GREEN, BLACK);
  } else if(month == 8){
    LCDPutStr("August", 16, 0, GREEN, BLACK);
  }else if(month == 9){
    LCDPutStr("September", 16, 0, GREEN, BLACK);
  }else if(month == 10){
    LCDPutStr("October", 16, 0, GREEN, BLACK);
  }else if(month == 11){
    LCDPutStr("November", 16, 0, GREEN, BLACK);
  }else if (month == 12){
    LCDPutStr("December", 16, 0, GREEN, BLACK);
  }
 LCDPutStr(itoa(monthDay, buf, 10), 16, 68, GREEN, BLACK);
 LCDPutStr(",", 16, 84, GREEN, BLACK);
 LCDPutStr(itoa(year,yearBuf,10), 16, 92, GREEN, BLACK);
}
void alarm(){
  LCDClear(BLACK);
  char bufA[4];
  char alarmHourA[4];
  itoa(alarmHour, bufA, 10);
  if (alarmHour < 10){
    alarmHourA[0] = '0'; alarmHourA[1] = bufA[0]; alarmHourA[2] = bufA[1]; 
  }else {
   alarmHourA[0] = bufA[0]; alarmHourA[1] = bufA[1]; alarmHourA[2] = bufA[2];
  }
  char alarmMinuteA[4];
  itoa(alarmMinute, bufA, 10);
  if (alarmMinute < 10){
    alarmMinuteA[0] = '0'; alarmMinuteA[1] = bufA[0]; alarmMinuteA[2] = bufA[1];
  } else {
    alarmMinuteA[0] = bufA[0]; alarmMinuteA[1] = bufA[1]; alarmMinuteA[2] = bufA[2];  
  }
  LCDPutStr(alarmHourA, 12, 0, WHITE, BLACK);
  LCDPutStr(":", 12, 20, WHITE, BLACK);
  LCDPutStr(alarmMinuteA, 12, 26, WHITE, BLACK); 
}

void sunrise(){ //FIX IT
  pinMode(10, OUTPUT);
  for (k=0; k<steps; k++)
  {
    duty = lookup[k] * 5;
    for (j=0; j<sunrisespeed; j++)
    {
      // one pulse of PWM
      digitalWrite(pulsepin, HIGH);
      delayMicroseconds(duty);
      digitalWrite(pulsepin, LOW);
      delayMicroseconds(5000-duty);
    }
  }
}

void wakeMeUp(){
 for (int i = 0; i < length; i++) {
    if (notes[i] == ' ') {
      delay(beats[i] * tempo); // rest
    } else {
      playNote(notes[i], beats[i] * tempo);
    }

    // pause between notes
    delay(tempo / 2); 
  } 
}
void playTone(int tone, int duration) {
  for (long i = 0; i < duration * 1000L; i += tone * 2) {
    digitalWrite(speakerPin, HIGH);
    delayMicroseconds(tone);
    digitalWrite(speakerPin, LOW);
    delayMicroseconds(tone);
  }
}

void playNote(char note, int duration) {
  char names[] = { 'c', 'd', 'e', 'f', 'g', 'a', 'b', 'C' };
  int tones[] = { 1915, 1700, 1519, 1432, 1275, 1136, 1014, 956 };

  // play the tone corresponding to the note name
  for (int i = 0; i < 8; i++) {
    if (names[i] == note) {
      playTone(tones[i], duration);
    }
  }
}

