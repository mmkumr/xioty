#include <SPI.h>
#include <LoRa.h>

int flag1=0;
int flag2=0;

void setup() 
{
  Serial.begin(9600);  
  while (!Serial);  
  Serial.println("LoRa Sender");
  if (!LoRa.begin(433E6)) { // or 915E6, the MHz speed of yout module
    Serial.println("Starting LoRa failed!");
    while (1);
  }
}

void loop() 
{
  
  LoRa.beginPacket();  
  LoRa.print('a');
  LoRa.endPacket();
  delay(30000);
 
}
