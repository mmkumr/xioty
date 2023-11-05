/*
commands: stir P(Position_val)
          stir C(PWM_val)
*/
#include <Arduino.h>
#include <ESP32Encoder.h>
#include <PID_v1.h>
// Mqtt setup
#include "WiFi.h"
#include "PubSubClient.h"

const char* ssid = "Asu";
const char* password = "12341234";
const char* mqttServer = "192.168.27.253";
const char* mqtt_username = "xara"; // MQTT username
const char* mqtt_password = "xara"; // MQTT password
const int mqttPort = 1883;
const char* mqttTopic = "xara/stir";
const char* mqttName = "stir";

//stir configs
int pwm = 0;
long currentPosition;
ESP32Encoder encoder;
// Define motor control pins
const int pwmPin = 18;      // Connect to the PWM input of the motor driver
const int directionPin = 19; // Connect to the direction input of the motor driver
double setpoint = 0;       // Target position (in encoder counts)
//stir config end
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
    stir(input);
}
// end of mqtt setup

// Define encoder pins
const int encoderPinA = 4;  // Connect one encoder pin to GPIO 2
const int encoderPinB = 5;  // Connect the other encoder pin to GPIO 4

// Create an encoder object

// Define PID parameters
double input, output;
double Kp = 1.0;           // Proportional term
double Ki = 0.0;           // Integral term
double Kd = 0.2;          // Derivative term

// Create a PID controller
PID myPID(&input, &output, &setpoint, Kp, Ki, Kd, DIRECT);

// Define variables
int motorSpeed = 50;                // Motor speed (0-255)
int maxAcceleration = 5;          // Maximum acceleration per loop iteration
int currentSpeed = 0;              // Current motor speed
int stopThreshold = 10;            // Threshold for stopping (adjust as needed)

void setup() {
  // Set motor control pins as outputs
  pinMode(pwmPin, OUTPUT);
  pinMode(directionPin, OUTPUT);

  // Initialize the encoder
  encoder.attachFullQuad(encoderPinA, encoderPinB);

  // Initialize serial communication
  Serial.begin(115200);
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
      if (client.connect(mqttName,mqtt_username, mqtt_password)) { 
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

  // Initialize the PID controller
  myPID.SetMode(AUTOMATIC);
  myPID.SetOutputLimits(-255, 255); // Set the output limits to control motor speed
}


void loop() {
  if (Serial.available() > 0) {
    // Read the serial input
    String input = Serial.readStringUntil('\n');
    stir(input);
  }
  if(pwm == 0){
    // Read the current position from the encoder
    currentPosition = encoder.getCount();
    input = currentPosition;
    // Set the target position (you can change this value as needed)
    // setpoint = 1000;  // Example: Target position is 1000 encoder counts

    // Compute the PID output
    myPID.Compute();

    // Determine the motor direction
    int direction = (output > 0) ? HIGH : LOW;

    // Set the motor direction
    digitalWrite(directionPin, direction);

    // Implement acceleration control
    if (currentSpeed < motorSpeed) {
      currentSpeed += maxAcceleration;
      if (currentSpeed > motorSpeed) {
        currentSpeed = motorSpeed;
      }
    } else if (currentSpeed > motorSpeed) {
      currentSpeed -= maxAcceleration;
      if (currentSpeed < motorSpeed) {
        currentSpeed = motorSpeed;
      }
    }

    // Set the motor speed based on the current speed
    analogWrite(pwmPin, currentSpeed);

    // Check if the motor is close enough to the target position to stop
    if (abs(currentPosition - setpoint) <= stopThreshold) {
      currentSpeed = 0;
      analogWrite(pwmPin, currentSpeed); // Stop the motor
    }

    // Print the current and target positions for debugging
    // Serial.print("Current Position: ");
    // Serial.println(currentPosition);
    // Serial.print("Target Position: ");
    // Serial.println(setpoint);

    delay(100); // Delay for stability
  }
  client.loop();
}

void stir(String input){
  if (sscanf(input.c_str(), "stir P%lf", &setpoint) == 1) {
    Serial.print("Set point is: ");
    Serial.println(setpoint);
  } else if (sscanf(input.c_str(), "stir C%d", &pwm) == 1) {
    Serial.print("PWM value is: ");
    Serial.println(pwm);
    digitalWrite(directionPin, pwm < 0 ? LOW : HIGH);
    analogWrite(pwmPin, abs(pwm));
    currentPosition = encoder.getCount();
    input = currentPosition;
    setpoint = currentPosition;
  }
}