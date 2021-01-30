#include <Arduino.h>
#include <WiFi.h>
#include <FirebaseESP32.h>

#define FIREBASE_HOST "https://drone-remote-6bcc8-default-rtdb.firebaseio.com/"
#define FIREBASE_AUTH "x4ncEQXvomlrEIYPjHBnugTMIqkdGD8lDFANV9ob"
#define WIFI_SSID "mmkumr"
#define WIFI_PASSWORD "P@$$w0rd"

int val = 100;
// variables for buttons.
int dbxplus = 15, dbxminus = 22, dbyplus = 4, dbyminus = 5, tbxplus = 27, tbxminus = 26, tbyplus = 14, tbyminus = 13;
int arm = 23, cw = 32, ccw = 12, disarm = 33;
//Sliding button for modes
int mode1 = 18, mode2 = 19, mode3 = 21;
//variables for values manupulated by buttons.
int directionx = 150, directiony = 150, throttlex = 150, throttley = 100, fmode = 0;

//Define FirebaseESP32 data object
FirebaseData firebaseData;

FirebaseJson json;

void printResult(FirebaseData &data);

void setup()
{
  pinMode(dbxplus, INPUT_PULLUP);
  pinMode(dbxminus, INPUT_PULLUP);
  pinMode(dbyplus, INPUT_PULLUP);
  pinMode(dbyminus, INPUT_PULLUP);
  pinMode(tbxplus, INPUT_PULLUP);
  pinMode(tbxminus, INPUT_PULLUP);
  pinMode(tbyplus, INPUT_PULLUP);
  pinMode(tbyminus, INPUT_PULLUP);
  pinMode(mode1, INPUT_PULLUP);
  pinMode(mode2, INPUT_PULLUP);
  pinMode(mode3, INPUT_PULLUP);
  pinMode(arm, INPUT_PULLUP);
  pinMode(disarm, INPUT_PULLUP);
  pinMode(cw, INPUT_PULLUP);
  pinMode(ccw, INPUT_PULLUP);

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

  //Set database read timeout to 1 minute (max 15 minutes)
  Firebase.setReadTimeout(firebaseData, 1000 * 60);
  //tiny, small, medium, large and unlimited.
  //Size and its write timeout e.g. tiny (1s), small (10s), medium (30s) and large (60s).
  Firebase.setwriteSizeLimit(firebaseData, "tiny");
  Firebase.setInt(firebaseData, "arm", 0);
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
  else
  {
    Serial.println(data.payload());
  }
}

void loop()
{
  int gap = 100, inc = 3;
  //Throttle y axis
  if (digitalRead(tbyplus) == LOW)
  {
    while (digitalRead(tbyplus) == LOW)
    {
      if (throttley < 200)
      {
        throttley += inc;
        Firebase.setInt(firebaseData, "/throttle/y", throttley);
        delay(gap);
      }
    }
    throttley = 150;
    Firebase.setInt(firebaseData, "/throttle/y", throttley);
  }

  if (digitalRead(tbyminus) == LOW)
  {
    while (digitalRead(tbyminus) == LOW)
    {
      if (throttley > 100)
      {
        throttley = 140;
        Firebase.setInt(firebaseData, "/throttle/y", throttley);
        delay(gap);
      }
    }
    throttley = 150;
    Firebase.setInt(firebaseData, "/throttle/y", throttley);
  }

  //Throttle x axis
  if (digitalRead(tbxplus) == LOW)
  {
    while (digitalRead(tbxplus) == LOW)
    {
      if (throttlex < 200)
      {
        throttlex += inc;
        Firebase.setInt(firebaseData, "/throttle/x", throttlex);
        delay(gap);
      }
    }
    throttlex = 150;
    Firebase.setInt(firebaseData, "/throttle/x", throttlex);
  }

  if (digitalRead(tbxminus) == LOW)
  {
    while (digitalRead(tbxminus) == LOW)
    {
      if (throttlex > 100)
      {
        throttlex -= inc;
        Firebase.setInt(firebaseData, "/throttle/x", throttlex);
        delay(gap);
      }
    }
    throttlex = 150;
    Firebase.setInt(firebaseData, "/throttle/x", throttlex);
  }

  //Direction x axis
  if (digitalRead(dbxplus) == LOW)
  {
    while (digitalRead(dbxplus) == LOW)
    {
      if (directionx < 200)
      {
        directionx += inc;
        Firebase.setInt(firebaseData, "/direction/x", directionx);
        delay(gap);
      }
    }
    directionx = 150;
    Firebase.setInt(firebaseData, "/direction/x", directionx);
  }

  if (digitalRead(dbxminus) == LOW)
  {
    while (digitalRead(dbxminus) == LOW)
    {
      if (directionx > 100)
      {
        directionx -= inc;
        Firebase.setInt(firebaseData, "/direction/x", directionx);
        delay(gap);
      }
    }
    directionx = 150;
    Firebase.setInt(firebaseData, "/direction/x", directionx);
  }

  //Direction y axis
  if (digitalRead(dbyplus) == LOW)
  {
    while (digitalRead(dbyplus) == LOW)
    {
      if (directiony < 200)
      {
        directiony += inc;
        Firebase.setInt(firebaseData, "/direction/y", directiony);
        delay(gap);
      }
    }
    directiony = 150;
    Firebase.setInt(firebaseData, "/direction/y", directiony);
  }
  if (digitalRead(dbyminus) == LOW)
  {
    while (digitalRead(dbyminus) == LOW)
    {
      if (directiony > 100)
      {
        directiony -= inc;
        Firebase.setInt(firebaseData, "/direction/y", directiony);
        delay(gap);
      }
    }
    directiony = 150;
    Firebase.setInt(firebaseData, "/direction/y", directiony);
  }

  //Modes
  if (fmode != 1 && digitalRead(mode1) == LOW)
  {
    fmode = 1;
    Firebase.setInt(firebaseData, "/mode", 186);
  }
  else if (fmode != 2 && digitalRead(mode2) == LOW)
  {
    fmode = 2;
    Firebase.setInt(firebaseData, "/mode", 152);
  }
  else if (fmode != 3 && digitalRead(mode3) == LOW)
  {
    fmode = 3;
    Firebase.setInt(firebaseData, "/mode", 119);
  }

  if (digitalRead(arm) == LOW)
  {
    Firebase.setInt(firebaseData, "/throttle/x", 200);
    Firebase.setInt(firebaseData, "/throttle/y", 100);
    Firebase.setInt(firebaseData, "/direction/x", 100);
    Firebase.setInt(firebaseData, "/direction/y", 100);
    delay(3000);
    Firebase.setInt(firebaseData, "/throttle/x", 150);
    Firebase.setInt(firebaseData, "/throttle/y", 110);
    Firebase.setInt(firebaseData, "/direction/x", 150);
    Firebase.setInt(firebaseData, "/direction/y", 150);
  }
  if (digitalRead(disarm) == LOW)
  {
    Firebase.setInt(firebaseData, "/throttle/y", 100);
  }
  if (digitalRead(cw) == LOW)
  {
    Firebase.setInt(firebaseData, "/motor", 1);
    delay(1000);
    Firebase.setInt(firebaseData, "/motor", 0);
  }
  if (digitalRead(ccw) == LOW)
  {
    Firebase.setInt(firebaseData, "/motor", 2);
    delay(1000);
    Firebase.setInt(firebaseData, "/motor", 0);
  }
}
