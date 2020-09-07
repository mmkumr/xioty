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
#define WIFI_SSID "mmkumr"
#define WIFI_PASSWORD "244466666"


//Define FirebaseESP8266 data object
FirebaseData firebaseData1;
FirebaseData firebaseData2;
FirebaseJson updateData;
FirebaseJson pipeData;

volatile int value = -1;

volatile int totalFlow = -1;


String parentPath = "/";
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
      //Serial.println("path: " + stream.dataPath + ", type: " + stream.type + ", value: " + stream.value);
      if(path == "/button"){
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


//int water = 0;
//#define LED_BUILTIN 1
//#define SENSOR  12
//
//long currentMillis = 0;
//long previousMillis = 0;
//int interval = 1000;
//boolean ledState = LOW;
//float calibrationFactor = 4.5;
//volatile byte pulseCount;
//byte pulse1Sec = 0;
//float flowRate;
//unsigned int flowMilliLitres;
//unsigned long totalMilliLitres;
//
//void IRAM_ATTR pulseCounter()
//{
//  pulseCount++;
//}



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



  if (!Firebase.beginMultiPathStream(firebaseData1, parentPath, childPath, childPathSize))
  {
    Serial.println("------------------------------------");
    Serial.println("Can't begin stream connection...");
    Serial.println("REASON: " + firebaseData1.errorReason());
    Serial.println("------------------------------------");
    Serial.println();
  }

  Firebase.setMultiPathStreamCallback(firebaseData1, streamCallback, streamTimeoutCallback);
//  pinMode(LED_BUILTIN, OUTPUT);
//  pinMode(SENSOR, INPUT_PULLUP);
//
//  pulseCount = 0;
//  flowRate = 0.0;
//  flowMilliLitres = 0;
//  totalMilliLitres = 0;
//  previousMillis = 0;
//
//  attachInterrupt(digitalPinToInterrupt(SENSOR), pulseCounter, FALLING);
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
//    water = 0;
  } else if(value == 0){
    LoRa.beginPacket();  
    LoRa.print(area + ":" + "state:" + "waterStop:");
    LoRa.endPacket();
    Serial.println("Motor off");
//    water = 1;
    value = -1;
  }
//  else if(water == 1){
//    flow();  
//  }

  if((millis() - t)/1000 == 25.0){
    updateData.set("button", "0");  
    updateData.set("motorCurrent", 0.001);
    pipeData.set("pipePressure", 0.001);
    Firebase.updateNode(firebaseData1, "/", updateData);
    Serial.println(firebaseData1.dataPath());
    Serial.println(firebaseData1.dataType());
    Serial.println(firebaseData1.jsonString());
    Firebase.updateNode(firebaseData1, "/", pipeData);
    Serial.println(firebaseData1.dataPath());
    Serial.println(firebaseData1.dataType());
    Serial.println(firebaseData1.jsonString());
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
    }
    
  }
  LoRa.packetRssi(); 
  i = 0; 
  Serial.println(i);
  if(change == 1){
    if((String(buffer[0]) == area && String(buffer[1]) == id) && (String(buffer[2]) == "motorCurrent") ){  
      if( String(buffer[3]).toFloat() == 0.0 ){ 
        Serial.println("stopping");
        FirebaseJson tankData;
        updateData.set("button", "0");
        updateData.set("motorCurrent", 0.001);
        Firebase.updateNode(firebaseData1, "/", updateData);
        value = -1;
      }else{
        Serial.println("continue");
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
      Serial.println("water in pipe");
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
  Serial.println(change);
  updateData.clear();
  pipeData.clear();
}


//void flow()
//{
//  currentMillis = millis();
//  if (currentMillis - previousMillis > interval && value == -1) {
//    
//    pulse1Sec = pulseCount;
//    pulseCount = 0;
//
//    // Because this loop may not complete in exactly 1 second intervals we calculate
//    // the number of milliseconds that have passed since the last execution and use
//    // that to scale the output. We also apply the calibrationFactor to scale the output
//    // based on the number of pulses per second per units of measure (litres/minute in
//    // this case) coming from the sensor.
//    flowRate = ((1000.0 / (millis() - previousMillis)) * pulse1Sec) / calibrationFactor;
//    previousMillis = millis();
//
//    // Divide the flow rate in litres/minute by 60 to determine how many litres have
//    // passed through the sensor in this 1 second interval, then multiply by 1000 to
//    // convert to millilitres.
//    flowMilliLitres = (flowRate / 60) * 1000;
//
//    // Add the millilitres passed in this second to the cumulative total
//    totalMilliLitres += flowMilliLitres;
//    
//    // Print the flow rate for this second in litres / minute
//    Serial.print("Flow rate: ");
//    Serial.print(int(flowRate));  // Print the integer part of the variable
//    Serial.print("L/min");
//    Serial.print("\t");       // Print tab space
//
//    // Print the cumulative total of litres flowed since starting
//    Serial.print("Output Liquid Quantity: ");
//    Serial.print(totalMilliLitres);
//    Serial.print("mL / ");
//    Serial.print(totalMilliLitres / 1000);
//    Serial.println("L");
//    FirebaseJson water;
//    water.set("totalFlow", round(totalMilliLitres));  
//    water.set("flowRate", round(flowRate));
//    Firebase.updateNode(firebaseData1, "/", water);
//  }
//}
