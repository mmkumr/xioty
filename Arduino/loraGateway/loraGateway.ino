/*************************************************************
  Download latest Blynk library here:
    https://github.com/blynkkk/blynk-library/releases/latest

  Blynk is a platform with iOS and Android apps to control
  Arduino, Raspberry Pi and the likes over the Internet.
  You can easily build graphic interfaces for all your
  projects by simply dragging and dropping widgets.

    Downloads, docs, tutorials: http://www.blynk.cc
    Sketch generator:           http://examples.blynk.cc
    Blynk community:            http://community.blynk.cc
    Follow us:                  http://www.fb.com/blynkapp
                                http://twitter.com/blynk_app

  Blynk library is licensed under MIT license
  This example code is in public domain.

 *************************************************************
  This example runs directly on ESP8266 chip.

  Note: This requires ESP8266 support package:
    https://github.com/esp8266/Arduino

  Please be sure to select the right ESP8266 module
  in the Tools -> Board menu!

  Change WiFi ssid, pass, and Blynk auth token to run :)
  Feel free to apply it to any other example. It's simple!
 *************************************************************/

/* Comment this out to disable prints and save space */
#define BLYNK_PRINT Serial


#include <ESP8266WiFi.h>
#include <BlynkSimpleEsp8266.h>
#include <LoRa.h>


// You should get Auth Token in the Blynk App.
// Go to the Project Settings (nut icon).
char auth[] = "8tBKb8ZJXgUbyERoeZSfINGEcsHP0jAm";

// Your WiFi credentials.
// Set password to "" for open networks.
char ssid[] = "mmkumr";
char pass[] = "244466666";

char inChar;

#define ss 15
#define rst 16
#define dio0 2
WidgetLCD lcd(V1);


BLYNK_WRITE(V0)
{
  int pinValue = param.asInt(); // assigning incoming value from pin V1 to a variable
  Serial.println(param.asInt());
  if(pinValue == 1){
    lcd.clear();
    LoRa.beginPacket();  
    LoRa.print("water:");
    LoRa.endPacket();    
  } else {
    lcd.clear();
    lcd.print(0, 0, "OFF");
    LoRa.beginPacket();  
    LoRa.print("waterStop:");
    LoRa.endPacket(); 
  }
}


void setup()
{
  // Debug console
  Serial.begin(9600);
  while (!Serial);  
  LoRa.setPins(ss, rst, dio0);
  Serial.println("LoRa Sender");
  if (!LoRa.begin(433E6)) { // or 915E6, the MHz speed of yout module
    Serial.println("Starting LoRa failed!");
    while (1);
  }
  Blynk.begin(auth, ssid, pass);
}

void loop()
{
  Blynk.run();
  char buffer [1][14];
  int length = 13;
  char termChar = ':';
  // try to parse packet
  int packetSize = LoRa.parsePacket();
  if (packetSize) {
    // received a packet
    Serial.print("Received packet ");
    // read packet
    while (LoRa.available()) {
      int numChars = LoRa.readBytesUntil(termChar, buffer[0], length);
      buffer[0][numChars]='\0';
      Serial.println(String(buffer[0]));
    }
    LoRa.packetRssi();
    if( String(buffer[0]).toFloat() != 0.0 ){
      Serial.println(buffer[0]);
      lcd.print(0, 10, buffer[0]);
    }
  }
}
