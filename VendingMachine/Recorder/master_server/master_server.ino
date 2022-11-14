#include <WiFi.h>
#include <HTTPClient.h>

const char* ssid = "mmkumr";
const char* password = "P@$$w0rd";
int button = 14;
void setup() {
  Serial.begin(115200);
  delay(4000);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi..");
  }

  Serial.println("Connected to the WiFi network");
  pinMode(button, INPUT_PULLUP);
}

void loop() {

  if (!digitalRead(button)) {  //Check the current connection status
    Serial.println("sent");
    HTTPClient http;

    http.begin("http://192.168.132.218/send");  //Specify the URL
    int httpCode = http.GET();                  //Make the request

    if (httpCode > 0) {  //Check for the returning code

      String payload = http.getString();
      Serial.println(httpCode);
      Serial.println(payload);
    }

    else {
      Serial.println("Error on HTTP request");
    }

    http.end();  //Free the resources
  }

  delay(500);
}
