#include <WiFi.h>
#include <FirebaseESP32.h>
#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>
#include <ArduinoJson.h>
#include "EmonLib.h"                   // Include Emon Library
EnergyMonitor emon1;

Adafruit_PWMServoDriver pca9685 = Adafruit_PWMServoDriver(0x40);
 
// Define maximum and minimum number of "ticks" for the servo motors
// Range from 0 to 4095
// This determines the pulse width
 
#define SERVOMIN  218  // Minimum value
#define SERVOMAX  436  // Maximum value
 


#define FIREBASE_HOST "https://iot-induction-default-rtdb.firebaseio.com/"
#define FIREBASE_AUTH "NCnHwdnSGB532P2CQ3rbxmmMZWxoD14HdLOnwGQy"
#define WIFI_SSID "mmkumr"
#define WIFI_PASSWORD "P@$$w0rd"



//Define FirebaseESP8266 data object
FirebaseData firebaseData1;
FirebaseData firebaseData2;
FirebaseJson induction;

FirebaseJson json;


unsigned long sendDataPrevMillis = 0;
String path; 
String main = "off";
String main1 = "off";
String main2 = "off";
String val;
int temp1, temp2, change = 0;

String parentPath = "/";
String childPath[3] = {"/i1", "/i2", "/power"};
size_t childPathSize = 3;

uint16_t count = 0;

void printResult(FirebaseData &data);

void streamCallback(MultiPathStreamData stream)
{
  size_t numChild = sizeof(childPath)/sizeof(childPath[0]);

  for(size_t i = 0;i< numChild;i++)
  {
    if (stream.get(childPath[i]))
    {
      //Serial.println("path: " + stream.dataPath + ", type: " + stream.type + ", value: " + stream.value);
      
//      change = 1;
//      path = stream.dataPath;
    }
  }

  
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
  emon1.current(15, 6.58);
}

void loop()
{
  float Irms = emon1.calcIrms(1480);  // Calculate Irms only
  json.clear();
  json.set("current", Irms);
  Serial.println(Irms/10);
  Firebase.updateNode(firebaseData1, "/i1", json);
}
