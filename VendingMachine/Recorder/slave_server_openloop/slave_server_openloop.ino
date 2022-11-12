#include <WiFi.h>
#include <FirebaseESP32.h>

//////////////////////////////////////////////Server and wifi creds
// Replace with your network credentials
const char* ssid = "mmkumr";
const char* password = "P@$$w0rd";

// Set web server port number to 80
WiFiServer server(80);

// Variable to store the HTTP request
String header;
// Current time
unsigned long currentTime = millis();
// Previous time
unsigned long previousTime = 0; 
// Define timeout time in milliseconds (example: 2000ms = 2s)
const long timeoutTime = 2000;
//////////////////////////////////////////////////////////////////////////////

//Firebase configs
#define FIREBASE_HOST "https://scara-arm-default-rtdb.asia-southeast1.firebasedatabase.app"
#define FIREBASE_AUTH "9MylEI5g6IAixH0nGbcrl5iHQfyTaMxqL1Y5gGFd"
//Define FirebaseESP32 data object
FirebaseData fbd;
FirebaseJson json;
///////////////////////////////////////////////////////////////////////////////////////////////////
//motor configs
int en = 5, dir = 17, pul = 16;
int cw = 22, ccw = 23;
long steps = 0;
int multiplier = 0;
//////////////////////////////////////////////////////////////////////////////////////////////////
int i = 0;
void setup() {
  Serial.begin(115200);
  pinMode(ccw, INPUT_PULLUP);
  pinMode(cw, INPUT_PULLUP);
  pinMode(en, OUTPUT);
  pinMode(dir, OUTPUT);
  pinMode(pul, OUTPUT);
  // Connect to Wi-Fi network with SSID and password
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  // Print local IP address and start web server
  Serial.println("");
  Serial.println("WiFi connected.");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
  server.begin();
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.reconnectWiFi(true);
  Firebase.deleteNode(fbd, "/SCARAPositions");
}

void loop(){
  //Motor control buttons
  if(digitalRead(cw) == LOW){
    digitalWrite(en, HIGH);
    digitalWrite(dir, LOW);
    digitalWrite(pul, HIGH);
    delayMicroseconds(200);
    digitalWrite(pul, LOW);
    multiplier = 1;
    steps++;
    Serial.println(steps * multiplier);
  } else if(digitalRead(ccw) == LOW){
    digitalWrite(en, HIGH);
    digitalWrite(dir, HIGH);
    digitalWrite(pul, HIGH);
    delayMicroseconds(200);
    digitalWrite(pul, LOW);
    multiplier = -1;
    steps++;
    Serial.println(steps * multiplier);
  } else {
      digitalWrite(en, LOW);
  }
  WiFiClient client = server.available();   // Listen for incoming clients
  if (client) {                             // If a new client connects,
    currentTime = millis();
    previousTime = currentTime;
    String currentLine = "";                // make a String to hold incoming data from the client
    while (client.connected() && currentTime - previousTime <= timeoutTime) {  // loop while the client's connected
      currentTime = millis();
      if (client.available()) {             // if there's bytes to read from the client,
        char c = client.read();             // read a byte, then
        Serial.write(c);                    // print it out the serial monitor
        header += c;
        if (c == '\n') {                    // if the byte is a newline character
          // if the current line is blank, you got two newline characters in a row.
          // that's the end of the client HTTP request, so send a response:
          if (currentLine.length() == 0) {
            // HTTP headers always start with a response code (e.g. HTTP/1.1 200 OK)
            // and a content-type so the client knows what's coming, then a blank line:
            client.println("HTTP/1.1 200 OK");
            client.println("Content-type:text/html");
            client.println("Connection: close");
            client.println();
            // turns the GPIOs on and off
            if (header.indexOf("GET /send") >= 0) {
              json.set(String(i), String(steps * multiplier));
              i++;
              Serial.println(Firebase.updateNode(fbd,"/SCARAPositions/m4", json));
              steps = 0;
            }
            break;
          } else { // if you got a newline, then clear currentLine
            currentLine = "";
          }
        } else if (c != '\r') {  // if you got anything else but a carriage return character,
          currentLine += c;      // add it to the end of the currentLine
        }
      }
    }
    // Clear the header variable
    header = "";
    // Close the connection
    client.stop();
  }
}
