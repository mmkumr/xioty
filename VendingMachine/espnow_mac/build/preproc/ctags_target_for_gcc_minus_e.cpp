# 1 "/mnt/MyWorkspace/Projects/Xioty/VendingMachine/espnow_mac/espnow_mac.ino"
# 2 "/mnt/MyWorkspace/Projects/Xioty/VendingMachine/espnow_mac/espnow_mac.ino" 2

void setup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_MODE_STA);
  Serial.println(WiFi.macAddress());
}

void loop() {
}
