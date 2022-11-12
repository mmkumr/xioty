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
  pinMode(cal, INPUT_PULLUP);
  digitalWrite(2, LOW);
}
int start = 0; 
void loop()
{
  if(digitalRead(cal) == LOW && start == 0){
    myservo1.write(map(100, 100, 200, 0, 180));
    delay(1000);
    myservo1.write(map(200, 100, 200, 0, 180));
    delay(1000);
    myservo1.write(map(150, 100, 200, 0, 180));
    delay(1000);

    
    myservo2.write(map(100, 100, 200, 0, 180));
    delay(1000);
    myservo2.write(map(200, 100, 200, 0, 180));
    delay(1000);
    myservo2.write(map(150, 100, 200, 0, 180));
    delay(1000);

    myservo3.write(map(100, 100, 200, 0, 180));
    delay(1000);
    myservo3.write(map(200, 100, 200, 0, 180));
    delay(1000);
    myservo3.write(map(150, 100, 200, 0, 180));
    delay(1000);

    myservo4.write(map(100, 100, 200, 0, 180));
    delay(1000);
    myservo4.write(map(200, 100, 200, 0, 180));
    delay(1000);
    myservo4.write(map(150, 100, 200, 0, 180));
    delay(1000);
    start = 1;
  }
}
