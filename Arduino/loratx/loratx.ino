#include <SPI.h>
#include <LoRa.h>

int flag1=0;
int flag2=0;
int d4 = 4;
float voltage;

void setup() 
{
  pinMode(A1,OUTPUT);
  pinMode(A0,INPUT);
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
  analogWrite(A1, 0);
  voltage = analogRead(A0) * (8.0/1024.0);
  Serial.println(voltage);
  LoRa.beginPacket();  
  LoRa.print('a');
  LoRa.endPacket();
  delay(300);
 
}
