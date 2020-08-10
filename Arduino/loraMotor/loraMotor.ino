#include <SPI.h>
#include <LoRa.h>
#include "EmonLib.h"

#define VOLT_CAL 148.7
#define CURRENT_CAL 4.3
EnergyMonitor emon1;
float currentDraw; 
float supplyVoltage;

int D3 = 3;
int D7 = 7;

long t;

void setup() {
  pinMode(D3, OUTPUT);
  pinMode(D7, OUTPUT);
  Serial.begin(9600);
  emon1.voltage(1, VOLT_CAL, 1.7);  // Voltage: input pin, calibration, phase_shift
  emon1.current(0, CURRENT_CAL);
  while (!Serial);

  Serial.println("Motor");

  if (!LoRa.begin(433E6)) {
    Serial.println("Starting LoRa failed!");
    while (1);
  }
  emon1.calcVI(20,2000);         
  currentDraw = emon1.Irms;             
  supplyVoltage = emon1.Vrms;
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
    if(String(buffer[0]) == "motor"){
      digitalWrite(D3, HIGH);
      digitalWrite(D7, HIGH);
      t = millis();
      while( (String(buffer[0]) != "motorStop") && ( (millis() - t)/1000 != 35.0) ) {
        packetSize = LoRa.parsePacket();
        if (packetSize) {
            // read packet
            while (LoRa.available()) {
              int numChars = LoRa.readBytesUntil(termChar, buffer[0], length);
              buffer[0][numChars]='\0';
              Serial.println(buffer[0]);
            }
            LoRa.packetRssi();
            if( (String(buffer[0]) == "motor") ){
              t = millis();          
            }
        }
        if((millis() - t)/1000 == 15.0){
          emon1.calcVI(20,2000);         
          currentDraw = emon1.Irms;             
          supplyVoltage = emon1.Vrms;
          LoRa.beginPacket(); 
          LoRa.print(String(currentDraw) + ":");  
          LoRa.endPacket(); 
        }
      }  
      digitalWrite(D3, LOW);
      digitalWrite(D7, LOW);
    }
  }
}
