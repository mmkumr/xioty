/*
G0 XPos YPos Zpos
G0 Xpos YPos
G0 XPos ZPos
G0 YPos ZPos
G0 XPos
G0 YPos
G0 ZPos
H 0 (For homing all three axis.)
M17 X/Y/Z enable motors
M18 X/Y/Z disable motors
*/
#include "WiFi.h"
#include "PubSubClient.h"
#include <AccelStepper.h>
#include <MultiStepper.h>

//Mqtt
const char* ssid = "Asu";
const char* password = "12341234";
const char* mqttServer = "192.168.27.253";
const char* mqtt_username = "xara";  // MQTT username
const char* mqtt_password = "xara";  // MQTT password
const int mqttPort = 1883;
const char* mqttTopic = "xara/arm";
const char* mqttName = "arm"

  WiFiClient espClient;
PubSubClient client(espClient);
void callback(char* topic, byte* payload, unsigned int length) {
  String input = "";
  Serial.print("Message arrived in topic: ");
  Serial.println(topic);
  Serial.print("Message: ");
  for (int i = 0; i < length; i++) {
    input += (char)payload[i];
  }
  Serial.println(input);
  arm(input);
  client.publish("response", "o");
}
//mqtt end
// EG X-Y position bed driven by 2 steppers
// Alas its not possible to build an array of these with different pins for each :-(
AccelStepper stepper1(AccelStepper::DRIVER, 4, 5);    // Motor 1 (Step, Dir);
AccelStepper stepper2(AccelStepper::DRIVER, 12, 13);  // Motor 2 (Step, Dir);
AccelStepper stepper3(AccelStepper::DRIVER, 18, 19);  // Motor 3 (Step, Dir);

// Motor pins
const int enablePin1 = 23;  // Motor 1 Enable
const int enablePin2 = 25;  // Motor 2 Enable
const int enablePin3 = 21;  // Motor 3 Enable
const int dir1 = 5;
const int dir2 = 13;
const int dir3 = 19;
const int step1 = 4;
const int step2 = 12;
const int step3 = 18;
const int lim1 = 14;
const int lim2 = 27;
const int lim3 = 26;
////////////////////////////////////////////////

// Up to 10 steppers can be handled as a group by MultiStepper
MultiStepper steppers;
MultiStepper steppersxy;
MultiStepper steppersxz;
MultiStepper steppersyz;

void setup() {
  Serial.begin(115200);
  pinMode(enablePin1, OUTPUT);
  pinMode(enablePin2, OUTPUT);
  pinMode(enablePin3, OUTPUT);
  digitalWrite(enablePin1, HIGH);
  digitalWrite(enablePin2, HIGH);
  digitalWrite(enablePin3, HIGH);
  // Configure each stepper's max speed
  stepper1.setMaxSpeed(500);
  stepper2.setMaxSpeed(500);
  stepper3.setMaxSpeed(500);

  // Then give them to MultiStepper to manage
  steppers.addStepper(stepper1);
  steppers.addStepper(stepper2);
  steppers.addStepper(stepper3);
  // intializing xy multis
  steppersxy.addStepper(stepper1);
  steppersxy.addStepper(stepper2);
  // intializing xz multis
  steppersxz.addStepper(stepper1);
  steppersxz.addStepper(stepper3);
  // intializing yz multis
  steppersyz.addStepper(stepper2);
  steppersyz.addStepper(stepper3);
  //mqtt
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
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
  //mqtt end
}

long pos[3] = { 0, 0, 0 };  // Array for storing positions.

void loop() {
  // long positions[3]; // Array of desired stepper positions

  // positions[0] = 1000;
  // positions[1] = 2000;
  // steppers.moveTo(positions);
  // steppers.runSpeedToPosition(); // Blocks until all are in position
  // Check for incoming serial commands
  if (Serial.available() > 0) {
    // Read the serial input
    String input = Serial.readStringUntil('\n');
    Serial.println(input);
    arm(input);
  }
  client.loop();
}


