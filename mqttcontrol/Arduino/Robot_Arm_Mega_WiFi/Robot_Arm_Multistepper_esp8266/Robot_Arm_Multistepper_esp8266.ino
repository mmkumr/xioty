#include <ESP8266WiFi.h>
#include <WiFiClientSecure.h>
#include "PubSubClient.h"


//Mqtt
const char* ssid = "Asu";
const char* password = "12341234";
const char* mqttServer = "6b3b54fa5f4a464fa80e2e0410aec35e.s2.eu.hivemq.cloud";
const char* mqtt_username = "xioty";     // MQTT username
const char* mqtt_password = "P@ssw0rd";  // MQTT password
const int mqttPort = 8883;
const char* mqttTopic = "xara/arm";
const char* mqttName = "arm";

WiFiClientSecure espClient;
PubSubClient client(espClient);


void callback(char* topic, byte* payload, unsigned int length) {
  String input = "";
  // Serial.print("Message arrived in topic: ");
  // Serial.println(topic);
  // Serial.print("Message: ");
  for (int i = 0; i < length; i++) {
    input += (char)payload[i];
  }
  Serial.println(input);
  //arm(input);
}
//mqtt end
void setup() {
  Serial.begin(250000);
  //mqtt
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");
  espClient.setInsecure();
  //espClient.setCACert(root_ca);  // enable this line and the the "certificate" code for secure connection
  client.setServer(mqttServer, mqttPort);
  client.setCallback(callback);
  while (!client.connected()) {
    if (client.connect(mqttName, mqtt_username, mqtt_password)) {
      Serial.println("Connected to MQTT broker");
      client.subscribe(mqttTopic);
    } else {
      Serial.print("Failed, rc=");
      Serial.print(client.state());
      Serial.println(" Retrying in 5 seconds...");
      delay(5000);
    }
  }
  //mqtt end
}


void loop() {

  if (Serial.available() > 0) {
    // Read the serial input
    String input = Serial.readStringUntil('\n');
    if (strcmp(input.c_str(), "ok") == 0) {
      client.publish("response", "o");
    }
  }
  client.loop();
}
