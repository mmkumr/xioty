#include <esp_now.h>
#include <WiFi.h>
#include <AccelStepper.h>
#include <MultiStepper.h>

//Stepper configs
int en = 5, dir = 17, pul = 16;
int cw = 22, ccw = 23;
AccelStepper stepper(1, 16, 17);
MultiStepper ms;
//////////////////////////////////
//Variables for storing steps, speed and number of commands.
long rcv[5000];
int spd[5000];
int s = 0;
///////////////////////////////////
//F0:08:D1:57:87:64(Mac address for for future ref.)
//Struct of data receiving
typedef struct struct_message {
  long trigger[5];
  int spd[5];
} struct_message;


// Create a struct_message called myData
struct_message myData;

// callback function that will be executed when data is received
void OnDataRecv(const uint8_t * mac, const uint8_t *incomingData, int len) {
  memcpy(&myData, incomingData, sizeof(myData));
  Serial.println(myData.trigger[0]);
  rcv[s] = myData.trigger[0];
  s++; 
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
  if(myData.trigger[0] == -1){
    Serial.println("Done");
    Serial.println(s);
    long temp = 0;
    for(int i = 0; i < s; i++){
      temp += rcv[i];
      Serial.println(temp);
      stepper.setMaxSpeed(5000);
      long mul[2] = {temp,0};
      ms.moveTo(mul);
      stepper.enableOutputs();
      ms.runSpeedToPosition();
    }
    s = 0;
  }
}
