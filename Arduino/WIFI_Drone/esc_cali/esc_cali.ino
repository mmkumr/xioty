#include <ESP32Servo.h>
 
Servo myservo1; 
Servo myservo2;
Servo myservo3;
Servo myservo4;
Servo myservo5;




int cal = 23;

void setup()
{
  ESP32PWM::allocateTimer(0);
  ESP32PWM::allocateTimer(1);
  ESP32PWM::allocateTimer(2);
  ESP32PWM::allocateTimer(3);
  myservo1.setPeriodHertz(50);
  myservo2.setPeriodHertz(50);
  myservo3.setPeriodHertz(50);
  myservo4.setPeriodHertz(50);
  myservo5.setPeriodHertz(50);
  // Recommended PWM GPIO pins on the ESP32 include 2,4,12-19,21-23,25-27,32-33
  myservo1.attach(12, 1000, 2000);
  myservo2.attach(13, 1000, 2000);
  myservo3.attach(14, 1000, 2000);
  myservo4.attach(15, 1000, 2000);
  myservo5.attach(18, 1000, 2000);
  // using default min/max of 1000us and 2000us
  Serial.begin(9600);
  myservo3.write(map(200, 100, 200, 0, 180));
  pinMode(cal, INPUT_PULLUP);
  digitalWrite(2, LOW);
}

void loop()
{
  if(digitalRead(cal) == LOW){
    for(int i = 200; i > 100; i -= 10){
      myservo3.write(map(i, 100, 200, 0, 180));
      delay(100);
    }
    delay(2000);
    for(int i = 100; i < 200; i += 10){
      myservo3.write(map(i, 100, 200, 0, 180));
      delay(100);
    }
  }
}
