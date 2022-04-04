#include <string.h>
#include <SPI.h>
#include <Wire.h>

//Stepper motor pins
int gen = A2, gd = A1, gp = A0;
int shen = A5, shd = A4, shp = A3;
int sven = A8, svd = A7, svp = A6;
int pen = A11, pd = A10, pp = A9;
int gl = 2, shl = 3, pl = 4;
// variable for storing the input serial string by using the delimeter ' '. Buffer for storing substring of tokenizer.
char buffer[5][20], str[80];
// i for line increment while storing word k for index of word.
int i = 0, dlay = 0;
//Pins for controlling induction cooker.
int induct2_on = 32, induct2_up = 28, induct2_down = 30;
int induct1_on = 22, induct1_up = 26, induct1_down = 24;

int fryon = 5;

//Feedback o/p pin of master.
int wirercv = 31;

void setup() {
  Serial.begin(115200);
  Wire.begin(8);                // join I2C bus with address #8
  Wire.onReceive(receiveEvent); // register event
  pinMode(wirercv, OUTPUT);
  //enables of stepper.
  pinMode(gen, OUTPUT);
  pinMode(shen, OUTPUT);
  pinMode(sven, OUTPUT);
  pinMode(pen, OUTPUT);
  pinMode(fryon, OUTPUT);
  //Pulse of stepper.
  pinMode(gp, OUTPUT);
  pinMode(shp, OUTPUT);
  pinMode(svp, OUTPUT);
  pinMode(pp, OUTPUT);
  //Direction of stepper.
  pinMode(gd, OUTPUT);
  pinMode(shd, OUTPUT);
  pinMode(svd, OUTPUT);
  pinMode(pd, OUTPUT);
  //Limit switches set as input
  pinMode(gl, INPUT_PULLUP);
  pinMode(shl, INPUT_PULLUP);
  pinMode(pl, INPUT_PULLUP);
  //disabling all motors
  analogWrite(gen, LOW);
  digitalWrite(shen, LOW);
  digitalWrite(sven, LOW);
  digitalWrite(pen, LOW);
  digitalWrite(fryon, LOW);
  digitalWrite(wirercv, HIGH);
}
int change = 0;
char cmd[80] = "";
void loop() {

  /*while (Serial.available()) {
    char temp = (char)Serial.read();
    str[i] = temp;
    if (str[i] == ';') {
      str[i] = '\0';
      change = 1;
    }
    ++i;
  }*/
  if (change == 1) {
    digitalWrite(wirercv, LOW);
    strcpy(cmd, str);
    Serial.println(cmd);
    const char s[2] = " ";
    i = 1;
    char* token;
    token = strtok(str, s);
    strcpy(buffer[0], token);
    buffer[0][String(buffer[0]).length()] = '\0';
    while (token != NULL) {
      token = strtok(NULL, s);
      if (String(token).length() != 0) {
        strcpy(buffer[i], token);
        buffer[i][String(buffer[i]).length()] = '\0';
        ++i;
      }
    }
    // change variable is used for check if the ';' is typed of not for marking the end of command;
    // comand fomat "command string speed direction steps ;"
    if (String(buffer[0]) == "grn" || String(buffer[0]) == "\ngrn") {
      // dir, speed, step
      rungrn(atoi(buffer[2]), atoi(buffer[1]), atol(buffer[3]));
    } else if (String(buffer[0]) == "spv" || String(buffer[0]) == "\nspv") {
      // dir, speed, step
      runspv(atoi(buffer[2]), atoi(buffer[1]), atol(buffer[3]));
    } else if (String(buffer[0]) == "sph" || String(buffer[0]) == "\nsph") {
      // dir, speed, step
      runsph(atoi(buffer[2]), atoi(buffer[1]), atol(buffer[3]));
    } else if (String(buffer[0]) == "pmp" || String(buffer[0]) == "\npmp") {
      // dir, speed, step
      runpmp(atoi(buffer[2]), atoi(buffer[1]), atol(buffer[3]));
    } else if (String(buffer[0]) == "ind" || String(buffer[0]) == "\nind") {
      if (atol(buffer[1]) == 1) {
        if (String(buffer[2]) == "on") {
          digitalWrite(induct1_on, HIGH);
          delay(500);
          digitalWrite(induct1_on, LOW);
        } else if (String(buffer[2]) == "up") {
          digitalWrite(induct1_up, HIGH);
          delay(500);
          digitalWrite(induct1_up, LOW);
        } else if (String(buffer[2]) == "down") {
          digitalWrite(induct1_down, HIGH);
          delay(500);
          digitalWrite(induct1_down, LOW);
        }
      } else if (atol(buffer[1]) == 2) {
        if (String(buffer[2]) == "on") {
          digitalWrite(induct2_on, HIGH);
          delay(500);
          digitalWrite(induct2_on, LOW);
        } else if (String(buffer[2]) == "up") {
          digitalWrite(induct2_up, HIGH);
          delay(500);
          digitalWrite(induct2_up, LOW);
        } else if (String(buffer[2]) == "down") {
          digitalWrite(induct2_down, HIGH);
          delay(500);
          digitalWrite(induct2_down, LOW);
        }
        //command syntax eed 0/1 ;
      }
    } else if (String(buffer[0]) == "fry" || String(buffer[0]) == "\nfry") {
      if (atol(buffer[1]) == 1) {
        digitalWrite(fryon, HIGH);
      } else {
        digitalWrite(fryon, LOW);
      }
    }
    change = 0;
    i = 0;
    digitalWrite(wirercv, HIGH);
    Serial.println("done");
  }
}

void rungrn(int direction, int speed, long step) {
  digitalWrite(gen, HIGH);
  digitalWrite(gd, direction);
  for (int i = 0; i < step; i++) {
    if (digitalRead(gl) == HIGH || direction == HIGH) {
      digitalWrite(gp, LOW);
      digitalWrite(gp, HIGH);
      delayMicroseconds(speed);
    } else {
      break;
    }
  }
  digitalWrite(gen, LOW);
}

void runspv(int direction, int speed, long step) {
  digitalWrite(sven, HIGH);
  digitalWrite(svd, direction);
  for (int i = 0; i < step; i++) {
    digitalWrite(svp, LOW);
    digitalWrite(svp, HIGH);
    delayMicroseconds(speed);
  }
  digitalWrite(sven, LOW);
}

void runsph(int direction, int speed, long step) {
  digitalWrite(shen, HIGH);
  digitalWrite(shd, direction);
  for (int i = 0; i < step; i++) {
    if (digitalRead(shl) == HIGH || direction == HIGH) {
      digitalWrite(shp, LOW);
      digitalWrite(shp, HIGH);
      delayMicroseconds(speed);
    } else {
      break;
    }
  }
  digitalWrite(shen, LOW);
}

void runpmp(int direction, int speed, long step) {
  digitalWrite(pen, HIGH);
  digitalWrite(pd, direction);
  for (int i = 0; i < step; i++) {
    if (digitalRead(pl) == HIGH || direction == HIGH) {
      digitalWrite(pp, LOW);
      digitalWrite(pp, HIGH);
      delayMicroseconds(speed);
    } else {
      break;
    }
  }
  digitalWrite(pen, LOW);
}

void receiveEvent(int howMany) {
  while(Wire.available()){
    char temp = (char)Wire.read();
    str[i] = temp;
    if (str[i] == ';') {
      str[i] = '\0';
      change = 1;
    }
    ++i;
  }
}
