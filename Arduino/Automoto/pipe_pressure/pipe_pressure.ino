/*
 * Interfacing Arduino with BMP280 temperature and pressure sensor.
 * Temperature and pressure values are displayed on 16x2 LCD.
 * This is a free software with NO WARRANTY.
 * https://simple-circuit.com/
 */
 
#include <Wire.h>             // include Wire library, required for I2C devices
#include <Adafruit_Sensor.h>  // include Adafruit sensor library
#include <Adafruit_BMP280.h>  // include adafruit library for BMP280 sensor
#include <SPI.h>
#include <LoRa.h>
#include<math.h>

// define device I2C address: 0x76 or 0x77 (0x77 is library default address)
#define BMP280_I2C_ADDRESS  0x76

int X;
int Y;
float TIME = 0;
float FREQUENCY = 0;
float WATER = 0;
float TOTAL = 0;
float LS = 0;
const int input = A2;

Adafruit_BMP280 bmp280;
int D3 = 3;
String id = "1234";
String area = "a1234"; //Unique area code.
float voltage;
int packetSize;
 
void setup() {
  Serial.begin(9600);
  while (!Serial);
  pinMode(D3, INPUT);
  pinMode(input,INPUT);
  Serial.println("pressure");

  if (!LoRa.begin(433E6)) {
    Serial.println("Starting LoRa failed!");
    while (1);
  }
  
  if (!bmp280.begin(BMP280_I2C_ADDRESS))
  {  
    Serial.println("Could not find a valid BMP280 sensor, check wiring!");
    while (1);
  }
 

}
 
char text[14]; 
 
// main loop
void loop()
{
  int sensorValue = analogRead(A0);
  // get temperature, pressure and altitude from library
  float temperature = bmp280.readTemperature();  // get temperature
  float pressure    = bmp280.readPressure();     // get pressure
  float altitude_   = bmp280.readAltitude(1000.25); // get altitude (this should be adjusted to your local forecast)
  voltage = sensorValue * (4.15 / 1023.0);
  Serial.print("Pressure    = ");
  Serial.print(round(pressure/100));
  Serial.println(" hPa");
  if( round(pressure/100) > 1020){
    int v ;
    if(voltage < 4.0){
      v = 0;
    }else{
      v = 1;
    }
    LoRa.beginPacket();
    LoRa.print(area + ":" + "pipePressure:" + String(pressure/100) + ":" + String(voltage) + ":");
    LoRa.endPacket();
    while(round(pressure/100) < 1015) {
      ;  
    }
  }
  Serial.println();  // start a new line
  delay(2000);       // wait 2 seconds  
}

void waterFlow(){
  X = pulseIn(input, HIGH);
  Y = pulseIn(input, LOW);
  TIME = X + Y;
  FREQUENCY = 1000000/TIME;
  WATER = FREQUENCY/7.5;
  LS = WATER/60;
  if(FREQUENCY >= 0) {
    if(isinf(FREQUENCY)){
      Serial.println("VOL.: 0.00 L\\M");
      Serial.println("Total: " + String(TOTAL) + " L");
    }
    else{
      TOTAL = TOTAL + LS;
      Serial.println(FREQUENCY);
      Serial.println("Volume: " + String(WATER) + " L\\M");
      Serial.println("Total: " + String(TOTAL) + " L");

    }
  } 
}
