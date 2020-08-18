
/*
 * Created by K. Suwatchai (Mobizt)
 * 
 * Email: k_suwatchai@hotmail.com
 * 
 * Github: https://github.com/mobizt
 * 
 * Copyright (c) 2020 mobizt
 * 
 * This example is for FirebaseESP32 Arduino library v 3.7.3 or later
 *
*/

//This example shows how to set stream event callback functions.
//Two events are available from Firebase's Real Time database HTTP stream connection, dataAvailable and streamTimeout.


#include <WiFi.h>
#include <FirebaseESP32.h>
#include <LoRa.h>

#define ss 5
#define rst 14
#define dio0 2
String id = "1234";
String area = "a1234";

int length = 20;
char buffer [5][20];
char termChar = ':';
int i = 0;
int change = 0;
float t = 0.0;


#define FIREBASE_HOST "automoto-143.firebaseio.com"
#define FIREBASE_AUTH "RgzejSsoAQpbkTg4OAkd2mMWtsJPm9VN1vpeB7dk"
#define WIFI_SSID "dddd70"
#define WIFI_PASSWORD "12345abcd"


//Define Firebase data object
FirebaseData firebaseData1;
FirebaseData firebaseData2;
FirebaseJson updateData;
FirebaseJson pipeData;

unsigned long sendDataPrevMillis = 0;

String path = "button";

uint16_t count = 0;

volatile int value = -1;


void printResult(FirebaseData &data);
void printResult(StreamData &data);

void streamCallback(StreamData data)
{

  Serial.println("Stream Data1 available...");
  Serial.println("STREAM PATH: " + data.streamPath());
  Serial.println("EVENT PATH: " + data.dataPath());
  Serial.println("DATA TYPE: " + data.dataType());
  Serial.println("EVENT TYPE: " + data.eventType());
  Serial.print("VALUE: ");
  printResult(data);
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

  Serial.begin(9600);
  
  while (!Serial);  
  LoRa.setPins(ss, rst, dio0);
  Serial.println("Gateway");
  if (!LoRa.begin(433E6)) { // or 915E6, the MHz speed of yout module
    Serial.println("Starting LoRa failed!");
    while (1);
  }

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

  if (!Firebase.beginStream(firebaseData1, path))
  {
    Serial.println("------------------------------------");
    Serial.println("Can't begin stream connection...");
    Serial.println("REASON: " + firebaseData1.errorReason());
    Serial.println("------------------------------------");
    Serial.println();
  }

  Firebase.setStreamCallback(firebaseData1, streamCallback, streamTimeoutCallback);
}

void loop()
{
  if(LoRa.parsePacket()) {
    getLora();
  }
  else if(value == 1){
    LoRa.beginPacket();  
    LoRa.print(area + ":" + "state:" + "water:");
    LoRa.endPacket();
    Serial.println("Motor on");  
    t = millis();
    value = -1;
  } else if(value == 0){
    LoRa.beginPacket();  
    LoRa.print(area + ":" + "state:" + "waterStop:");
    LoRa.endPacket();
    Serial.println("Motor off");  
    value = -1;
  }

  if((millis() - t)/1000 == 25.0){
    updateData.set("button", "0");  
    updateData.set("motorCurrent", 0.001);
    pipeData.set("pipePressure", 0.001);
    Firebase.updateNode(firebaseData1, "/", updateData);
    Firebase.updateNode(firebaseData1, "/", pipeData);
  }
    
}

void getLora(){
  while(LoRa.available()) {
    int numChars = LoRa.readBytesUntil(termChar, buffer[i], length);
    buffer[i][numChars]='\0';
    Serial.println(buffer[i]);
    Serial.println(i);
    if( (i == 3 && String(buffer[2]) != "motorCurrent") || String(buffer[0]) != area){
      i = 0;
    }
    else if(i < 3){
      ++i;
      change = 1;
      
    }else if((i == 3 && String(buffer[2]) == "motorCurrent")){
      ++i;
      Serial.println("ok");
    }
    
  }
  LoRa.packetRssi(); 
  i = 0; 
  Serial.println(i);
  if(change == 1){
    if((String(buffer[0]) == area && String(buffer[1]) == id) && (String(buffer[2]) == "motorCurrent") ){  
      if( String(buffer[3]).toFloat() == 0.0 ){ 
        FirebaseJson tankData;
        updateData.set("button", "0");
        updateData.set("motorCurrent", 0.001);
        Firebase.updateNode(firebaseData1, "/", updateData);
      }else{
        updateData.set("motorCurrent", String(buffer[3]).toFloat() );
        Firebase.updateNode(firebaseData1, "/", updateData);
        updateData.set("button", "1");
        Firebase.updateNode(firebaseData1, "/", updateData);
        FirebaseJson tankData;
        tankData.set("tankBattery", String(buffer[4]).toFloat());
        Firebase.updateNode(firebaseData1, "/", tankData);
        Serial.println(firebaseData1.dataPath());
        Serial.println(firebaseData1.dataType());
        Serial.println(firebaseData1.jsonString());
        t = millis();
        value = -1;
      }
    }

    
   if((String(buffer[0]) == area && String(buffer[1]) == "pipePressure") ){
      pipeData.set("pipePressure",String(buffer[2]).toFloat());
      pipeData.set("pipeBattery", String(buffer[3]).toFloat());
      pipeData.set("button", "1");
      pipeData.set("motorCurrent", 0.001);
      Firebase.updateNode(firebaseData1, "/", pipeData);
      Serial.println(firebaseData1.dataPath());
      Serial.println(firebaseData1.dataType());
      Serial.println(firebaseData1.jsonString()); 
      Serial.println("water started");
    }  

    
    
    change = 0;
  }
  
}

