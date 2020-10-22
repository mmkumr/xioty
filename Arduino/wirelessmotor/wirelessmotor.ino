/*
 * Created by K. Suwatchai (Mobizt)
 * 
 * Email: k_suwatchai@hotmail.com
 * 
 * Github: https://github.com/mobizt
 * 
 * Copyright (c) 2020 mobizt
 * 
 * This example is for FirebaseESP8266 Arduino library v 3.7.3 or newer
 *
*/

#include <WiFi.h>
#include <driver/adc.h>
#include <FirebaseESP32.h>
#include "EmonLib.h"

#define vCalibration 106.8
#define currCalibration 1.15

EnergyMonitor emon1;


#define FIREBASE_HOST "automoto-143.firebaseio.com"
#define FIREBASE_AUTH "RgzejSsoAQpbkTg4OAkd2mMWtsJPm9VN1vpeB7dk"
#define WIFI_SSID "mmkumr"
#define WIFI_PASSWORD "P@$$w0rd"


//Define FirebaseESP8266 data object
FirebaseData firebaseData1;
FirebaseData firebaseData2;
FirebaseJson updateData;
FirebaseJson pipeData;

volatile int value = -1;
int onButton = 18;
int offButton = 19;

String parentPath = "/wirelessmotor";
String childPath[1] = {"/button"};
size_t childPathSize = 1;

uint16_t count = 0;

void printResult(FirebaseData &data); 

void streamCallback(MultiPathStreamData stream)
{
  Serial.println();
  Serial.println("Stream Data1 available...");

  size_t numChild = sizeof(childPath)/sizeof(childPath[0]);

  for(size_t i = 0;i< numChild;i++)
  {
    if (stream.get(childPath[i]))
    {
      String path = stream.dataPath;
      String temp = stream.value;
      Serial.println("path: " + stream.dataPath + ", type: " + stream.type + ", value: " + stream.value);
      if(path == "/button"){
        Serial.println("Button value changed");
        value = temp.toInt();
      }
    }
  }

  Serial.println();
  
}

void streamTimeoutCallback(bool timeout)
{
  if (timeout)
  {
    Serial.println();
    Serial.println("Stream timeout, resume streaming...");
    Serial.println();
  }
}





void setup()
{
  pinMode(onButton, OUTPUT);
  pinMode(offButton, OUTPUT);
  Serial.begin(9600);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.reconnectWiFi(true);



  if (!Firebase.beginMultiPathStream(firebaseData1, parentPath, childPath, childPathSize))
  {
    Serial.println("------------------------------------");
    Serial.println("Can't begin stream connection...");
    Serial.println("REASON: " + firebaseData1.errorReason());
    Serial.println("------------------------------------");
    Serial.println();
  }

  Firebase.setMultiPathStreamCallback(firebaseData1, streamCallback, streamTimeoutCallback);
  emon1.voltage(35, vCalibration, 1.7); // Voltage: input pin, calibration, phase_shift
  emon1.current(34, currCalibration);
}

void loop()
{
  if(value == 1){
    digitalWrite(onButton, HIGH);
    delay(1500);
    digitalWrite(onButton, LOW);
    Serial.println("on");
    value = -1;
  } else if(value == 0){
    digitalWrite(offButton, HIGH);
    delay(1500);
    digitalWrite(offButton, LOW);
    Serial.println("off");
    value = -1;
  }
  updateData.clear();
  updateData.set("status", "ok");
  Firebase.updateNode(firebaseData1, "/wirelessmotor", updateData);
  Serial.println(firebaseData1.dataPath());
  Serial.println(firebaseData1.dataType());
  Serial.println(firebaseData1.jsonString());
  emon1.calcVI(20,2000);           // Calculate all. No.of half wavelengths (crossings), time-out
  float currentDraw = emon1.Irms; //extract Irms into Variable
  float supplyVoltage = emon1.Vrms;
  Serial.println(currentDraw);
  updateData.set("current", currentDraw);
  updateData.set("status", "ok");
  Firebase.updateNode(firebaseData1, "/wirelessmotor", updateData);
  Serial.println(firebaseData1.dataPath());
  Serial.println(firebaseData1.dataType());
  Serial.println(firebaseData1.jsonString());
}
