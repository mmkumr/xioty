#include <SPI.h>
#include <LoRa.h>
#include<math.h>
String inString = "";    // string to hold input
int start = 0;
float time;

void setup() {
  Serial.begin(9600);
  pinMode(3,OUTPUT);
  pinMode(4,OUTPUT);
  pinMode(5,OUTPUT);
  while (!Serial);
  Serial.println("LoRa Receiver2");
  if (!LoRa.begin(433E6)) { // or 915E6
    Serial.println("Starting LoRa failed!");
    while (1);
  }
}

void loop() {
  
  // try to parse packet
  char prev = 'a';
  while(true){
      int packetSize = LoRa.parsePacket();
      if(LoRa.available() && start == 0) {
          char inChar = LoRa.read();
          Serial.println(inChar); 
          if(inChar=='a') {
          digitalWrite(3,HIGH);
    //    digitalWrite(4,HIGH);
          delay(2000);
    //    digitalWrite(3,LOW);
    //    digitalWrite(4,LOW);
          start = 1;
          prev = inChar;
          LoRa.packetRssi();
          time = millis();
          } 
      }else if(start == 1 && (round((millis() - time)/1000) == 35) ) {
          break;
      }else if(LoRa.available() && start == 1 && (LoRa.read()) == 'a') {
          LoRa.packetRssi();
          time = millis();
      }
  }  
  //digitalWrite(5,HIGH);
  delay(2000);
  digitalWrite(3,LOW);
  start = 0;
}
