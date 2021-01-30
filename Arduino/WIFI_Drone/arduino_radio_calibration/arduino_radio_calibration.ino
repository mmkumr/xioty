#include <ESP32Servo.h>

Servo ESC1;
Servo ESC2;
Servo ESC3;
Servo ESC4;
Servo ESC5;

String type[6] = {"dx", "dy", "ty", "tx", "m", "arm"};


int received = 0;
int c[5];

void setup() {
  ESP32PWM::allocateTimer(0);
  ESP32PWM::allocateTimer(1);
  ESP32PWM::allocateTimer(2);
  ESP32PWM::allocateTimer(3);
  ESC1.setPeriodHertz(50);
  ESC2.setPeriodHertz(50);
  ESC3.setPeriodHertz(50);
  ESC4.setPeriodHertz(50);
  ESC5.setPeriodHertz(50);
  // Recommended PWM GPIO pins on the ESP32 include 2,4,12-19,21-23,25-27,32-33
  ESC1.attach(12, 1000, 2000);
  ESC2.attach(13, 1000, 2000);
  ESC3.attach(14, 1000, 2000);
  ESC4.attach(15, 1000, 2000);
  ESC5.attach(18, 1000, 2000);
  Serial.begin(9600);
  pinMode(2, INPUT_PULLUP);
}
int start = 0;
void loop() {  
  if(digitalRead(2) == LOW && start == 0){
    ESC1.write(map(1000, 1000, 2000, 0, 180));
    delay(1000);
    ESC1.write(map(2000, 1000, 2000, 0, 180));
    delay(1000);
    ESC1.write(map(1500, 1000, 2000, 0, 180));
    delay(1000);
  
    ESC2.write(map(1000, 1000, 2000, 0, 180));
    delay(1000);
    ESC2.write(map(2000, 1000, 2000, 0, 180));
    delay(1000);
    ESC2.write(map(1500, 1000, 2000, 0, 180));
  
    ESC3.write(map(1000, 1000, 2000, 0, 180));
    delay(1000);
    ESC3.write(map(2000, 1000, 2000, 0, 180));
    delay(1000);
    ESC3.write(map(1500, 1000, 2000, 0, 180));
    delay(1000);
  
    ESC4.write(map(1000, 1000, 2000, 0, 180));
    delay(1000);
    ESC4.write(map(2000, 1000, 2000, 0, 180));
    delay(1000);
    ESC4.write(map(1500, 1000, 2000, 0, 180));
    start = 1;
  }
}
