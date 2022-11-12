#include <WiFi.h>
#include <FirebaseESP32.h>
#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>

Adafruit_PWMServoDriver pca9685 = Adafruit_PWMServoDriver(0x40);
 
// Define maximum and minimum number of "ticks" for the servo motors
// Range from 0 to 4095
// This determines the pulse width
 
#define SERVOMIN  218  // Minimum value
#define SERVOMAX  436  // Maximum value
 


#define FIREBASE_HOST "https://drone-remote-6bcc8-default-rtdb.firebaseio.com/"
#define FIREBASE_AUTH "x4ncEQXvomlrEIYPjHBnugTMIqkdGD8lDFANV9ob"
#define WIFI_SSID "mmkumr"
#define WIFI_PASSWORD "P@$$w0rd"



//Define FirebaseESP8266 data object
FirebaseData firebaseData1;
FirebaseData firebaseData2;

int val = 0, change = 0;
String path; 

unsigned long sendDataPrevMillis = 0;

String parentPath = "/";
String childPath[4] = {"/direction","/throttle", "/mode", "/motor"};
size_t childPathSize = 4;

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
      val = stream.value.toInt();
      change = 1;
      path = stream.dataPath;
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

int I2C_SDA = 1,I2C_SCL = 2;

void setup()
{
  Serial.begin(9600);
  Serial.println("PCA9685 Servo Test");
  pca9685.begin();
  // Set PWM Frequency to 50Hz
  pca9685.setPWMFreq(50);
  pinMode(14, OUTPUT);
  pinMode(27, OUTPUT);
  digitalWrite(14, HIGH);
  digitalWrite(27, HIGH);
  pca9685.setPWM(0, 0, map(150, 100, 200, SERVOMIN, SERVOMAX));// pwm channel no., don't care, pwm ticks value
  pca9685.setPWM(1, 0, map(150, 100, 200, SERVOMIN, SERVOMAX));// pwm channel no., don't care, pwm ticks value
  pca9685.setPWM(2, 0, map(100, 100, 200, SERVOMIN, SERVOMAX));// pwm channel no., don't care, pwm ticks value
  pca9685.setPWM(3, 0, map(150, 100, 200, SERVOMIN, SERVOMAX));// pwm channel no., don't care, pwm ticks value
  pca9685.setPWM(4, 0, map(186, 100, 200, SERVOMIN, SERVOMAX));// pwm channel no., don't care, pwm ticks value
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
}

void loop()
{
  if(WiFi.status() != WL_CONNECTED){
    pca9685.setPWM(3, 0, map(140, 100, 200, SERVOMIN, SERVOMAX));
  }
  // channel no. and its short name dx = 1 dy = 2 ty = 3 tx = 4 m = 5;
  if(change == 1) {
    Serial.println(path);
    if(path == "/direction/x"){
      val = map(val, 100, 200, SERVOMIN, SERVOMAX);
      pca9685.setPWM(0, 0, val);// pwm channel no., don't care, pwm ticks value
    }
    if(path == "/direction/y"){
      val = map(val, 100, 200, SERVOMIN, SERVOMAX);
      pca9685.setPWM(1, 0, val);// pwm channel no., don't care, pwm ticks value
    }
    if(path == "/throttle/y"){
      val = map(val, 100, 200, SERVOMIN, SERVOMAX);
      pca9685.setPWM(2, 0, val);// pwm channel no., don't care, pwm ticks value
    }
    if(path == "/throttle/x"){
      val = map(val, 100, 200, SERVOMIN, SERVOMAX);
      pca9685.setPWM(3, 0, val);// pwm channel no., don't care, pwm ticks value
    }
    if(path == "/mode"){
      val = map(val, 100, 200, SERVOMIN, SERVOMAX);
      pca9685.setPWM(4, 0, val);// pwm channel no., don't care, pwm ticks value
    }
    if(path == "/motor"){
      if(val == 1){
        digitalWrite(14, LOW);
        delay(1000);
      } else if(val == 2){
        digitalWrite(27, LOW);
        delay(1000);
      }
    }
    digitalWrite(14, HIGH);
    digitalWrite(27, HIGH);
   change = 0;
  }
}
