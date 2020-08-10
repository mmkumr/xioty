#include <SPI.h>
#include <LoRa.h>
#include<math.h>

long t = 0;

int D3 = 3;

void setup() {
  Serial.begin(9600);
  while (!Serial);
  pinMode(D3, INPUT);
  Serial.println("Tank");

  if (!LoRa.begin(433E6)) {
    Serial.println("Starting LoRa failed!");
    while (1);
  }
}

void loop() {
  char buffer [1][14];
  int length = 13;
  char termChar = ':';
  // try to parse packet
  int packetSize = LoRa.parsePacket();
  if (packetSize) {
    // received a packet
    Serial.print("Received packet ");
    // read packet
    while (LoRa.available()) {
      int numChars = LoRa.readBytesUntil(termChar, buffer[0], length);
      buffer[0][numChars]='\0';
      Serial.println(String(buffer[0]));
    }
    LoRa.packetRssi();
    if(String(buffer[0]) == "water"){
      LoRa.beginPacket();
      LoRa.print("motor");
      LoRa.endPacket();
      t = millis();
      while( (String(buffer[0]) != "waterStop") && (digitalRead(D3) == LOW) ) {
        packetSize = LoRa.parsePacket();
        if (packetSize) {
            // read packet
            while (LoRa.available()) {
              int numChars = LoRa.readBytesUntil(termChar, buffer[0], length);
              buffer[0][numChars]='\0';
              Serial.println(buffer[0]);
              if( String(buffer[0]).toFloat() != 0.0 ){
                LoRa.beginPacket();
                LoRa.print(buffer[0]);
                LoRa.endPacket();
              }
            }
            LoRa.packetRssi();
        }
        if( (millis() - t)/1000 == 30.0){
          LoRa.beginPacket();
          LoRa.print("motor");
          LoRa.endPacket();
          t = millis();          
        }
      }
      LoRa.beginPacket();
      LoRa.print("motorStop");
      LoRa.endPacket();
      t = millis();  
    }
  }
}
