#include <SPI.h>
#include <LoRa.h>
#include<math.h>
String inString = "";    // string to hold input
int start = 0;
int D3 = 3;
float t;

void setup() {
  Serial.begin(9600);
  pinMode(D3,INPUT);
  digitalWrite(D3, HIGH);
  while (!Serial);
  Serial.println("Tank");
  if (!LoRa.begin(433E6)) { // or 915E6
    Serial.println("Starting LoRa failed!");
    while (1);
  }
}

void loop() {
  // try to parse packet
  while(true){
      int packetSize = LoRa.parsePacket();
      if(LoRa.available()) {
          char inChar = LoRa.read();
          Serial.println(inChar); 
          LoRa.packetRssi();
          t = millis();
          if(inChar=='a' && digitalRead(D3) == LOW) {
             while(digitalRead(D3) == LOW && inChar != 'b') {
              LoRa.parsePacket();
              if(LoRa.available()) {
                inChar = LoRa.read();
                Serial.println(inChar); 
                LoRa.packetRssi();
               }

               if(inChar == 'a'){
                  LoRa.beginPacket(); 
                  Serial.println("m"); 
                  LoRa.print('m');
                  LoRa.endPacket();
                  inChar = 's';
                }
               if(inChar == 'c') {
                  LoRa.beginPacket();  
                  LoRa.print('e');
                  LoRa.endPacket(); 
                }
               if(round((millis() - t)/1000) == 30 && inChar == 's') {
                LoRa.beginPacket(); 
                Serial.println("m"); 
                LoRa.print('m');
                LoRa.endPacket(); 
                t = millis(); 
               }
             }   
          }
          if(inChar=='b'){
            LoRa.beginPacket(); 
            Serial.println("o"); 
            LoRa.print('o');
            inChar = 's';
            LoRa.endPacket();
          }
      }
  }  
  
  start = 0;
}