void printResult(FirebaseData &data)
{

  if (data.dataType() == "int")
    Serial.println(data.intData());
  else if (data.dataType() == "float")
    Serial.println(data.floatData(), 5);
  else if (data.dataType() == "double")
    printf("%.9lf\n", data.doubleData());
  else if (data.dataType() == "boolean")
    Serial.println(data.boolData() == 1 ? "true" : "false");
  else if (data.dataType() == "string")
    Serial.println(data.stringData());
  else if (data.dataType() == "json")
  {
    Serial.println();
    FirebaseJson &json = data.jsonObject();
    //Print all object data
    Serial.println("Pretty printed JSON data:");
    String jsonStr;
    json.toString(jsonStr, true);
    Serial.println(jsonStr);
    Serial.println();
    Serial.println("Iterate JSON data:");
    Serial.println();
    size_t len = json.iteratorBegin();
    String key, value = "";
    int type = 0;
    for (size_t i = 0; i < len; i++)
    {
      json.iteratorGet(i, type, key, value);
      Serial.print(i);
      Serial.print(", ");
      Serial.print("Type: ");
      Serial.print(type == FirebaseJson::JSON_OBJECT ? "object" : "array");
      if (type == FirebaseJson::JSON_OBJECT)
      {
        Serial.print(", Key: ");
        Serial.print(key);
      }
      Serial.print(", Value: ");
      Serial.println(value);
    }
    json.iteratorEnd();
  }
  else if (data.dataType() == "array")
  {
    Serial.println();
    //get array data from FirebaseData using FirebaseJsonArray object
    FirebaseJsonArray &arr = data.jsonArray();
    //Print all array values
    Serial.println("Pretty printed Array:");
    String arrStr;
    arr.toString(arrStr, true);
    Serial.println(arrStr);
    Serial.println();
    Serial.println("Iterate array values:");
    Serial.println();
    for (size_t i = 0; i < arr.size(); i++)
    {
      Serial.print(i);
      Serial.print(", Value: ");

      FirebaseJsonData &jsonData = data.jsonData();
      //Get the result data from FirebaseJsonArray object
      arr.get(jsonData, i);
      if (jsonData.typeNum == FirebaseJson::JSON_BOOL)
        Serial.println(jsonData.boolValue ? "true" : "false");
      else if (jsonData.typeNum == FirebaseJson::JSON_INT)
        Serial.println(jsonData.intValue);
      else if (jsonData.typeNum == FirebaseJson::JSON_FLOAT)
        Serial.println(jsonData.floatValue);
      else if (jsonData.typeNum == FirebaseJson::JSON_DOUBLE)
        printf("%.9lf\n", jsonData.doubleValue);
      else if (jsonData.typeNum == FirebaseJson::JSON_STRING ||
               jsonData.typeNum == FirebaseJson::JSON_NULL ||
               jsonData.typeNum == FirebaseJson::JSON_OBJECT ||
               jsonData.typeNum == FirebaseJson::JSON_ARRAY)
        Serial.println(jsonData.stringValue);
    }
  }
}

void printResult(StreamData &data)
{

  if (data.dataType() == "int")
    Serial.println(data.intData());
  else if (data.dataType() == "float")
    Serial.println(data.floatData(), 5);
  else if (data.dataType() == "double")
    printf("%.9lf\n", data.doubleData());
  else if (data.dataType() == "boolean")
    Serial.println(data.boolData() == 1 ? "true" : "false");
  else if (data.dataType() == "string" || data.dataType() == "null")
    value = data.stringData().toInt();
}
