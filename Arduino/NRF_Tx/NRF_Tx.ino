#include <SPI.h>
#include <LoRa.h>
//#include <nRF24L01.h>
//#include <RF24.h>
//RF24 radio(9, 10); // CE, CSN         
//const byte address[6] = "00001";     //Byte of array representing the address. This is the address where we will send the data. This should be same on the receiving side.
//int button_pin = 2;
//boolean button_state = 0;

String id = "1234";

void setup() {
  Serial.begin(9600);
  while (!Serial);

  Serial.println("LoRa Sender");

  if (!LoRa.begin(433E6)) {
    Serial.println("Starting LoRa failed!");
    while (1);
  }
  LoRa.setTxPower(20);
//  Serial.begin(9600);
//  pinMode(button_pin, INPUT_PULLUP);
//  radio.begin();                  //Starting the Wireless communication
//  radio.openWritingPipe(address); //Setting the address where we will send the data
//  radio.setPALevel(RF24_PA_MIN);  //You can set it as minimum or maximum depending on the distance between the transmitter and receiver.
//  radio.stopListening();          //This sets the module as transmitter
}
void loop(){
  LoRa.beginPacket();
  LoRa.print('a');
  Serial.println('a');
  LoRa.endPacket();
  //Qradio.openWritingPipe(address); //Setting the address where we will send the data
//  button_state = digitalRead(button_pin);
//  const char text[] = "motorOn";
//  radio.write(&text, sizeof(text)); //Sending the message to receiver
  delay(3000);
}
