
void setup() {
  Serial.begin(250000);
  Serial3.begin(250000);
  // initialize digital pin LED_BUILTIN as an output.
  pinMode(13, OUTPUT);
}

// the loop function runs over and over again forever
void loop() {
  if (Serial3.available() > 0) {
    // Read the serial input
    String input = Serial3.readStringUntil('\n');
    digitalWrite(13, HIGH);
    delay(2000);
    digitalWrite(13, LOW);
    Serial.println(input);
  }
}
