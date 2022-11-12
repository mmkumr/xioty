#include <string.h>
#include <Wire.h>
#include <Servo.h>
Servo ESC1;
Servo ESC2;
Servo ESC3;
Servo ESC4;
Servo ESC5;

String type[6] = {"dx", "dy", "ty", "tx", "m", "arm"};


int received = 0;
int c[5];

void setup() {
  ESC1.attach(3,1000,2000);
  ESC2.attach(5,1000,2000);
  ESC3.attach(6,1000,2000);
  ESC4.attach(9,1000,2000);
  ESC5.attach(10,1000,2000);  
  ESC1.write(map(150, 100, 200, 0, 180));
  ESC2.write(map(150, 100, 200, 0, 180));
  ESC3.write(map(100, 100, 200, 0, 180));
  ESC4.write(map(150, 100, 200, 0, 180));
  ESC5.write(map(200, 100, 200, 0, 180));
  Wire.begin(8);                // join i2c bus with address #8
  Wire.onReceive(receiveEvent); // register event
  Serial.begin(9600);           // start serial for output
}

void loop() {
  if(received == 1){
    if(c[0] == 1){ // Direction x channel
      c[1] = map(c[1], 100, 200, 0, 180);   
      ESC1.write(c[1]);
    } 

    if((c[0] == 2)){ // Direction y channel
      c[1] = map(c[1], 100, 200, 0, 180);   
      ESC2.write(c[1]);
    }
    if((c[0] == 3)){ // throttle y channel
      c[1] = map(c[1], 100, 200, 0, 180);   
      ESC3.write(c[1]);
    }
    if((c[0] == 4)){ // throttle x channel
      c[1] = map(c[1], 100, 200, 0, 180);   
      ESC4.write(c[1]);
    }
    if((c[0] == 5)){ // mode channel
      c[1] = map(c[1], 100, 200, 0, 180);   
      ESC5.write(c[1]);
    }
    received = 0;
  }
}

// function that executes whenever data is received from master
// this function is registered as an event, see setup()
void receiveEvent(int howMany) {
  int i = 0;
  while (Wire.available()) {
    c[i] = Wire.read();
    i++;
  }
  received = 1;
}
