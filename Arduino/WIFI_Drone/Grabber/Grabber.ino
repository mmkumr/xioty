
int cw = 9, ccw = 8, i1 = 2, i2 = 3;
void setup() {
  Serial.begin(9600);
  //8=27/1,9=14/0
  pinMode(cw, INPUT_PULLUP);
  pinMode(ccw, INPUT_PULLUP);
  digitalWrite(i1, LOW);
  digitalWrite(i2, LOW);
}

void loop() {
  if(digitalRead(cw) == LOW){
    digitalWrite(i1, LOW);
    digitalWrite(i2, HIGH);
    Serial.println("cw");
    delay(6000);
  }else if(digitalRead(ccw) == LOW){
    digitalWrite(i2, LOW);
    digitalWrite(i1, HIGH);
    Serial.println("ccw");
    delay(6000);
  }
  digitalWrite(i1, LOW);
  digitalWrite(i2, LOW);
}
