#include <string.h>

#include <Servo.h>

#include <stdlib.h>

Servo ts; //Tool servo
Servo ees; // Endeffector servo

//Stepper motor pins
int zd = 3, zp = 2, ze = 4;
int eed = 6, eep = 5, eee = 7;
int eepwm = 51, eedir = 49; //Pins for controlling endeffector detachable motor.
int x2d = 9, x2p = 8, x2e = 10;
int x1d = 12, x1p = 11, x1e = 13;
int rd = 24, rp = 22, re = 26;
//angle to step for x1 and x2
int x1atos  = 423.333;
int x2atos  = 359.444;
//limit switch
int eel = 30, x1l = 34, x2l = 32, zl = 36, rl = 38;
// variable for storing the input serial string by using the delimeter ' '. Buffer for storing substring of tokenizer.
char buffer[5][20], str[80];
// i for line increment while storing word k for index of word.
int i = 0, dlay = 0;
//Pins for controlling induction cooker.
int induct2_on = 23, induct2_up = 23, induct2_down = 27;
int induct1_on = 29, induct1_up = 31, induct1_down = 33;

void setup() {
    Serial.begin(9600);
    //setting tool pins
    ees.attach(46);
    ts.attach(44);
    //Setting pinmode for all Output pins
    //output pins for z axis
    pinMode(zd, OUTPUT);
    pinMode(zp, OUTPUT);
    pinMode(ze, OUTPUT);
    //output pins for endeffector axis
    pinMode(eed, OUTPUT);
    pinMode(eep, OUTPUT);
    pinMode(eee, OUTPUT);
    //output pins for x2 axis
    pinMode(x2d, OUTPUT);
    pinMode(x2p, OUTPUT);
    pinMode(x2e, OUTPUT);
    //output pins for x1 axis
    pinMode(x1d, OUTPUT);
    pinMode(x1p, OUTPUT);
    pinMode(x1e, OUTPUT);
    //output pins for Rail axis
    pinMode(rd, OUTPUT);
    pinMode(rp, OUTPUT);
    pinMode(re, OUTPUT);
    //Limit switches set as input
    pinMode(zl, INPUT_PULLUP);
    pinMode(eel, INPUT_PULLUP);
    pinMode(x1l, INPUT_PULLUP);
    pinMode(x2l, INPUT_PULLUP);
    pinMode(rl, INPUT_PULLUP);

    //disabling all motors
    digitalWrite(ze, HIGH);
    digitalWrite(eee, HIGH);
    digitalWrite(x1e, HIGH);
    digitalWrite(x2e, HIGH);
    digitalWrite(re, HIGH);
    // higher speed number lower speed
    //runx1(LOW, 60, 10000);
    //for writing angle to servo.
    ees.write(0);
    ts.write(15);
}
int change = 0;
void loop() {
    while (Serial.available()) {
        char temp = (char) Serial.read();
        str[i] = temp;
        if (str[i] == ';') {
            str[i] = '\0';
            change = 1;
        }
        ++i;
    }
    if (change == 1) {
        const char s[2] = " ";
        i = 1;
        char * token;
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
        if (String(buffer[0]) == "x1" || String(buffer[0]) == "\nx1") {
            runx1(atoi(buffer[2]), atoi(buffer[1]), atol(buffer[3]), 0);
            Serial.println("o");
        } else if (String(buffer[0]) == "x2" || String(buffer[0]) == "\nx2") {
            runx2(atoi(buffer[2]), atoi(buffer[1]), atol(buffer[3]), 0);
            Serial.println("o");
        } else if (String(buffer[0]) == "e" || String(buffer[0]) == "\ne") {
            runee(atoi(buffer[2]), atoi(buffer[1]), atol(buffer[3]), 0);
            Serial.println("o");
        } else if (String(buffer[0]) == "r" || String(buffer[0]) == "\nr") {
            runr(atoi(buffer[2]), atoi(buffer[1]), atol(buffer[3]), 0);
            Serial.println("o");
        } else if (String(buffer[0]) == "z" || String(buffer[0]) == "\nz") {
            runz(atoi(buffer[2]), atoi(buffer[1]), atol(buffer[3]), 0);
            Serial.println("o");
        } else if (String(buffer[0]) == "es" || String(buffer[0]) == "\nes") {
            ees.write(atoi(buffer[1]));
            delay(2000);
            Serial.println("o");
        } else if (String(buffer[0]) == "ts" || String(buffer[0]) == "\nts") {
            ts.write(atoi(buffer[1]));
            delay(2000);
            Serial.println("o");
        } else if (String(buffer[0]) == "x1en" || String(buffer[0]) == "\nx1en") {
            if (atol(buffer[1]) == 1) {
                digitalWrite(x1e, HIGH);
            } else {
                digitalWrite(x1e, LOW);
            }
            Serial.println("o");
            //command syntax  ind 1/2 on/up/down ;
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
            }
            Serial.println("o");
            //command syntax eed 0/1 ;
        } else if (String(buffer[0]) == "eed" || String(buffer[0]) == "\need") {
            if (atol(buffer[1]) == 1) {
                digitalWrite(eedir, HIGH);
            } else {
                digitalWrite(eedir, LOW);
            }
            Serial.println("o");
            //command syntax eep pwm ;
        } else if (String(buffer[0]) == "eep" || String(buffer[0]) == "\neep") {
            analogWrite(eepwm, buffer[1]);
            Serial.println("o");
        } else if (String(buffer[0]) == "x2en" || String(buffer[0]) == "\nx2en") {
            if (atol(buffer[1]) == 1) {
                digitalWrite(x2e, HIGH);
            } else {
                digitalWrite(x2e, LOW);
            }
            Serial.println("o");
        } else if (String(buffer[0]) == "zen" || String(buffer[0]) == "\nzen") {
            if (atol(buffer[1]) == 1) {
                digitalWrite(ze, HIGH);
            } else {
                digitalWrite(ze, LOW);
            }
            Serial.println("o");
        }
        change = 0;
        i = 0;
    }
}

