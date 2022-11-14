#include <Arduino.h>
#line 1 "/mnt/MyWorkspace/Projects/Xioty/VendingMachine/espnow_mac/espnow_mac.ino"
#include "WiFi.h"

#line 3 "/mnt/MyWorkspace/Projects/Xioty/VendingMachine/espnow_mac/espnow_mac.ino"
void setup();
#line 9 "/mnt/MyWorkspace/Projects/Xioty/VendingMachine/espnow_mac/espnow_mac.ino"
void loop();
#line 3 "/mnt/MyWorkspace/Projects/Xioty/VendingMachine/espnow_mac/espnow_mac.ino"
void setup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_MODE_STA);
  Serial.println(WiFi.macAddress());
}

void loop() {
}

