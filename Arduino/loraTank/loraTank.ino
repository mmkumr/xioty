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
  int packetSize = LoRa.parsePacket();
  if(packetSize) {
    getLora();
    if( ( (String(buffer[2]) == "water" && String(buffer[1]) == "state") && String(buffer[0]) == area ) && (digitalRead(D3) == LOW) ){
      delay(2000);
      LoRa.beginPacket();
      LoRa.print(id + ":" + "state:" + "motor:");
      LoRa.endPacket();
      Serial.println("Sending...");
      t = millis();
      while( (digitalRead(D3) == LOW) ){
        packetSize = LoRa.parsePacket();
        if (packetSize){
          getLora();
          getType();
        } 
        if( (millis() - t)/1000 == 30.0){
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
      delay(2000);
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
    if(i == 2){
      i = 0;
    }
    else if(i < 2){
      ++i;
    }
  }
  LoRa.packetRssi();  
}

void getType() {
  if( String(buffer[0]) == id ){
    if(String(buffer[1]) == "motorCurrent"){
      delay(2000);
      LoRa.beginPacket();
      LoRa.print( String(area) + ":" + String(id) + ":" + String(buffer[1]) + ":" + String(buffer[2]) + ":");
      LoRa.endPacket();
    }
  }  
}
