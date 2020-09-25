#include <SPI.h>
#include <LoRa.h>
//#include <nRF24L01.h>
//#include <RF24.h>
//RF24 radio(9, 10); // CE, CSN
const byte address[6] = "00001";
boolean button_state = 0;
int startButton = 3;
int startCapacitor = 4;
int stopButton = 5;
long t = 0;

int i = 0;
void setup() {
pinMode(startButton, OUTPUT);//on
pinMode(startCapacitor, OUTPUT);//on
pinMode(stopButton, OUTPUT);//off
pinMode(2, OUTPUT);//on
digitalWrite(2, LOW);

  Serial.begin(9600);

  while (!Serial);

  Serial.println("Motor");

  if (!LoRa.begin(433E6)) {
    Serial.println("Starting LoRa failed!");
    while (1);
  }

//Serial.begin(9600);
//radio.begin();
//radio.openReadingPipe(0, address);   //Setting the address at which we will receive the data
//radio.setPALevel(RF24_PA_MIN);       //You can set this as minimum or maximum depending on the distance between the transmitter and receiver.
//radio.startListening();              //This sets the module as receiver
}
void loop() {
  int packetSize = LoRa.parsePacket();
  char lora;
  if(packetSize){
    while(LoRa.available()) {
      lora = (char)LoRa.read();
      Serial.println(lora);
    }
    LoRa.packetRssi();
    if(lora == 'a'){
      Serial.println("on");
      digitalWrite(startButton, HIGH);
      digitalWrite(startCapacitor, HIGH);
      delay(1500);
      digitalWrite(startButton, LOW);
      digitalWrite(startCapacitor, LOW);
      t = millis();
      while( round((millis() - t)/1000) != 10){
        char lora;
        if(LoRa.parsePacket()){
          while(LoRa.available()) {
            lora = (char)LoRa.read();
            Serial.println(lora);
          }
          LoRa.packetRssi();
          if(lora == 'a'){
            //digitalWrite(startButton, HIGH);
            //delay(1000);
            //digitalWrite(startButton, LOW);
            t = millis();
            Serial.println("on");
          }
        }
      }
      Serial.println("off");
      digitalWrite(stopButton, HIGH);
      delay(1500);
      digitalWrite(stopButton, LOW);
    }
  }
}
