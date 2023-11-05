/*
stepper1 Dir 5, Step 4, En 23, Limit 14
Stepper2 Dir 13, Step 12, En 25, Limit 27
Pump 35

commands:
  M 1/2 P0(home)
  M 1/2 P<position>
  M 3 P<pwmvalue> 
*/
#include "WiFi.h"
#include "PubSubClient.h"
#include <AccelStepper.h>

// Define the number of steps per revolution for your stepper motors
#define STEPS_PER_REV 200

// Create two instances of AccelStepper for each motor
AccelStepper stepper1(AccelStepper::DRIVER, 4, 5); // Motor 1 (Step, Dir)
AccelStepper stepper2(AccelStepper::DRIVER, 12, 13); // Motor 2 (Step, Dir)

// Define the enable pins for each motor
const int enablePin1 = 23; // Motor 1 Enable
const int enablePin2 = 25; // Motor 2 Enable
const int dir1 = 5;
const int dir2 = 13;
const int step1 = 4;
const int step2 = 12;
const int lim1 = 14;
const int lim2 = 27;

//Pump vars
const int pwmPin = 2;
// setting PWM properties
const int freq = 5000;
const int pwmChannel = 0;
const int resolution = 12;

//mqtt
const char* ssid = "Asu";
const char* password = "12341234";
const char* mqttServer = "192.168.27.253";
const char* mqtt_username = "xara"; // MQTT username
const char* mqtt_password = "xara"; // MQTT password
const int mqttPort = 1883;
const char* mqttTopic = "xara/ingredients";
const char* mqttName = "ingredient";

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
    client.publish("response","o");
    itower(input);
}
//end of mqtt

void setup() {
  // Set up the enable pins as OUTPUT and disable the motors
  pinMode(enablePin1, OUTPUT);
  pinMode(enablePin2, OUTPUT);
  digitalWrite(enablePin1, HIGH);
  digitalWrite(enablePin2, HIGH);
  ledcSetup(pwmChannel, freq, resolution);
  ledcAttachPin(pwmPin, pwmChannel);
  // Set the maximum speed and acceleration for both motors
  stepper1.setMaxSpeed(1000.0);
  stepper1.setAcceleration(500.0);
  stepper2.setMaxSpeed(1000.0);
  stepper2.setAcceleration(500.0);

  // Initialize the serial communication
  Serial.begin(115200);
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
}

void loop() {
  // Check for incoming serial commands
  if (Serial.available() > 0) {
    // Read the serial input
    String input = Serial.readStringUntil('\n');
    itower(input);
  }
  client.loop();
}

void itower(String input){
  // Parse the input to get motor number and position
  int motorNumber;
  long absolutePosition;
  if (sscanf(input.c_str(), "M %d P%ld", &motorNumber, &absolutePosition) == 2) {
    // Check if the motor number is valid (1 or 2)
    if (motorNumber == 1 || motorNumber == 2) {
      // Move the specified motor to the absolute position
      AccelStepper* selectedStepper = (motorNumber == 1) ? &stepper1 : &stepper2;
      selectedStepper->moveTo(absolutePosition);
      digitalWrite((motorNumber == 1) ? enablePin1 : enablePin2, LOW);
      // Wait for the motor to reach the target position
      if(absolutePosition == 0){
        digitalWrite((motorNumber == 1) ? enablePin1 : enablePin2, LOW);
        while(digitalRead((motorNumber == 1) ? lim1 : lim2)){
          digitalWrite((motorNumber == 1) ? step1 : step2, HIGH);
          delayMicroseconds(1000);
          digitalWrite((motorNumber == 1) ? step1 : step2, LOW);
          delayMicroseconds(1000);
        }
      } else{
        while (selectedStepper->distanceToGo() != 0) {
          selectedStepper->run();
        }
      }
      // Disable the selected motor
      digitalWrite((motorNumber == 1) ? enablePin1 : enablePin2, HIGH);
      // Print a message indicating the movement is complete
      Serial.println("Movement complete");
    } else if(motorNumber == 3){
      ledcWrite(pwmChannel, absolutePosition);
      Serial.print("PWM value: ");
      Serial.println(absolutePosition);
    }else {
      Serial.println("Invalid motor number. Use M1 or M2 or M3.");
    }
  } else {
    Serial.println("Invalid command format. Use M1 Pxxx or M2 Pxxx.");
  }
  
}
