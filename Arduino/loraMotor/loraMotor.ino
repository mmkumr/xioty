#include <SPI.h>
#include <LoRa.h>
#include "EmonLib.h"             // Include Emon Library

#define VOLT_CAL 151.0
#define CURRENT_CAL 4.6

EnergyMonitor emon1;

int D3 = 3;
int D7 = 7;
int D5 = 5;

int i = 0;

String id = "1234";

int length = 25;
char buffer [3][25];
char termChar = ':';

long t;

void setup() {
  
  pinMode(D3, OUTPUT);
  pinMode(D7, OUTPUT);
  pinMode(D5, INPUT);

  emon1.voltage(1, VOLT_CAL, 1.7);  // Voltage: input pin, calibration, phase_shift
  emon1.current(0, CURRENT_CAL);

  Serial.begin(9600);

  while (!Serial);

  Serial.println("Motor");

  if (!LoRa.begin(433E6)) {
    Serial.println("Starting LoRa failed!");
    while (1);
  }
  emon1.calcVI(20,2000);           // Calculate all. No.of half wavelengths (crossings), time-out
  float currentDraw = emon1.Irms; //extract Irms into Variable
  float supplyVoltage = emon1.Vrms;
}


void loop() {
  int packetSize = LoRa.parsePacket();
  if(packetSize) {
    getLora();  
    if( (String(buffer[2]) == "motor" && String(buffer[1]) == "state") && String(buffer[0]) == id ){
      digitalWrite(D3, HIGH);
      digitalWrite(D7, HIGH);
      t = millis() * 1.000;
      int cont = 0;
      while((millis() - t)/1000 != 35.0) {
        packetSize = LoRa.parsePacket();
        if (packetSize) {
          getLora();
          if( (String(buffer[2]) == "motor" && String(buffer[1]) == "state") && String(buffer[0]) == id ){
              emon1.calcVI(20,2000);           // Calculate all. No.of half wavelengths (crossings), time-out
              float currentDraw = emon1.Irms; //extract Irms into Variable
              float supplyVoltage = emon1.Vrms;
              Serial.println(currentDraw);
              if(currentDraw < 0.25){
                Serial.println("low");
                break;  
              }
              Serial.println(currentDraw);
              LoRa.beginPacket(); 
              LoRa.print(id + ":" + "motorCurrent:" + String(currentDraw) + ":");  
              Serial.println(id + ":" + "motorCurrent:" + String(currentDraw) + ":");
              LoRa.endPacket();  
              t = millis();               
          }
          if( (String(buffer[2]) == "motorStop" && String(buffer[1]) == "state") && String(buffer[0]) == id ) {
            break;  
          }
        }
      } 
      
      LoRa.beginPacket(); 
      LoRa.print(id + ":" + "motorCurrent:" + String(0.0) + ":");  
      Serial.println(id + ":" + "motorCurrent:" + String(0.0) + ":");
      LoRa.endPacket();
      Serial.println("Stopping motor");
      digitalWrite(D3, LOW);
      digitalWrite(D7, 0);
    }
  }
}


void getLora(){
  while(LoRa.available()) {
    int numChars = LoRa.readBytesUntil(termChar, buffer[i], length);
    buffer[i][numChars]='\0';
    Serial.println(buffer[i]);
    Serial.println(i);
    if(i == 2 || String(buffer[0]) != id){
      i = 0;
    }
    else if(i < 2){
      ++i;
    }
  }
  LoRa.packetRssi();  
  Serial.println();
}
