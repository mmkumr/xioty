// EmonLibrary examples openenergymonitor.org, Licence GNU GPL V3

#include "EmonLib.h"             // Include Emon Library



#define VOLT_CAL 148.7
#define CURRENT_CAL 4.3

EnergyMonitor emon1;             // Create an instance
int d3 = 3;

void setup()
{  
  pinMode(d3, OUTPUT);
  Serial.begin(9600);
  
  emon1.voltage(1, VOLT_CAL, 1.7);  // Voltage: input pin, calibration, phase_shift
  emon1.current(0, CURRENT_CAL);       // Current: input pin, calibration.
}

void loop()
{
  emon1.calcVI(20,2000);         // Calculate all. No.of half wavelengths (crossings), time-out
  float currentDraw = emon1.Irms;             //extract Irms into Variable
  float supplyVoltage = emon1.Vrms;                    //extract Vrms into Variable

  Serial.print("Voltage: ");
  Serial.println(supplyVoltage);
  
  Serial.print("Current: ");
  Serial.println(currentDraw);
  if(currentDraw < 0.20 && currentDraw > 0.15){
      digitalWrite(d3, HIGH);
    } else {
       digitalWrite(d3, LOW);
     }

  Serial.print("Watts: ");
  Serial.println(currentDraw * supplyVoltage);
  Serial.println("\n\n");
}
