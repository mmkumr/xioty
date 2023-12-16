#line 1 "/run/media/mmkumr/MyWorkspace/Projects/xioty/mqttcontrol/Arduino/Ind_Command/Ind_Command.ino"
// command: ind temp_val/0/1

#include <Arduino.h>
#include "WiFi.h"
#include "PubSubClient.h"

// Define the GPIO pins for the button controls
const int upButtonPin = 27;     // Up button
const int downButtonPin = 14;   // Down button
const int powerButtonPin = 12;  // Power (on/off) button


// Define the initial heat level
int currentHeatLevel = 4;

// Variable to track the target heat level
int targetHeatLevel = 4;

//mqtt
const char* ssid = "ConnectndEnjoy";
const char* password = "P@$$w0rd";
const char* mqttServer = "6b3b54fa5f4a464fa80e2e0410aec35e.s2.eu.hivemq.cloud";
const char* mqtt_username = "xara";  // MQTT username
const char* mqtt_password = "xara";  // MQTT password
const int mqttPort = 8883;
const char* mqttTopic = "xara/induction";
const char* mqttName = "induction";

WiFiClient espClient;
PubSubClient client(espClient);
#line 31 "/run/media/mmkumr/MyWorkspace/Projects/xioty/mqttcontrol/Arduino/Ind_Command/Ind_Command.ino"
void callback(char* topic, byte* payload, unsigned int length);
#line 45 "/run/media/mmkumr/MyWorkspace/Projects/xioty/mqttcontrol/Arduino/Ind_Command/Ind_Command.ino"
void setup();
#line 88 "/run/media/mmkumr/MyWorkspace/Projects/xioty/mqttcontrol/Arduino/Ind_Command/Ind_Command.ino"
void loop();
#line 96 "/run/media/mmkumr/MyWorkspace/Projects/xioty/mqttcontrol/Arduino/Ind_Command/Ind_Command.ino"
void induction(String input);
#line 132 "/run/media/mmkumr/MyWorkspace/Projects/xioty/mqttcontrol/Arduino/Ind_Command/Ind_Command.ino"
void adjustHeatLevel();
#line 31 "/run/media/mmkumr/MyWorkspace/Projects/xioty/mqttcontrol/Arduino/Ind_Command/Ind_Command.ino"
void callback(char* topic, byte* payload, unsigned int length) {
  String input = "";
  Serial.print("Message arrived in topic: ");
  Serial.println(topic);
  Serial.print("Message: ");
  for (int i = 0; i < length; i++) {
    input += (char)payload[i];
  }
  Serial.println(input);
  client.publish("response", "o");
  induction(input);
}
//end of mqtt

void setup() {
  // Initialize serial communication
  Serial.begin(115200);
  //mqtt
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi...");
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print("..");
  }
  Serial.println();
  Serial.println("Connected to WiFi");

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
  //end of mqtt
  // Set button control pins as outputs
  pinMode(upButtonPin, OUTPUT);
  pinMode(downButtonPin, OUTPUT);
  pinMode(powerButtonPin, OUTPUT);

  digitalWrite(upButtonPin, HIGH);
  digitalWrite(downButtonPin, HIGH);
  digitalWrite(powerButtonPin, HIGH);
  delay(5000);
  // Initially, turn the induction cooktop off
  // digitalWrite(powerButtonPin, LOW);
  // delay(500); // Simulate button press
  // digitalWrite(powerButtonPin, HIGH);
}
int t = 0;      // Temperature input
int state = 0;  // Power status of Induction cooker.
void loop() {
  if (Serial.available()) {
    String input = Serial.readStringUntil('\n');
    induction(input);
  }
  client.loop();
}

void induction(String input) {
  if (sscanf(input.c_str(), "ind %d", &t) == 1) {
    if (t == 0) {
      digitalWrite(powerButtonPin, LOW);
      delay(500);  // Simulate button press
      digitalWrite(powerButtonPin, HIGH);
    }
    if (state == 0) {
      targetHeatLevel = 4;
      currentHeatLevel = targetHeatLevel;
      digitalWrite(powerButtonPin, LOW);
      delay(500);  // Simulate button press
      digitalWrite(powerButtonPin, HIGH);
      state = 1;
    }
    if (t == 200) {
      targetHeatLevel = 0;
    } else if (t == 400) {
      targetHeatLevel = 1;
    } else if (t == 800) {
      targetHeatLevel = 2;
    } else if (t == 1000) {
      targetHeatLevel = 3;
    } else if (t == 1300) {
      targetHeatLevel = 4;
    } else if (t == 1600) {
      targetHeatLevel = 5;
    } else if (t == 1800) {
      targetHeatLevel = 6;
    } else if (t == 2000) {
      targetHeatLevel = 7;
    }
    adjustHeatLevel();
  }
}
// Function to adjust the heat level
void adjustHeatLevel() {
  // Calculate the number of steps (up or down)
  int steps = targetHeatLevel - currentHeatLevel;
  Serial.println(steps);
  // Simulate button presses to reach the target heat level
  if (steps > 0) {
    for (int i = 0; i < steps; i++) {
      digitalWrite(upButtonPin, LOW);
      delay(500);  // Simulate button press
      digitalWrite(upButtonPin, HIGH);
      delay(500);  // Delay between button presses
    }
  } else if (steps < 0) {
    steps = abs(steps);
    for (int i = 0; i < steps; i++) {
      digitalWrite(downButtonPin, LOW);
      delay(500);  // Simulate button press
      digitalWrite(downButtonPin, HIGH);
      delay(500);  // Delay between button presses
    }
  }

  // Update the current heat level
  currentHeatLevel = targetHeatLevel;

  // Print the new heat level for debugging
  // Serial.print("Heat Level: ");
  // Serial.println(currentHeatLevel);
}

