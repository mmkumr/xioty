#line 1 "/run/media/mmkumr/MyWorkspace/Projects/xioty/mqttcontrol/Arduino/Ind_Command/Ind_Command.ino"
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
miifazcca1ogawibagiraiiqz7dsqonzrgpgu2ociwawdqyjkozihvcnaqelbqaw
tzelmakga1uebhmcvvmxktanbgnvbaotieludgvybmv0ifnly3vyaxr5ifjlc2vh
cmnoiedyb3vwmruwewydvqqdewxju1jhifjvb3qgwdewhhcnmtuwnja0mtewndm4
whcnmzuwnja0mtewndm4wjbpmqswcqydvqqgewjvuzepmccga1uechmgsw50zxju
zxqgu2vjdxjpdhkgumvzzwfyy2ggr3jvdxaxftatbgnvbamtdeltukcgum9vdcby
mtccaiiwdqyjkozihvcnaqebbqadggipadccagocggibak3ojhp0fdfzm54rvygc
h77ct984kixupozxohj3dcki/vvqbvyatyjb3migbesttrfj/rqsa78f0uoxmyf+
0tm8ukj13xnfs7j/evehmkvbiozxaupmzmypfjxwv60pigbz5mdmgk7is4+3mx6u
a5/tr5d8mugju+g4rk8kb4mu0ulxjib0ttov0dinewnwirt18ja8+o+u3dpjq+sw
t8koeut+zwvo/7v3lvsye0rgtbildhcnaymg4vmk7bpz7hm/elnkjd+jo2fr3qyh
b5t0y3hslujvw5ib4ylcnhlsdu87kgj55tukmi8mxdaq4q7e2rcofvu396j3x+uc
b5ipngiv5+i3lg02dz77dnkxhzu8a/ljbdib3qw0ktzb6awbdpukd9jf1b0shzuv
kbds0pjbqalkd25hn7rorfleaj1/ctajxqzbkt5zpt0m9stjeadao0xah0ahmbwn
olfuhjuefxknegv4we0+uxgvcwopjdavbbi+e0ocs3mfevzg6ubqe3xdk3szyntn
jh8bcnaw1ftxnrqhusewmfxit4i7mkz9yiqioymczlq9gwqboomdqahwbfebwrbw
qhygo0aoscqi3haadr8faqu9gy/ropnk3sgrdqoo//fb4hvc1clqj13hef4y53ci
ru7m2ys6xt0nuw7/vgt1m0npagmbaagjqjbama4ga1uddweb/wqeawibbjapbgnv
hrmbaf8ebtadaqh/mb0ga1uddgqwbbr5tfnme7bl5afzgaiiybpy9umbbjanbgkq
hkig9w0baqsfaaocageavr9yqbyyqfdqdlhygmkgjykirgf1xipu+illas/v9lzl
ubhzefntizd+50xx+7lsyk05qavqfyfwhffqdlnrzubz6brjfe+gny+egpbk6zgq
3bebyhtf8gav0nxvwuo77x/py9auj/gpsmiu/x1+mvoibov/2x/qkssisrcoj/kk
nfty2pwbyvs5ucbmiogziuwthdyc3+6wvww6llv3xlfhtjucvjhiinnzkthcgkq5
orazi4jmpj+gslwyhb4phowim57iaztxoojwtdwjx4nlcgdnbohdjsnvzqvhu7ur
tkxwstamzovyyghqpzxjfah3po3jlf+l+/+skaiuvtd7u+nxe5aw0wderln8nwdc
jnpelpzvmbuq4juageiutdkhzsxhpfkvk7q4+63sm1n95r1nbdwhscdcb+zajzvc
oyi3b43njtoq5yof+1ccewxg1bqvs5zufpsmljq4ui0/1lvh+wjchp4kqkoj2qxq
4rgqsahdyvvth9w7jxbyleindd8xm2w9u/t7y0ff/9yi0ge44za4rf2ln9d11tpa
mrgunuhbcnwevgjbql9njeiu0zsnvgc/ubhpgxrr4xq37z0j4r7g1sgeezwxa57d
emypxgcyxn/er44/kj4ebs+lvdr3veyjm+kxq99b21/+jh5xos1anx5iitregcc=
-----END CERTIFICATE-----
)EOF";

#line 70 "/run/media/mmkumr/MyWorkspace/Projects/xioty/mqttcontrol/Arduino/Ind_Command/Ind_Command.ino"
void callback(char* topic, byte* payload, unsigned int length);
#line 84 "/run/media/mmkumr/MyWorkspace/Projects/xioty/mqttcontrol/Arduino/Ind_Command/Ind_Command.ino"
void setup();
#line 127 "/run/media/mmkumr/MyWorkspace/Projects/xioty/mqttcontrol/Arduino/Ind_Command/Ind_Command.ino"
void loop();
#line 135 "/run/media/mmkumr/MyWorkspace/Projects/xioty/mqttcontrol/Arduino/Ind_Command/Ind_Command.ino"
void induction(String input);
#line 172 "/run/media/mmkumr/MyWorkspace/Projects/xioty/mqttcontrol/Arduino/Ind_Command/Ind_Command.ino"
void adjustHeatLevel();
#line 70 "/run/media/mmkumr/MyWorkspace/Projects/xioty/mqttcontrol/Arduino/Ind_Command/Ind_Command.ino"
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

