/*
 * ESP8266 (Adafruit HUZZAH) Mosquitto MQTT Publish Example
 * Thomas Varnish (https://github.com/tvarnish), (https://www.instructables.com/member/Tango172)
 * Made as part of my MQTT Instructable - "How to use MQTT with the Raspberry Pi and ESP8266"
 */

#include <WiFi.h> // Enables the ESP8266 to connect to the local network (via WiFi)
#include <PubSubClient.h> // Allows us to connect to, and publish to the MQTT broker
#include "EmonLib.h"                   // Include Emon Library
EnergyMonitor emon1;
EnergyMonitor emon2;



const int ledPin = 0; // This code uses the built-in led for visual feedback that the button has been pressed
//const int buttonPin = 13; // Connect your button to pin #13

// WiFi
// Make sure to update this for your own WiFi network!
const char* ssid = "mmkumr";
const char* wifi_password = "P@$$w0rd";

// MQTT
// Make sure to update this for your own MQTT Broker!
const char* mqtt_server = "192.168.43.119";
const char* mqtt_topic1 = "current1";
const char* mqtt_topic2 = "current2";

// The client id identifies the ESP8266 device. Think of it a bit like a hostname (Or just a name, like Greg).
const char* clientID = "Sensor3";



// Initialise the WiFi and MQTT Client objects
WiFiClient wifiClient;
PubSubClient client(mqtt_server, 1883, wifiClient); // 1883 is the listener port for the Broker

void setup() {
  emon1.current(34, 6.6);
  emon2.current(35, 6.6);
  Serial.begin(9600);

  Serial.print("Connecting to ");
  Serial.println(ssid);

  // Connect to the WiFi
  WiFi.begin(ssid, wifi_password);

  // Wait until the connection has been confirmed before continuing
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  // Debugging - Output the IP Address of the ESP8266
  Serial.println("WiFi connected");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());

  // Connect to MQTT Broker
  // client.connect returns a boolean value to let us know if the connection was successful.
  if (client.connect(clientID)) {
    Serial.println("Connected to MQTT Broker!");
    
  }
  else {
    Serial.println("Connection to MQTT Broker failed...");
  }
  
}

void loop() {

  float lowvolt, highvolt, pressure, calibration;
  int sensor;
    float temp;
    float humidity; 

    //temp = sht1x.readTemperatureC(); //new adc code
    //humidity = sht1x.readHumidity();
 
    // PUBLISH to the MQTT Broker (topic = mqtt_topic, defined at the beginning)
    // Here, "Button pressed!" is the Payload, but this could be changed to a sensor reading, for example.
    double Irms = emon1.calcIrms(1480);  // Calculate Irms only
    Serial.println();
    if(client.publish(mqtt_topic1, String(Irms/10).c_str())) 
    {
      Serial.println("Current1 DATA SENT");
      Serial.println(String(Irms/10));
    }
    Irms = emon1.calcIrms(1480);
    if(client.publish(mqtt_topic2, String(Irms/10).c_str())) 
    {
      Serial.println("Current2 DATA SENT");
      Serial.println(String(Irms/10));
      delay(500);
    }
    
    // Again, client.publish will return a boolean value depending on whether it succeded or not.
    // If the message failed to send, we will try again, as the connection may have broken.
    else {
      Serial.println("Message failed to send. Reconnecting to MQTT Broker and trying again");
      client.connect(clientID);
      delay(10); // This delay ensures that client.publish doesn't clash with the client.connect call
      client.publish(mqtt_topic1, "Null");
    }
    
  
  
}
