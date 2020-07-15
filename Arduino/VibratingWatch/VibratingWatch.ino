
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
#include <SPI.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include "RTClib.h"
//rtc setup
RTC_DS1307 rtc;

char daysOfTheWeek[7][4] = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};

#define SCREEN_WIDTH 128 // OLED display width, in pixels
#define SCREEN_HEIGHT 64 // OLED display height, in pixels

// Declaration for SSD1306 display connected using software SPI (default case):
#define OLED_MOSI  11
#define OLED_CLK   13
#define OLED_DC    9
#define OLED_CS    10
#define OLED_RESET 8
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT,
  OLED_MOSI, OLED_CLK, OLED_DC, OLED_RESET, OLED_CS);

/* Comment out above, uncomment this block to use hardware SPI
#define OLED_DC     6
#define OLED_CS     7
#define OLED_RESET  8
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT,
  &SPI, OLED_DC, OLED_RESET, OLED_CS);
*/

uint8_t ah = 3, am = 42, as = 0;

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


void setup() {
  pinMode(motor, OUTPUT);
  pinMode(beltswitch, INPUT);
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

  // SSD1306_SWITCHCAPVCC = generate display voltage from 3.3V internally
  if(!display.begin(SSD1306_SWITCHCAPVCC)) {
    Serial.println(F("SSD1306 allocation failed"));
    for(;;); // Don't proceed, loop forever
  }


  // Show initial display buffer contents on the screen --
  // the library initializes this with an Adafruit splash screen.
  display.display();

  // Clear the buffer
  display.clearDisplay();

  // Draw a single pixel in white

  // Show the display buffer on the screen. You MUST call display() after
  // drawing commands to make them visible on screen!
  display.display();
  delay(2000);
  // display.display() is NOT necessary after every single drawing command,
  // unless that's what you want...rather, you can batch up a bunch of
  // drawing operations and then update the screen all at once by calling
  // display.display(). These examples demonstrate both approaches... 
  

  // Invert and restore display, pausing in-between
  display.invertDisplay(true);
  delay(1000);
  display.invertDisplay(false);
  delay(1000);

 // testanimate(logo_bmp, LOGO_WIDTH, LOGO_HEIGHT); // Animate bitmaps
}

void loop() {
  watch();
  delay(1000);
}


void testdrawchar(String word) {
  display.setTextColor(SSD1306_WHITE); // Draw white text
  
      // Start at top-left corner
  display.cp437(true);         // Use full 256 char 'Code Page 437' font

  // Not all the characters will fit on the display. This is normal.
  // Library will draw what it can and the rest will be clipped.
  for(int i=0; i < word.length(); i++) {
    display.write(word[i]);
  }
}


void watch (){
  display.clearDisplay();
  DateTime now = rtc.now();
  DateTime future(now);
  if(ah == future.hour() && am == future.minute() && as == future.second()){
     for(int timer = 0; timer < 60; ++timer) {
        moving = 0;
        for(int i = 0; i < 15; ++i) {
          tx = mpu6050.getAccAngleX();
          ty = mpu6050.getAccAngleY();
          mpu6050.update();
          //timing
          display.clearDisplay();
          DateTime now = rtc.now();
          DateTime future(now);
          display.setTextSize(1);
          display.setCursor(40,5); 
          print2digits(future.day());
          testdrawchar(String(future.day()));
          testdrawchar("-");
          print2digits(future.month());
          testdrawchar(String(future.month()));
          //testdrawchar("-");
          //testdrawchar(String(future.year()));
          testdrawchar(" ");
          testdrawchar(String(daysOfTheWeek[now.dayOfTheWeek()]));
          display.setCursor(40,40); 
          //testdrawchar("       ");
          print2digits(future.hour());
          testdrawchar(String(future.hour()));
          testdrawchar(":");
          print2digits(future.minute());
          testdrawchar(String(future.minute()));
          testdrawchar(":");
          print2digits(future.second());
          testdrawchar(String(future.second())); 
          display.display();
          //watch();
          delay(1000);
          if(abs(tx - mpu6050.getAccAngleX()) > 10 || abs(ty - mpu6050.getAccAngleY()) > 10) {
            moving += 1;
          }
          
          if(i == 10) {
              digitalWrite(motor, LOW); 
            }
        }
        Serial.print(moving);
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
        display.setTextSize(1);
        display.setCursor(40,5); 
        print2digits(future.day());
        testdrawchar(String(future.day()));
        testdrawchar("-");
        print2digits(future.month());
        testdrawchar(String(future.month()));
        //testdrawchar("-");
        //testdrawchar(String(future.year()));
        testdrawchar(" ");
        testdrawchar(String(daysOfTheWeek[now.dayOfTheWeek()]));
        display.setCursor(40,40); 
        //testdrawchar("       ");
        print2digits(future.hour());
        testdrawchar(String(future.hour()));
        testdrawchar(":");
        print2digits(future.minute());
        testdrawchar(String(future.minute()));
        testdrawchar(":");
        print2digits(future.second());
        testdrawchar(String(future.second()));
        display.display();
    }
}

void print2digits(int number) {
    if (number >= 0 && number < 10) {
        testdrawchar("0");
      }
}



  
  
