#include <Wire.h>


// Define the GPIO pins for the button controls
const int upButtonPin = 14;     // Up button
const int downButtonPin = 27;   // Down button
const int powerButtonPin = 12;  // Power (on/off) button


// Define the initial heat level
int currentHeatLevel = 4;

// Variable to track the target heat level
int targetHeatLevel = 4;


void setup() {
  // Initialize serial communication
  Serial.begin(115200);
  Wire.begin(8);                 // join I2C bus with address #8
  Wire.onReceive(receiveEvent);  // register event
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
int rcv = 0;
void loop() {
  if (rcv != 0) {
    induction();
  }
}

void induction() {
  if (t == 0) {
    // For intial turning on.
    digitalWrite(powerButtonPin, LOW);
    delay(500);  // Simulate button press
    digitalWrite(powerButtonPin, HIGH);
  }
  if (t == 1) {
    // Turning on after intialization.
    targetHeatLevel = 4;
    currentHeatLevel = targetHeatLevel;
    digitalWrite(powerButtonPin, LOW);
    delay(500);  // Simulate button press
    digitalWrite(powerButtonPin, HIGH);
  } else if (t == 200) {
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
  rcv = 0;
}
// Function to adjust the heat level
void adjustHeatLevel() {
  // Calculate the number of steps (up or down)
  int steps = targetHeatLevel - currentHeatLevel;
  Serial.print("Steps: ");
  Serial.println(steps);
  // Simulate button presses to reach the target heat level
  if (steps > 0) {
    for (int i = 0; i < steps; i++) {
      digitalWrite(upButtonPin, LOW);
      delay(500);  // Simulate button press
      digitalWrite(upButtonPin, HIGH);
      delay(1000);  // Delay between button presses
    }
  } else if (steps < 0) {
    steps = abs(steps);
    for (int i = 0; i < steps; i++) {
      digitalWrite(downButtonPin, LOW);
      delay(500);  // Simulate button press
      digitalWrite(downButtonPin, HIGH);
      delay(1000);  // Delay between button presses
    }
  }

  // Update the current heat level
  currentHeatLevel = targetHeatLevel;

  // Print the new heat level for debugging
  // Serial.print("Heat Level: ");
  // Serial.println(currentHeatLevel);
}

// function that executes whenever data is received from master
// this function is registered as an event, see setup()
void receiveEvent(int howMany) {
  while (Wire.available()) {  // loop through all but the last
    t = Wire.read();
    t *= 100;
    Serial.println(t);  // print the character
  }
  rcv = 1;
}