void runz(int direction, int speed, long step, int home) {
    digitalWrite(zd, direction);
    for (int i = 0; i < step; i++) {
        if (digitalRead(zl) == HIGH || direction == LOW) {
            digitalWrite(zp, LOW);
            digitalWrite(zp, HIGH);
            delayMicroseconds(speed);
        } else {
            break;
        }
    }
}

void runee(int direction, int speed, long step, int home) {
    digitalWrite(eed, direction);
    digitalWrite(eee, LOW);
    for (int i = 0; i < step; i++) {
        if (digitalRead(eel) == HIGH || direction == HIGH) {
            digitalWrite(eep, LOW);
            digitalWrite(eep, HIGH);
            delayMicroseconds(speed);
        } else {
            break;
        }
    }
    digitalWrite(eee, HIGH);
}

void runx1(int direction, int speed, long step, int home) {
    digitalWrite(x1d, direction);
    for (int i = 0; i < step; i++) {
        if (digitalRead(x1l) == HIGH || direction == HIGH) {
            digitalWrite(x1p, LOW);
            digitalWrite(x1p, HIGH);
            delayMicroseconds(speed);
        } else {
            break;
        }
    }

}

void runx2(int direction, int speed, long step, int home) {
    digitalWrite(x2d, direction);
    for (int i = 0; i < step; i++) {
        if (digitalRead(x2l) == HIGH || direction == LOW) {
            digitalWrite(x2p, LOW);
            digitalWrite(x2p, HIGH);
            delayMicroseconds(speed);
        } else {
            break;
        }
    }
}

void runr(int direction, int speed, long step, int home) {
    digitalWrite(rd, direction);
    digitalWrite(re, LOW);
    for (int i = 0; i < step; i++) {
        if (digitalRead(rl) == HIGH || direction == LOW) {
            digitalWrite(rp, LOW);
            digitalWrite(rp, HIGH);
            delayMicroseconds(speed);
        } else {
            break;
        }
    }
    digitalWrite(re, HIGH);
}
