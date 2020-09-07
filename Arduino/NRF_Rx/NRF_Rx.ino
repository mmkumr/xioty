#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>
RF24 radio(9, 10); // CE, CSN
const byte address[6] = "00001";
boolean button_state = 0;
int startButton = 3;
int startCapacitor = 4;
int stopButton = 5;
long t = 0;

void setup() {
pinMode(startButton, OUTPUT);//on
pinMode(startCapacitor, OUTPUT);//on
pinMode(stopButton, OUTPUT);//off
Serial.begin(9600);
radio.begin();
radio.openReadingPipe(0, address);   //Setting the address at which we will receive the data
radio.setPALevel(RF24_PA_MIN);       //You can set this as minimum or maximum depending on the distance between the transmitter and receiver.
radio.startListening();              //This sets the module as receiver
}
void loop()
{
  if (radio.available()){              //Looking for the data.
    char text[32] = "";                 //Saving the incoming data
    radio.read(&text, sizeof(text));    //Reading the data
    if(String(text) == "motorOn"){
      digitalWrite(startButton, HIGH);
      digitalWrite(startCapacitor, HIGH);
      Serial.println("on");
      delay(1500);
      digitalWrite(startButton, LOW);
      digitalWrite(startCapacitor, LOW);
      t = millis() * 1.000;
      while( (millis() - t)/1000 != 12){
        if (radio.available()){
          radio.read(&text, sizeof(text));    //Reading the data
          if(String(text) == "motorOn"){
            Serial.println( (millis() - t)/1000);
            t = millis();
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
