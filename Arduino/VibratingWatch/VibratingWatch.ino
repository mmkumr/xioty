
/**************************************************************************
 This is an example for our Monochrome OLEDs based on SSD1306 drivers

 Pick one up today in the adafruit shop!
 ------> http://www.adafruit.com/category/63_98

 This example is for a 128x64 pixel display using SPI to communicate
 4 or 5 pins are required to interface.

 Adafruit invests time and resources providing this open
 source code, please support Adafruit and open-source
 hardware by purchasing products from Adafruit!

 Written by Limor Fried/Ladyada for Adafruit Industries,
 with contributions from the open source community.
 BSD license, check license.txt for more information
 All text above, and the splash screen below must be
 included in any redistribution.
 **************************************************************************/
#include <MPU6050_tockn.h>
#include "RTClib.h"
#include "U8glib.h"
#define USE_ARDUINO_INTERRUPTS true // Set-up low-level interrupts for most acurate BPM math.
#include <PulseSensorPlayground.h>

PulseSensorPlayground pulseSensor;
const int PulseWire = 0; // PulseSensor PURPLE WIRE connected to ANALOG PIN 0
int Threshold = 550;

U8GLIB_SSD1306_128X64 u8g(U8G_I2C_OPT_NONE|U8G_I2C_OPT_DEV_0);  // I2C / TWI 

//rtc setup
RTC_DS1307 rtc;

char daysOfTheWeek[7][4] = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};

uint8_t ah = -1, am = -1, as = 00;

// Mpu6050 variables.

MPU6050 mpu6050(Wire);

double tx, ty;
int moving = 0;
//i/o variables.
int motor = 5;
int beltswitch = 6;
int beltmotor1 = 3;
int beltmotor2 = 4;
int status = 0;
long state = 0;
int pulseButton = 7;
int t = 0;


void setup() {
  pulseSensor.begin();
  pulseSensor.analogInput(PulseWire);
  pulseSensor.setThreshold(Threshold);
  pulseSensor.setThreshold(Threshold);
  pinMode(motor, OUTPUT);
  pinMode(beltswitch, INPUT);
  pinMode(pulseButton, INPUT);
  pinMode(beltmotor1, OUTPUT);
  pinMode(beltmotor2, OUTPUT);
  Wire.begin();
  mpu6050.begin();
  mpu6050.calcGyroOffsets(true);

  //rtc setup
  if (! rtc.begin()) {
    Serial.println("Couldn't find RTC");
    while (1);
  }

  if (! rtc.isrunning()) {
    Serial.println("RTC is NOT running, let's set the time!");
    // When time needs to be set on a new device, or after a power loss, the
    // following line sets the RTC to the date & time this sketch was compiled
    //rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
    // This line sets the RTC with an explicit date & time, for example to set
    // January 21, 2014 at 3am you would call:
    rtc.adjust(DateTime(2014, 1, 21, 3, 0, 0));
  }

  
  //OLED functions.
  Serial.begin(9600);

}

void loop() {
  mpu6050.update();
  u8g.firstPage();  
  do {
      watch();
  } while( u8g.nextPage() );
  delay(1000);
}

void watch (){
  DateTime now = rtc.now();
  DateTime future(now);
  if(ah == future.hour() && am == future.minute() && as == future.second()){
     for(int timer = 0; timer < 60; ++timer) {
        moving = 0;
        for(int i = 0; i < 15; ++i) {
          tx = mpu6050.getAccAngleX();
          ty = mpu6050.getAccAngleY();
          DateTime now = rtc.now();
          DateTime future(now);
          mpu6050.update();
          //timing
          
          delay(1000);
          if(abs(tx - mpu6050.getAccAngleX()) > 10 || abs(ty - mpu6050.getAccAngleY()) > 10) {
            moving += 1;
          }
          
          if(i == 10) {
              digitalWrite(motor, LOW); 
            }
        }
        Serial.println(moving);
        if(moving < 10) { 
            digitalWrite(motor, HIGH);
        } else {
            digitalWrite(motor, LOW); 
          }      
      }
  } else{
        if(digitalRead(beltswitch) == 1) {
            if(status == 0) {
                digitalWrite(beltmotor1, HIGH);
                digitalWrite(beltmotor2, LOW);
                status = 1;
                state = millis();
            }
            if(status == 1) {
                digitalWrite(beltmotor1, LOW);
                digitalWrite(beltmotor2, HIGH);
                status = 0;
                state = millis();
            }
        }
        if(digitalRead(beltswitch) == 0) {
             if(millis() - state > 4000) {
                digitalWrite(beltmotor1, LOW);
                digitalWrite(beltmotor2, LOW);
                state = 0;
             } 
        }
        showTime();
    }
}

void showTime() {
  int length = 13;
  char buffer [6][14];
  char termChar = ':';

  if(Serial.available() > 0){
    int numChars = Serial.readBytesUntil(termChar, buffer[t], length);
    buffer[t][numChars]='\0';
    if(t == 5){
      if(buffer[0][0] == 'd') {
        rtc.adjust(DateTime(String(buffer[3]).toInt(), String(buffer[2]).toInt(), String(buffer[1]).toInt(), String(buffer[4]).toInt(), String(buffer[5]).toInt(), 0));
        Serial.print("Setting Time");
      }
      if(buffer[0][0] == 'a') {
        ah = String(buffer[4]).toInt();
        am = String(buffer[5]).toInt();
        Serial.print("Setting Alarm");
      }
      t = 0;
    }
    else if(t < 5){
      ++t;
    }
  }
  
  DateTime now = rtc.now();
  DateTime future(now);
  int myBPM = pulseSensor.getBeatsPerMinute();
  if(digitalRead(pulseButton) == HIGH) {
      u8g.drawStr(0,40, ("Heart: " + String(myBPM)).c_str() );
  }else {
      u8g.drawStr(45,40, String(daysOfTheWeek[now.dayOfTheWeek()]).c_str() );
    }
  u8g.setFont(u8g_font_courB14);
  u8g.drawStr(10,20, (twoChar(String(future.day())) + "/" + twoChar(String(future.month())) + "/" + String(future.year()) ).c_str() );
  u8g.drawStr(20,60, (twoChar(String(future.hour())) + ":" + twoChar(String(future.minute())) + ":" + twoChar(String(future.second())) ).c_str() );  
}

String twoChar(String num){
  if(num.length() == 1){
      return "0" + num;
   }  
   return num;
}


  
  
