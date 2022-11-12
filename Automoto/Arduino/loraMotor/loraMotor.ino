#include <Wire.h>
#include <SPI.h>
#include <LoRa.h>

#define ss 5
#define rst 14
#define dio0 2

int s = 0;
int sendc = 0;
float current;
int c;
char irms[6];


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
  Wire.begin();
  Serial.begin(9600);
    
  while (!Serial);
//  LoRa.setPins(ss, rst, dio0);
  Serial.println("Motor");

  if (!LoRa.begin(433E6)) {
    Serial.println("Starting LoRa failed!");
    while (1);
  }
  
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
      Wire.requestFrom(8, 1);    // request 6 bytes from slave device #8

      while (Wire.available()) { // slave may send less than requested
        c = Wire.read(); // receive a byte as character
      }
      current = c/100.00;
      LoRa.begin(433E6);
      LoRa.beginPacket(); 
      LoRa.println(id + ":" + "motorCurrent:" + String(c) + ":");  
      LoRa.endPacket();
      Serial.println(id + ":" + "motorCurrent:" + String(c) + ":");

//      if(!LoRa.endPacket()){
//        Serial.println("LoRa failed to send");  
//        LoRa.begin(433E6);
//        Wire.requestFrom(8, 1);    // request 6 bytes from slave device #8
//
//        while (Wire.available()) { // slave may send less than requested
//          c = Wire.read(); // receive a byte as character
//        }
//        current = c/100.00;
//        LoRa.beginPacket(); 
//        LoRa.print(id + ":" + "motorCurrent:" + String(current).c_str() + ":");
//        LoRa.endPacket();
//      }
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
              Wire.requestFrom(8, 1);    // request 6 bytes from slave device #8

              while (Wire.available()) { // slave may send less than requested
                c = Wire.read(); // receive a byte as character
              }
              Wire.requestFrom(8, 1);    // request 6 bytes from slave device #8

              while (Wire.available()) { // slave may send less than requested
                c = Wire.read(); // receive a byte as character
              }
              current = c/100.00;
              Serial.println(id + ":" + "motorCurrent:" + String(c) + ":");
              LoRa.beginPacket(); 
              LoRa.println(id + ":" + "motorCurrent:" + String(c) + ":");  
              LoRa.endPacket();
//              if(!LoRa.endPacket()){
//                Serial.println("LoRa failed to send");
//                Wire.requestFrom(8, 1);    // request 6 bytes from slave device #8
//
//                while (Wire.available()) { // slave may send less than requested
//                  c = Wire.read(); // receive a byte as character
//                }
//                current = c/100.00;
//                LoRa.beginPacket(); 
//                LoRa.println(id + ":" + "motorCurrent:" + String(current).c_str() + ":");
//                LoRa.endPacket();
//              }
              LoRa.begin(433E6);

              sendc = 0;
              
            }
            Wire.requestFrom(8, 1);    // request 6 bytes from slave device #8

            while (Wire.available()) { // slave may send less than requested
              c = Wire.read(); // receive a byte as character
            }
            current = c/100.00;
            if(current < 0.25){
              Serial.println("low");
              s = 1; 
            }
            t = millis();
        }

      }
      digitalWrite(led, LOW);
      digitalWrite(relay, LOW);
      Serial.println(id + ":" + "motorCurrent:" + "0.0" + ":");
      LoRa.beginPacket(); 
      LoRa.println(id + ":" + "motorCurrent:" + "0.0" + ":");  
      LoRa.endPacket();
//      if(!LoRa.endPacket()){
//        Serial.println("LoRa failed to send");
//        LoRa.beginPacket(); 
//        LoRa.println(id + ":" + "motorCurrent:" + String(0.0).c_str() + ":");
//        LoRa.endPacket();
//      }
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
