// Command format: S 1/2 position speed
#include "WiFi.h"
#include "PubSubClient.h"
#include <SCServo.h>

SMS_STS st;

// the uart used to control servos.
// GPIO 18 - S_RXD, GPIO 19 - S_TXD, as default.
#define S_RXD 18
#define S_TXD 19

int id = 0;
int p = 0;
int s = 0;

// mqtt setup
const char* ssid = "Asu";
const char* password = "12341234";
const char* mqttServer = "192.168.27.253";
const char* mqtt_username = "xara"; // MQTT username
const char* mqtt_password = "xara"; // MQTT password
const int mqttPort = 1883;
const char* mqttTopic = "xara/gripper";
const char* mqttName = "gripper";

WiFiClient espClient;
PubSubClient client(espClient);
void callback(char* topic, byte* payload, unsigned int length) {
  String input = "";
  Serial.print("Message arrived in topic: ");
  Serial.println(topic);
  Serial.print("Message: ");
  for (int i = 0; i < length; i++) {
      input += (char)payload[i];
  }
  Serial.println(input);
  if (sscanf(input.c_str(), "S %d %d %d", &id, &p, &s) == 3){
    st.WritePosEx(id, p, s, 50);
    id = 0;
    p = 0;
    s = 0;
  }
  client.publish("response","o");
}
// mqtt setup end

void setup()
{
  Serial.begin(115200);
  Serial1.begin(1000000, SERIAL_8N1, S_RXD, S_TXD);
  st.pSerial = &Serial1;
  delay(1000);
  //mqtt
  WiFi.begin(ssid, password);
  while(WiFi.status() != WL_CONNECTED) {
      delay(1000);
      Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");

  client.setServer(mqttServer, mqttPort);
  client.setCallback(callback);
  while (!client.connected()) {
      if (client.connect(mqttName,mqtt_username, mqtt_password)) { 
          Serial.println("Connected to MQTT broker");
          client.subscribe(mqttTopic);
      } else {
          Serial.print("Failed, rc=");
          Serial.print(client.state());
          Serial.println(" Retrying in 5 seconds...");
          delay(5000);
      }
  }
  //mqtt end
}

void loop()
{
  
  if(Serial.available()){
     String input = Serial.readStringUntil('\n');
    if (sscanf(input.c_str(), "S %d %d %d", &id, &p, &s) == 3){
      st.WritePosEx(id, p, s, 50);
      id = 0;
      p = 0;
      s = 0;
    }
    if(st.FeedBack(1)!=-1){
      Serial.println(st.ReadMove(-1));
    }
  }
  client.loop();
  //-------------------------------------------------------------------------------------------------------------
  //servo(ID1) speed=3400，acc=50，move to position=4095.
  //delay(2000);
  //st.WritePosEx(1, 2000, 1500, 50);//servo(ID1) speed=3400，acc=50，move to position=2000.
  //delay(2000);
}
