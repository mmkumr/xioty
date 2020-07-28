#include <SPI.h>
#include <LoRa.h>
#include<math.h>
String inString = "";    // string to hold input
int start = 0;
float time, time1;
char token = 'm';
void setup() {
  Serial.begin(9600);
  pinMode(3,OUTPUT);
  pinMode(4,OUTPUT);
  pinMode(5,OUTPUT);
  while (!Serial);
  Serial.println("Motor");
  if (!LoRa.begin(433E6)) { // or 915E6
    Serial.println("Starting LoRa failed!");
    while (1);
  }
}

void loop() {
  
  // try to parse packet
  char prev = token;
  while(true){
      int packetSize = LoRa.parsePacket();
      if(LoRa.available() && start == 0) {
          char inChar = LoRa.read();
          Serial.println(inChar); 
          if(inChar == token) {
          digitalWrite(3,HIGH);
    //    digitalWrite(4,HIGH);
          delay(2000);
    //    digitalWrite(3,LOW);
    //    digitalWrite(4,LOW);
          start = 1;
          prev = inChar;
          LoRa.packetRssi();
          time = millis();
          time1 = millis();
          } 
      }else if( (start == 1 && (round((millis() - time)/1000) == 35)) || (LoRa.read() == 'o') ) {
          break;
      }else if(start == 1 && (round((millis() - time1)/1000) == 10)  && (LoRa.read()) == token) {
          LoRa.beginPacket();  
          LoRa.print('c');
          LoRa.endPacket();
          time1 = millis();
      }else if(LoRa.available() && start == 1 && (LoRa.read()) == token) {
          LoRa.packetRssi();
          time = millis();
      }
  }  
  //digitalWrite(5,HIGH);
  delay(2000);
  digitalWrite(3,LOW);
  start = 0;
}
