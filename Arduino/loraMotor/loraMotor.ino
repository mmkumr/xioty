#include <SPI.h>
#include <LoRa.h>
#include <Wire.h>

float current = 0;

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
  digitalWrite(D7, 0);
  Serial.begin(9600);
  Wire.begin();        // join i2c bus (address optional for master)

  while (!Serial);

  Serial.println("Motor");

  if (!LoRa.begin(433E6)) {
    Serial.println("Starting LoRa failed!");
    while (1);
  }
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
              Wire.requestFrom(8, 1);
              while (Wire.available()) { // slave may send less than requested
                int c = Wire.read(); // receive a byte as character
                current = c/100.0;
              }
              Serial.println(current);
              Serial.print(digitalRead(D5));
              if(digitalRead(D5) == LOW){
                break;
              }else{
                cont = 1;
              }
              LoRa.beginPacket(); 
              LoRa.print(id + ":" + "motorCurrent:" + String(current) + ":");  
              Serial.println(id + ":" + "motorCurrent:" + String(current) + ":");
              LoRa.endPacket();  
              Serial.println((millis() - t)/1000);
              t = millis();               
          }
          if( (String(buffer[2]) == "motorStop" && String(buffer[1]) == "state") && String(buffer[0]) == id ) {
            break;  
          }
        }else if(cont == 1){
          Wire.requestFrom(8, 1);
          while (Wire.available()) { // slave may send less than requested
            int c = Wire.read(); // receive a byte as character
            current = c/100.0;
          }
          if(digitalRead(D5) == LOW){
            break;
          }
          
        }
      } 
      if(digitalRead(D5) == LOW){
        LoRa.beginPacket(); 
        LoRa.print(id + ":" + "motorCurrent:" + String(0.0) + ":");  
        Serial.println(id + ":" + "motorCurrent:" + String(0.0) + ":");
        LoRa.endPacket();
        Serial.println("Stopping motor");
      }
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
