#include "FirebaseESP8266.h"
#include <ESP8266WiFi.h>

#define ss 5
#define rst 14
#define dio0 2
String id = "1234";
String area = "a1234";
char tank[5];

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


int water = 0;
#define LED_BUILTIN 16
#define SENSOR  4

long currentMillis = 0;
long previousMillis = 0;
int interval = 1000;
boolean ledState = LOW;
float calibrationFactor = 4.5;
volatile byte pulseCount;
byte pulse1Sec = 0;
float flowRate;
unsigned int flowMilliLitres;
unsigned long totalMilliLitres;

void IRAM_ATTR pulseCounter()
{
  pulseCount++;
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
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(SENSOR, INPUT_PULLUP);

  pulseCount = 0;
  flowRate = 0.0;
  flowMilliLitres = 0;
  totalMilliLitres = 0;
  previousMillis = 0;

  attachInterrupt(digitalPinToInterrupt(SENSOR), pulseCounter, FALLING);

}

void loop()
{
  currentMillis = millis();
  if (currentMillis - previousMillis > interval) {
    
    pulse1Sec = pulseCount;
    pulseCount = 0;

    // Because this loop may not complete in exactly 1 second intervals we calculate
    // the number of milliseconds that have passed since the last execution and use
    // that to scale the output. We also apply the calibrationFactor to scale the output
    // based on the number of pulses per second per units of measure (litres/minute in
    // this case) coming from the sensor.
    flowRate = ((1000.0 / (millis() - previousMillis)) * pulse1Sec) / calibrationFactor;
    previousMillis = millis();

    // Divide the flow rate in litres/minute by 60 to determine how many litres have
    // passed through the sensor in this 1 second interval, then multiply by 1000 to
    // convert to millilitres.
    flowMilliLitres = (flowRate / 60) * 1000;

    // Add the millilitres passed in this second to the cumulative total
    totalMilliLitres += flowMilliLitres;
    
    // Print the flow rate for this second in litres / minute
    Serial.print("Flow rate: ");
    Serial.print(int(flowRate));  // Print the integer part of the variable
    Serial.print("L/min");
    Serial.print("\t");       // Print tab space

    // Print the cumulative total of litres flowed since starting
    Serial.print("Output Liquid Quantity: ");
    Serial.print(totalMilliLitres);
    Serial.print("mL / ");
    Serial.print(totalMilliLitres / 1000);
    Serial.println("L");
    pipeData.set("flowRate", int(flowRate));
    pipeData.set("totalFlow", int(totalMilliLitres));
    Firebase.updateNode(firebaseData2, "/", pipeData); 
  }
  delay(2000);
  
}
