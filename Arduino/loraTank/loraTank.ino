#include <SPI.h>
#include <LoRa.h>
#include<math.h>

long t = 0;
int i = 0;

int D3 = 3;
String id = "1234";
String area = "a1234"; //Unique area code.

int length = 25;
char buffer [3][25];
char termChar = ':';
int lowCurrent = 0;


void setup() {
  Serial.begin(9600);
  while (!Serial);
  pinMode(D3, INPUT);
  pinMode(A0, INPUT);
  Serial.println("Tank");

  if (!LoRa.begin(433E6)) {
    Serial.println("Starting LoRa failed!");
    while (1);
  }
}

void loop() {
  int packetSize = LoRa.parsePacket();
  if(packetSize) {
    getLora();
    if( ( (String(buffer[2]) == "water" && String(buffer[1]) == "state") && String(buffer[0]) == area ) && (digitalRead(D3) == LOW) ){
      LoRa.beginPacket();
      LoRa.print(id + ":" + "state:" + "motor:");
      LoRa.endPacket();
      Serial.println("Sending...");
      t = millis();
      lowCurrent = 0;
      while( (digitalRead(D3) == LOW) ){
        packetSize = LoRa.parsePacket();
        if (packetSize){
          getLora();
          getType();
        } 
        if( (millis() - t)/1000 == 15.0){
            Serial.println((millis() - t)/1000);
            LoRa.beginPacket();
            LoRa.print(id + ":" + "state:" + "motor:");
            LoRa.endPacket();
            t = millis(); 
            Serial.println("Sending Signal....");  
        }
        if( (String(buffer[2]) == "waterStop" && String(buffer[1]) == "state") && String(buffer[0]) == area ){
          break;
        }
      }
      Serial.println("Stopping...");
      LoRa.beginPacket();
      LoRa.print(id + ":" + "state:" + "motorStop:");
      LoRa.endPacket();
      t = millis(); 
    }
  }
}


void getLora(){
  while(LoRa.available()) {
    int numChars = LoRa.readBytesUntil(termChar, buffer[i], length);
    buffer[i][numChars]='\0';
    Serial.println(buffer[i]);
    Serial.println(i);
    if( i == 2 || (String(buffer[0]) != area && String(buffer[0]) != id) ){
      i = 0;
    }
    else if(i < 2){
      ++i;
    }
  }
  LoRa.packetRssi();  
  i = 0;
  Serial.println();
}

void getType() {
  if( String(buffer[0]) == id ){
    if(String(buffer[1]) == "motorCurrent"){
      int sensorValue = analogRead(A0);
      float voltage = sensorValue * (4.15 / 1023.0);
      delay(2000);
      LoRa.beginPacket();
      LoRa.print( String(area) + ":" + String(id) + ":" + String(buffer[1]) + ":" + String(buffer[2]) + ":" + String(voltage) + ":");
      Serial.println("current");
      LoRa.endPacket();      
    }
  }  
}
