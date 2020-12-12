#include <SPI.h>
#include <LoRa.h>
#include<math.h>

#define ss 5
#define rst 14
#define dio0 2

long t = 0;
int i = 0;
int low = 0;

int sensor = 3;
String id = "1234";
String area = "a1234"; //Unique area code.

int length = 25;
char buffer [6][50];
char termChar = ':';
int lowCurrent = 0;


void setup() {
  Serial.begin(9600);
  while (!Serial);
  pinMode(sensor, INPUT_PULLUP);
  pinMode(A0, INPUT);
  Serial.println("Tank");
  //LoRa.setPins(ss, rst, dio0);
  if (!LoRa.begin(433E6)) {
    Serial.println("Starting LoRa failed!");
    while (1);
  }
}

void loop() {
  int packetSize = LoRa.parsePacket();
  if(packetSize) {
    getLora();
    getType();
    if( ( (String(buffer[2]) == "water" && String(buffer[1]) == "state") && String(buffer[0]) == area ) && (digitalRead(sensor) == LOW) ){
      delay(1000);
      LoRa.beginPacket();
      LoRa.print(id + ":" + "state:" + "motor:");
      LoRa.endPacket();
      Serial.println("Sending...");
      t = millis();
      low = 0;
      while( (digitalRead(sensor) == LOW) && low == 0){
        packetSize = LoRa.parsePacket();
        if (packetSize){
          getLora();
          getType();
        } 
//        if( (millis() - t)/1000 == 15.0){
//            Serial.println((millis() - t)/1000);
//            LoRa.beginPacket();
//            LoRa.print(id + ":" + "state:" + "motor:");
//            LoRa.endPacket();
//            t = millis(); 
//            Serial.println("Sending Signal....");  
//        }
        if(( (String(buffer[2]) == "waterStop" && String(buffer[1]) == "state") && String(buffer[0]) == area ) ){
          low = 1;
        } 
      } 
      for(int j = 0; j < 3; j++){
          if(packetSize){
            getLora();
            getType();
          } 
          delay(1500);
          Serial.println("Stopping...");
          LoRa.beginPacket();
          LoRa.print(id + ":" + "state:" + "motorStop:");
          LoRa.endPacket();
          //delay(2000);             
      }
    }
  }
}


void getLora(){
  int ok = 0;
  while(LoRa.available()) {
    int numChars = LoRa.readBytesUntil(termChar, buffer[i], length);
    buffer[i][numChars]='\0';
    Serial.println(buffer[i]);
    Serial.println(i);
    if(String(buffer[0]) == id){
      ok = 1;
    }
    if( i == 2 || (String(buffer[0]) != area && String(buffer[0]) != id) ){
      i = 0;
    }
    else if(i < 2){
      ++i;
    }
  }
  LoRa.packetRssi();  
  i = 0;
  if(ok == 1){
    strcpy(buffer[0], "1234");  
    ok = 0;
  }
}

void getType() {
  if( String(buffer[0]) == id ){
    Serial.println(buffer[0]);
    if(String(buffer[1]) == "motorCurrent"){
      int sensorValue = analogRead(A0);
      float voltage = sensorValue * (4.15 / 1023.0);
      if(String(buffer[2]) == "0.0"){
       low = 1; 
      }
      delay(1000);
      LoRa.beginPacket();
      LoRa.println( String(area) + ":" + String(id) + ":" + String(buffer[1]) + ":" + String(buffer[2]) + ":" + String(voltage) + ":");
      Serial.println( String(area) + ":" + String(id) + ":" + String(buffer[1]) + ":" + String(buffer[2]) + ":" + String(voltage) + ":");
      LoRa.endPacket(); 
    }
  } 

  if(( (String(buffer[2]) == "sendCurrent" && String(buffer[1]) == "state") && String(buffer[0]) == area ) ){
    for(int j = 0; j < 2; j++){
        delay(2000);
        Serial.println("Send Current...");
        LoRa.beginPacket();
        LoRa.print(id + ":" + "state:" + "sendCurrent:");
        LoRa.endPacket();
        //delay(2000);             
    }
  }
}
