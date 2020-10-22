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
int prev;

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

volatile int totalFlow = -1;

volatile int need = 0;


String parentPath = "/";
String childPath[2] = {"/button", "/send"};
size_t childPathSize = 2;

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
      if(path == "/send"){
        need = temp.toInt();
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

  Firebase.getString(firebaseData1, "/button");
  value = firebaseData1.stringData().toInt();
  if(value == 1){
    LoRa.beginPacket();  
    LoRa.print(area + ":" + "state:" + "water:");
    LoRa.endPacket();
    Serial.println("Motor on");  
    t = millis();
    updateData.clear();
    pipeData.clear();
    updateData.set("motorCurrent", 0.001);
    Firebase.updateNode(firebaseData2, "/", updateData);
    Serial.println(firebaseData2.dataPath());
    Serial.println(firebaseData2.dataType());
    Serial.println(firebaseData2.jsonString());
    prev = 1;
  } else if(value == 0){
    LoRa.beginPacket();  
    LoRa.print(area + ":" + "state:" + "waterStop:");
    LoRa.endPacket();
    Serial.println("Motor off");
    prev = 0;
  }
}

void loop()
{
  if(LoRa.parsePacket()) {
    getLora();
  }
  else if(value == 1 && prev == 0){
    LoRa.beginPacket();  
    LoRa.print(area + ":" + "state:" + "water:");
    LoRa.endPacket();
    Serial.println("Motor on");  
    t = millis();
    prev = 1;
    updateData.clear();
    pipeData.clear();
    updateData.set("motorCurrent", 0.001);
    Firebase.updateNode(firebaseData2, "/", updateData);
  } 
  else if(value == 0 && prev == 1){
    LoRa.beginPacket();  
    LoRa.print(area + ":" + "state:" + "waterStop:");
    LoRa.endPacket();
    Serial.println("Motor off");
    prev = 0;
  }
  if(need == 1){
    updateData.clear();
    updateData.set("send", 0);
    need = 0;
    Firebase.updateNode(firebaseData2, "/", updateData);
    LoRa.beginPacket();  
    LoRa.print(area + ":" + "state:" + "sendCurrent:");
    LoRa.endPacket();
    Serial.println("send current");
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
        updateData.clear();
        pipeData.clear();
        Serial.println("stopping");
        FirebaseJson tankData;
        updateData.set("button", "0");
        updateData.set("motorCurrent", 0.001);
        Firebase.updateNode(firebaseData2, "/", updateData);
      }else{
        updateData.clear();
        pipeData.clear();
        updateData.set("motorCurrent", String(buffer[3]).toFloat() );
        Firebase.updateNode(firebaseData2, "/", updateData);
        FirebaseJson tankData;
        tankData.set("tankBattery", String(buffer[4]).toFloat());
        Firebase.updateNode(firebaseData2, "/", tankData);
        Serial.println(firebaseData2.dataPath());
        Serial.println(firebaseData2.dataType());
        Serial.println(firebaseData2.jsonString());
        t = millis();
      }
    }

    
   if((String(buffer[0]) == area && String(buffer[1]) == "pipePressure") ){
      updateData.clear();
      pipeData.clear();
      Serial.println("water in pipe");
      pipeData.set("pipePressure",String(buffer[2]).toFloat());
      pipeData.set("pipeBattery", String(buffer[3]).toFloat());
      pipeData.set("button", "1");
      pipeData.set("motorCurrent", 0.001);
      Firebase.updateNode(firebaseData2, "/", pipeData);
      Serial.println(firebaseData2.dataPath());
      Serial.println(firebaseData2.dataType());
      Serial.println(firebaseData2.jsonString()); 
      Serial.println("water started");
      LoRa.beginPacket();  
      LoRa.print(area + ":" + "state:" + "water:");
      LoRa.endPacket();
      Serial.println("Motor on");  
      t = millis();
    }  

    if((String(buffer[0]) == area && String(buffer[1]) == "pipeFlow") ){
      updateData.clear();
      pipeData.clear();
      pipeData.set("flowRate", atoi(String(buffer[2]).c_str()) );
      pipeData.set("totalFlow", atoi(String(buffer[3]).c_str()) );
      Firebase.updateNode(firebaseData2, "/", pipeData);
      Serial.println(firebaseData2.dataPath());
      Serial.println(firebaseData2.dataType());
      Serial.println(firebaseData2.jsonString()); 
    }

    change = 0;
  }
  Serial.println(change);
  updateData.clear();
  pipeData.clear();
}
