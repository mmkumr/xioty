// Wire Slave Sender
// by Nicholas Zambetti <http://www.zambetti.com>

// Demonstrates use of the Wire library
// Sends data as an I2C/TWI slave device
// Refer to the "Wire Master Reader" example for use with this

// Created 29 March 2006

// This example code is in the public domain.


#include <Wire.h>
#include "EmonLib.h"             // Include Emon Library

#define VOLT_CAL 151.0
#define CURRENT_CAL 4.5

EnergyMonitor emon1;
volatile int current;

int D5 = 5;

void setup() {
  pinMode(D5, OUTPUT);
  digitalWrite(D5, HIGH);
  Serial.begin(9600);
  emon1.voltage(1, VOLT_CAL, 1.7);  // Voltage: input pin, calibration, phase_shift
  emon1.current(0, CURRENT_CAL);
  Wire.begin(8);                // join i2c bus with address #8
  Wire.onRequest(requestEvent); // register event
  
}

void loop() {
  emon1.calcVI(20,2000);           // Calculate all. No.of half wavelengths (crossings), time-out
  float currentDraw = emon1.Irms; //extract Irms into Variable
  float supplyVoltage = emon1.Vrms;
  current = round(currentDraw*100);
  Serial.println(currentDraw);
  if(currentDraw < 0.16){
    digitalWrite(D5, LOW);  
  }else{
    digitalWrite(D5, HIGH);  
  }
}

// function that executes whenever data is requested by master
// this function is registered as an event, see setup()
void requestEvent() {
  Wire.write(current); // respond with message of 6 bytes
  // as expected by master
}
