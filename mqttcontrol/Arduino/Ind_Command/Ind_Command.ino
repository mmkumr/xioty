// command: ind temp_val/0/1

#include <Arduino.h>
#include "WiFi.h"
#include "PubSubClient.h"
#include <WiFiClientSecure.h>


// Define the GPIO pins for the button controls
const int upButtonPin = 14;     // Up button
const int downButtonPin = 27;   // Down button
const int powerButtonPin = 12;  // Power (on/off) button


// Define the initial heat level
int currentHeatLevel = 4;

// Variable to track the target heat level
int targetHeatLevel = 4;

//mqtt
const char* ssid = "ConnectndEnjoy";
const char* password = "P@$$w0rd";
const char* mqttServer = "6b3b54fa5f4a464fa80e2e0410aec35e.s2.eu.hivemq.cloud";
const char* mqtt_username = "xioty";     // MQTT username
const char* mqtt_password = "P@ssw0rd";  // MQTT password
const int mqttPort = 8883;
const char* mqttTopic = "xara/induction";
const char* mqttName = "induction";

WiFiClientSecure espClient;
PubSubClient client(espClient);

/****** root certificate *********/

static const char* root_ca PROGMEM = R"EOF(
-----BEGIN CERTIFICATE-----
MIIFazCCA1OgAwIBAgIRAIIQz7DSQONZRGPgu2OCiwAwDQYJKoZIhvcNAQELBQAw
TzELMAkGA1UEBhMCVVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3VyaXR5IFJlc2Vh
cmNoIEdyb3VwMRUwEwYDVQQDEwxJU1JHIFJvb3QgWDEwHhcNMTUwNjA0MTEwNDM4
WhcNMzUwNjA0MTEwNDM4WjBPMQswCQYDVQQGEwJVUzEpMCcGA1UEChMgSW50ZXJu
ZXQgU2VjdXJpdHkgUmVzZWFyY2ggR3JvdXAxFTATBgNVBAMTDElTUkcgUm9vdCBY
MTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAK3oJHP0FDfzm54rVygc
h77ct984kIxuPOZXoHj3dcKi/vVqbvYATyjb3miGbESTtrFj/RQSa78f0uoxmyF+
0TM8ukj13Xnfs7j/EvEhmkvBioZxaUpmZmyPfjxwv60pIgbz5MDmgK7iS4+3mX6U
A5/TR5d8mUgjU+g4rk8Kb4Mu0UlXjIB0ttov0DiNewNwIRt18jA8+o+u3dpjq+sW
T8KOEUt+zwvo/7V3LvSye0rgTBIlDHCNAymg4VMk7BPZ7hm/ELNKjD+Jo2FR3qyH
B5T0Y3HsLuJvW5iB4YlcNHlsdu87kGJ55tukmi8mxdAQ4Q7e2RCOFvu396j3x+UC
B5iPNgiV5+I3lg02dZ77DnKxHZu8A/lJBdiB3QW0KtZB6awBdpUKD9jf1b0SHzUv
KBds0pjBqAlkd25HN7rOrFleaJ1/ctaJxQZBKT5ZPt0m9STJEadao0xAH0ahmbWn
OlFuhjuefXKnEgV4We0+UXgVCwOPjdAvBbI+e0ocS3MFEvzG6uBQE3xDk3SzynTn
jh8BCNAw1FtxNrQHusEwMFxIt4I7mKZ9YIqioymCzLq9gwQbooMDQaHWBfEbwrbw
qHyGO0aoSCqI3Haadr8faqU9GY/rOPNk3sgrDQoo//fb4hVC1CLQJ13hef4Y53CI
rU7m2Ys6xt0nUW7/vGT1M0NPAgMBAAGjQjBAMA4GA1UdDwEB/wQEAwIBBjAPBgNV
HRMBAf8EBTADAQH/MB0GA1UdDgQWBBR5tFnme7bl5AFzgAiIyBpY9umbbjANBgkq
hkiG9w0BAQsFAAOCAgEAVR9YqbyyqFDQDLHYGmkgJykIrGF1XIpu+ILlaS/V9lZL
ubhzEFnTIZd+50xx+7LSYK05qAvqFyFWhfFQDlnrzuBZ6brJFe+GnY+EgPbk6ZGQ
3BebYhtF8GaV0nxvwuo77x/Py9auJ/GpsMiu/X1+mvoiBOv/2X/qkSsisRcOj/KK
NFtY2PwByVS5uCbMiogziUwthDyC3+6WVwW6LLv3xLfHTjuCvjHIInNzktHCgKQ5
ORAzI4JMPJ+GslWYHb4phowim57iaztXOoJwTdwJx4nLCgdNbOhdjsnvzqvHu7Ur
TkXWStAmzOVyyghqpZXjFaH3pO3JLF+l+/+sKAIuvtd7u+Nxe5AW0wdeRlN8NwdC
jNPElpzVmbUq4JUagEiuTDkHzsxHpFKVK7q4+63SM1N95R1NbdWhscdCb+ZAJzVc
oyi3B43njTOQ5yOf+1CceWxG1bQVs5ZufpsMljq4Ui0/1lvh+wjChP4kqKOJ2qxq
4RgqsahDYVvTH9w7jXbyLeiNdd8XM2w9U/t7y0Ff/9yi0GE44Za4rF2LN9d11TPA
mRGunUHBcnWEvgJBQl9nJEiU0Zsnvgc/ubhPgXRR4Xq37Z0j4r7g1SgEEzwxA57d
emyPxgcYxn/eR44/KJ4EBs+lVDR3veyJm+kXQ99b21/+jh5Xos1AnX5iItreGCc=
-----END CERTIFICATE-----
)EOF";