void arm(String input) {
  // Parse the input to get motor number and position
  char dis[5];  // Array for storing disable mode.
  char en[5];   // Array for storing enable mode.
  int home;
  int feedrate;
  if (sscanf(input.c_str(), "G0 X%ld Y%ld Z%ld", &pos[0], &pos[1], &pos[2]) == 3) {
    digitalWrite(enablePin1, LOW);
    digitalWrite(enablePin2, LOW);
    digitalWrite(enablePin3, LOW);
    steppers.moveTo(pos);
    steppers.runSpeedToPosition();
  } else if (sscanf(input.c_str(), "G0 X%ld Y%ld", &pos[0], &pos[1]) == 2) {
    digitalWrite(enablePin1, LOW);
    digitalWrite(enablePin2, LOW);
    steppers.moveTo(pos);
    steppers.runSpeedToPosition();
  } else if (sscanf(input.c_str(), "G0 X%ld Z%ld", &pos[0], &pos[2]) == 2) {
    digitalWrite(enablePin1, LOW);
    digitalWrite(enablePin3, LOW);
    steppers.moveTo(pos);
    steppers.runSpeedToPosition();
  } else if (sscanf(input.c_str(), "G0 Y%ld Z%ld", &pos[1], &pos[2]) == 2) {
    digitalWrite(enablePin2, LOW);
    digitalWrite(enablePin3, LOW);
    steppers.moveTo(pos);
    steppers.runSpeedToPosition();
  } else if (sscanf(input.c_str(), "G0 X%ld", &pos[0]) == 1) {
    digitalWrite(enablePin1, LOW);
    stepper1.setSpeed(1000);
    stepper1.setAcceleration(500);
    steppers.moveTo(pos);
    steppers.runSpeedToPosition();
  } else if (sscanf(input.c_str(), "G0 Y%ld", &pos[1]) == 1) {
    digitalWrite(enablePin2, LOW);
    steppers.moveTo(pos);
    steppers.runSpeedToPosition();
  } else if (sscanf(input.c_str(), "G0 Z%ld", &pos[2]) == 1) {
    digitalWrite(enablePin3, LOW);
    steppers.moveTo(pos);
    steppers.runSpeedToPosition();
  } else if (sscanf(input.c_str(), "G0 F%ld", &feedrate) == 1) {
    stepper1.setMaxSpeed(feedrate);
    stepper2.setMaxSpeed(feedrate);
    stepper3.setMaxSpeed(feedrate);
  } else if (sscanf(input.c_str(), "M18 %s", dis) == 1) {
    if (strcmp(dis, "XYZ") == 0) {
      Serial.println("Disabling XYZ");
      digitalWrite(enablePin1, HIGH);
      digitalWrite(enablePin2, HIGH);
      digitalWrite(enablePin3, HIGH);
    } else if (strcmp(dis, "Y") == 0) {
      Serial.println("Disabling Y");
      digitalWrite(enablePin2, HIGH);
    } else if (strcmp(dis, "Z") == 0) {
      Serial.println("Disabling Z");
      digitalWrite(enablePin3, HIGH);
    } else if (strcmp(dis, "XY") == 0) {
      Serial.println("Disabling XY");
      digitalWrite(enablePin1, HIGH);
      digitalWrite(enablePin2, HIGH);
    } else if (strcmp(dis, "XZ") == 0) {
      Serial.println("Disabling XZ");
      digitalWrite(enablePin1, HIGH);
      digitalWrite(enablePin3, HIGH);
    } else if (strcmp(dis, "YZ") == 0) {
      Serial.println("Disabling YZ");
      digitalWrite(enablePin2, HIGH);
      digitalWrite(enablePin3, HIGH);
    } else if (strcmp(dis, "X") == 0) {
      Serial.println("Disabling X");
      digitalWrite(enablePin1, HIGH);
    }
  } else if (sscanf(input.c_str(), "M17 %s", en) == 1) {
    if (strcmp(en, "XYZ") == 0) {
      Serial.println("Enable XYZ");
      digitalWrite(enablePin1, LOW);
      digitalWrite(enablePin2, LOW);
      digitalWrite(enablePin3, LOW);
    } else if (strcmp(en, "Y") == 0) {
      Serial.println("Enable Y");
      digitalWrite(enablePin2, LOW);
    } else if (strcmp(en, "Z") == 0) {
      Serial.println("Enable Z");
      digitalWrite(enablePin3, LOW);
    } else if (strcmp(en, "XY") == 0) {
      Serial.println("Enable XY");
      digitalWrite(enablePin1, LOW);
      digitalWrite(enablePin2, LOW);
    } else if (strcmp(en, "XZ") == 0) {
      Serial.println("Enable XZ");
      digitalWrite(enablePin1, LOW);
      digitalWrite(enablePin3, LOW);
    } else if (strcmp(en, "YZ") == 0) {
      Serial.println("Enable YZ");
      digitalWrite(enablePin2, LOW);
      digitalWrite(enablePin3, LOW);
    } else if (strcmp(en, "X") == 0) {
      Serial.println("Enable X");
      digitalWrite(enablePin1, LOW);
    }
  } else if (sscanf(input.c_str(), "H %d", &home) == 1) {
    digitalWrite(enablePin1, LOW);
    digitalWrite(enablePin2, LOW);
    digitalWrite(enablePin3, LOW);
    while (digitalRead(lim1) || digitalRead(lim2) || digitalRead(lim3)) {
      if (digitalRead(lim1))
        digitalWrite(step1, HIGH);
      if (digitalRead(lim2))
        digitalWrite(step2, HIGH);
      if (digitalRead(lim3))
        digitalWrite(step3, HIGH);
      delayMicroseconds(1000);
      digitalWrite(step1, LOW);
      digitalWrite(step2, LOW);
      digitalWrite(step3, LOW);
      delayMicroseconds(1000);
    }
    stepper1.setCurrentPosition(0);
    stepper2.setCurrentPosition(0);
    stepper3.setCurrentPosition(0);
    Serial.println("Homing completed");
  } else {
    Serial.print("XYZ position");
    Serial.print(" ");
    Serial.print(stepper1.currentPosition());
    Serial.print(" ");
    Serial.print(stepper2.currentPosition());
    Serial.print(" ");
    Serial.println(stepper3.currentPosition());
  }
}
