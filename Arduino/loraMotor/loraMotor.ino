#include <Wire.h>
#include <SPI.h>
#include <LoRa.h>
#include "ACS712.h"

#define ss 5
#define rst 14
#define dio0 2

int s = 0;
int sendc = 0;
float current;

char irms[6];

// Arduino UNO has 5.0 volt with a max ADC value of 1023 steps
// ACS712 5A  uses 185 mV per A
// ACS712 20A uses 100 mV per A
// ACS712 30A uses  66 mV per A

ACS712  ACS(A0, 5.0, 1023, 185);
// ESP 32 example (requires resistors to step down the logic voltage)
//ACS712  ACS(25, 5.0, 4095, 185);

int i = 0;
String id = "1234";
int length = 25;
char buffer[6][50]; //variable for storing the data received to lora
char termChar = ':'; //Termination character for lora data.

long t; //variable for storing time.

int led = 3;
int relay = 7;



void setup(){
  pinMode(led, OUTPUT);
  pinMode(relay, OUTPUT);
  
  Serial.begin(9600);
    
  while (!Serial);
//  LoRa.setPins(ss, rst, dio0);
  Serial.println("Motor");

  if (!LoRa.begin(433E6)) {
    Serial.println("Starting LoRa failed!");
    while (1);
  }
  ACS.autoMidPoint();
  Serial.print("MidPoint: ");
  Serial.print(ACS.getMidPoint());
  Serial.print(". Noise mV: ");
  Serial.println(ACS.getNoisemV());  
}

void loop(){
  int packetSize = LoRa.parsePacket();
  if(packetSize) {
    getLora(); 
    if( (String(buffer[2]) == "motor" && String(buffer[1]) == "state") && String(buffer[0]) == id ){
      digitalWrite(led, HIGH);
      digitalWrite(relay, HIGH);
      t = millis() * 1.000;
      delay(2000);
      current = ACS.mA_AC()/1000.00;
      Serial.println(id + ":" + "motorCurrent:" + String(current).c_str() + ":");
      LoRa.beginPacket(); 
      LoRa.print(id + ":" + "motorCurrent:" + String(current).c_str() + ":");  
      //LoRa.endPacket();
      if(!LoRa.endPacket()){
        Serial.println("LoRa failed to send");  
        LoRa.begin(433E6);
        current = ACS.mA_AC()/1000.00;
        LoRa.beginPacket(); 
        LoRa.print(id + ":" + "motorCurrent:" + String(current).c_str() + ":");
        LoRa.endPacket();
      }
      LoRa.begin(433E6);
      t = millis();
      s = 0;
      sendc = 0;
      while(s == 0){
        packetSize = LoRa.parsePacket();
        if (packetSize) {
          getLora();
          if( (String(buffer[2]) == "motorStop" && String(buffer[1]) == "state") && String(buffer[0]) == id ) {
            s = 1;  
          }
          else if( (String(buffer[2]) == "sendCurrent" && String(buffer[1]) == "state") && String(buffer[0]) == id ) {
            sendc = 1;  
            Serial.println("Calculating..");
          }
        }
        else if((millis() - t)/1000 == 5.0){
            if(sendc == 1){
              current = ACS.mA_AC()/1000.00;
              Serial.println(id + ":" + "motorCurrent:" + String(current).c_str() + ":");
              LoRa.beginPacket(); 
              LoRa.print(id + ":" + "motorCurrent:" + String(current).c_str() + ":");  
              if(!LoRa.endPacket()){
                Serial.println("LoRa failed to send");
                current = ACS.mA_AC()/1000.00;
                LoRa.beginPacket(); 
                LoRa.print(id + ":" + "motorCurrent:" + String(current).c_str() + ":");
                LoRa.endPacket();
              }
              LoRa.begin(433E6);

              sendc = 0;
              
            }
            if( (ACS.mA_AC()/1000.00) < 0.25){
              Serial.println("low");
              s = 1; 
            }
            t = millis();
        }

      }
      digitalWrite(led, LOW);
      digitalWrite(relay, LOW);
      Serial.println(id + ":" + "motorCurrent:" + String(0.0).c_str() + ":");
      LoRa.beginPacket(); 
      LoRa.print(id + ":" + "motorCurrent:" + String(0.0).c_str() + ":");  
      if(!LoRa.endPacket()){
        Serial.println("LoRa failed to send");
        LoRa.beginPacket(); 
        LoRa.print(id + ":" + "motorCurrent:" + String(0.0).c_str() + ":");
        LoRa.endPacket();
      }
      LoRa.begin(433E6);
      Serial.println("Stopping motor");
      
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
