#include <esp_now.h>
#include <WiFi.h>
#include <AccelStepper.h>
#include <MultiStepper.h>

//Stepper configs
int en = 19, dir = 18, pul = 5;
int cw = 12, ccw = 13;
AccelStepper stepper(1, 16, 17);
MultiStepper ms;
//////////////////////////////////
//Variables for storing steps, speed and number of commands.
long rcv[1000];
float spd[1000];
int s = 0;
int r = 0;
///////////////////////////////////
//F0:08:D1:57:87:64(Mac address for for future ref.)
//Struct of data receiving
typedef struct struct_message {
  long trigger;
  float spd;
  char cmd[50];
} struct_message;


// Create a struct_message called myData
struct_message myData;

// callback function that will be executed when data is received
void OnDataRecv(const uint8_t * mac, const uint8_t *incomingData, int len) { 
  memcpy(&myData, incomingData, sizeof(myData));
  //Serial.println(myData.trigger);
  if(round(myData.spd) != 0){
    spd[s] = myData.spd;
    s++;
  }
  if(myData.trigger != 0){
    rcv[r] = myData.trigger;
    r++;
  }
}
// callback when data is sent
void setup() {
  // Initialize Serial Monitor
  Serial.begin(115200);
  pinMode(en, OUTPUT);
  pinMode(dir, OUTPUT);
  pinMode(pul, OUTPUT);
  digitalWrite(en, HIGH);
  // Set device as a Wi-Fi Station
  WiFi.mode(WIFI_STA);
  // Init ESP-NOW
  if (esp_now_init() != ESP_OK) {
    Serial.println("Error initializing ESP-NOW");
    return;
  }
//  callback for data receiving.
  esp_now_register_recv_cb(OnDataRecv);
  stepper.setMaxSpeed(400); //SPEED = Steps / second
  stepper.setAcceleration(800);
  stepper.disableOutputs(); //disable outputs
  ms.addStepper(stepper);
}

void loop() { 
  if(myData.trigger == -1){
    Serial.println("Done");
    Serial.print("no. of steps");
    Serial.println(s);
    Serial.print("no. of speeds");
    Serial.println(r);
    for(int i = 0; i < r ; i++){
      stepper.setMaxSpeed(spd[i]);
      Serial.println(spd[i]);
      long temp[] = {rcv[i], 0};
      Serial.println(rcv[i]);
      ms.moveTo(temp);
      ms.runSpeedToPosition();
    }
    s = 0;
    r = 0;
    myData.trigger = 0;
    myData.spd = 0;
  }
}
