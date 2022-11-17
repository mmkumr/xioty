#include <esp_now.h>
#include <WiFi.h>

// REPLACE WITH YOUR RECEIVER MAC Address
//40:22:D8:EA:02:9C(mac address)
uint8_t broadcastAddress[] = {0x40, 0x22, 0xD8, 0xEA, 0x02, 0x9C};
int length = 50;
char buffer[1000][60];
char termChar = '\n';
long i = 0;
//Struct of data sending
typedef struct struct_message {
  long trigger;
  float spd;
  char cmd[50];
} struct_message;

esp_now_peer_info_t peerInfo;


// Create a struct_message called myData
struct_message myData;

// callback when data is sent
void OnDataSent(const uint8_t *mac_addr, esp_now_send_status_t status) {
  //Serial.print("\r\nLast Packet Send Status:\t");
  //Serial.println(status == ESP_NOW_SEND_SUCCESS ? "Delivery Success" : "Delivery Fail");
}
 
void setup() {
  // Init Serial Monitor
  Serial.begin(115200);
  // Set device as a Wi-Fi Station
  WiFi.mode(WIFI_STA);

  // Init ESP-NOW
  if (esp_now_init() != ESP_OK) {
    Serial.println("Error initializing ESP-NOW");
    return;
  }

  // Once ESPNow is successfully Init, we will register for Send CB to
  // get the status of Trasnmitted packet
  esp_now_register_send_cb(OnDataSent);

  
  // Register peer
  memcpy(peerInfo.peer_addr, broadcastAddress, 6);
  peerInfo.channel = 0;  
  peerInfo.encrypt = false;
  
  // Add peer        
  if (esp_now_add_peer(&peerInfo) != ESP_OK){
    Serial.println("Failed to add peer");
    return;
  }
}

void loop() {
  convert();
}

void convert(){
  while(Serial.available()) {
    int numChars = Serial.readBytesUntil(termChar, buffer[i], length);
    buffer[i][numChars]='\0';
    char cmd[60] = "";
    //strcpy(myData.cmd, buffer[i]);
    //esp_err_t result = esp_now_send(broadcastAddress, (uint8_t *) &myData, sizeof(myData));
    if(strcmp("-1", buffer[i]) == -1){
      for(long a = 0; a < i; a++){
        //char cmd[60] = "";
        strcpy(cmd, buffer[a]);
        //esp_err_t result = esp_now_send(broadcastAddress, (uint8_t *) &myData, sizeof(myData));
        char temp[6][60];
        int space = 0;
        int d = 0;
        for(int i = 0; cmd[i] != '\0'; i++){
            if(cmd[i] != ' '){ 
               temp[space][d] = cmd[i];
               d++;
            }else{
                temp[space][d] = '\0';
                d++;
                d = 0;
                space++;
            }
        }
        if(String(temp[0]) == "G01"){
          myData.trigger = atoi(temp[1]);
          myData.spd = 0;
          esp_err_t result = esp_now_send(broadcastAddress, (uint8_t *) &myData, sizeof(myData));
        }
        if(String(temp[0]) == "S"){
          myData.trigger = 0;
          myData.spd = atof(temp[1]);
          esp_err_t result = esp_now_send(broadcastAddress, (uint8_t *) &myData, sizeof(myData));
        }  
      }
      myData.trigger = -1;
      esp_err_t result = esp_now_send(broadcastAddress, (uint8_t *) &myData, sizeof(myData));
      i = 0;
     } else{
      i++;  
    }
  }
}