void callback(char* topic, byte* payload, unsigned int length) {
  String input = "";
  Serial.print("Message arrived in topic: ");
  Serial.println(topic);
  Serial.print("Message: ");
  for (int i = 0; i < length; i++) {
    input += (char)payload[i];
  }
  Serial.println(input);
  client.publish("response", "o");
  induction(input);
}
//end of mqtt

void setup() {
  // Initialize serial communication
  Serial.begin(115200);
  //mqtt
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi...");
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print("..");
  }
  Serial.println();
  Serial.println("Connected to WiFi");
  espClient.setCACert(root_ca);  // enable this line and the the "certificate" code for secure connection
  client.setServer(mqttServer, mqttPort);
  client.setCallback(callback);
  while (!client.connected()) {
    if (client.connect(mqttName, mqtt_username, mqtt_password)) {
      Serial.println("Connected to MQTT broker");
      client.subscribe(mqttTopic);
    } else {
      Serial.print("Failed, rc=");
      Serial.print(client.state());
      Serial.println(" Retrying in 5 seconds...");
      delay(5000);
    }
  }
  //end of mqtt
  // Set button control pins as outputs
  pinMode(upButtonPin, OUTPUT);
  pinMode(downButtonPin, OUTPUT);
  pinMode(powerButtonPin, OUTPUT);

  digitalWrite(upButtonPin, HIGH);
  digitalWrite(downButtonPin, HIGH);
  digitalWrite(powerButtonPin, HIGH);
  delay(5000);
  // Initially, turn the induction cooktop off
  // digitalWrite(powerButtonPin, LOW);
  // delay(500); // Simulate button press
  // digitalWrite(powerButtonPin, HIGH);
}
int t = 0;      // Temperature input
int state = 0;  // Power status of Induction cooker.
void loop() {
  if (Serial.available()) {
    String input = Serial.readStringUntil('\n');
    induction(input);
  }
  client.loop();
}

void induction(String input) {
  if (sscanf(input.c_str(), "ind %d", &t) == 1) {
    if (t == 0) {
      digitalWrite(powerButtonPin, LOW);
      delay(1000);  // Simulate button press
      digitalWrite(powerButtonPin, HIGH);
      state = 0;
    } else if (state == 0) {
      targetHeatLevel = 4;
      currentHeatLevel = targetHeatLevel;
      digitalWrite(powerButtonPin, LOW);
      delay(1000);  // Simulate button press
      digitalWrite(powerButtonPin, HIGH);
      state = 1;
      Serial.println("Turn on");
    }
    if (t == 200) {
      targetHeatLevel = 0;
    } else if (t == 400) {
      targetHeatLevel = 1;
    } else if (t == 800) {
      targetHeatLevel = 2;
    } else if (t == 1000) {
      targetHeatLevel = 3;
    } else if (t == 1300) {
      targetHeatLevel = 4;
    } else if (t == 1600) {
      targetHeatLevel = 5;
    } else if (t == 1800) {
      targetHeatLevel = 6;
    } else if (t == 2000) {
      targetHeatLevel = 7;
    }
    adjustHeatLevel();
  }
}
// Function to adjust the heat level
void adjustHeatLevel() {
  // Calculate the number of steps (up or down)
  int steps = targetHeatLevel - currentHeatLevel;
  Serial.println(steps);
  // Simulate button presses to reach the target heat level
  if (steps > 0) {
    for (int i = 0; i < steps; i++) {
      digitalWrite(upButtonPin, LOW);
      delay(500);  // Simulate button press
      digitalWrite(upButtonPin, HIGH);
      delay(500);  // Delay between button presses
    }
  } else if (steps < 0) {
    steps = abs(steps);
    for (int i = 0; i < steps; i++) {
      digitalWrite(downButtonPin, LOW);
      delay(500);  // Simulate button press
      digitalWrite(downButtonPin, HIGH);
      delay(500);  // Delay between button presses
    }
  }

  // Update the current heat level
  currentHeatLevel = targetHeatLevel;

  // Print the new heat level for debugging
  // Serial.print("Heat Level: ");
  // Serial.println(currentHeatLevel);
}
