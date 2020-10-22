// Wire Slave Sender
// by Nicholas Zambetti <http://www.zambetti.com>

// Demonstrates use of the Wire library
// Sends data as an I2C/TWI slave device
// Refer to the "Wire Master Reader" example for use with this

// Created 29 March 2006

// This example code is in the public domain.
volatile String current;

#include <Wire.h>
#include "EmonLib.h"             // Include Emon Library

#define VOLT_CAL 151.0
#define CURRENT_CAL 4.4

EnergyMonitor emon1;


void setup() {
  Wire.begin(8);                // join i2c bus with address #8
  Wire.onRequest(requestEvent); // register event
  emon1.voltage(1, VOLT_CAL, 1.7);  // Voltage: input pin, calibration, phase_shift
  emon1.current(0, CURRENT_CAL);

  Serial.begin(9600);
}

void loop() {
  emon1.calcVI(20,2000);           // Calculate all. No.of half wavelengths (crossings), time-out
  float currentDraw = emon1.Irms; //extract Irms into Variable
  float supplyVoltage = emon1.Vrms;
  Serial.println(currentDraw);
  current = String(currentDraw);
}

// function that executes whenever data is requested by master
// this function is registered as an event, see setup()
void requestEvent() {
  Wire.write(current.c_str()); // respond with message of 6 bytes
  Serial.print("Sending current: ");
  Serial.println(current.c_str());
  // as expected by master
}
