#include <Servo_Hardware_PWM.h>

#include <string.h>


#include <stdlib.h>

Servo ts; //Tool servo
Servo ees; // Endeffector servo

//Stepper motor pins
int zd = 1, zp = 2, ze = 4;
int eed = 6, eep = 5, eee = 7;
int eepwm = 51, eedir = 49; //Pins for controlling endeffector detachable motor.
int x2d = A7, x2p = A6, x2e = A2;
int x1d = A1, x1p = A0, x1e = 38;
int rd = 24, rp = 22, re = 26;
//angle to step for x1 and x2.
int x1atos = 423.333;
int x2atos = 359.444;
//angle to step for inverse kinametics.
const float theta1AngleToSteps = 171.6;
const float theta2AngleToSteps = 186.3;
const float zDistanceToSteps = 100;
//length variable for x1, x2 / x, y
double L1 = 228; // L1 = 228mm
double L2 = 136.5; // L2 = 136.5mm
double theta1, theta2, z;

//pump
int pump = 45;
//limit switch
int eel = 0, x1l = 3, x2l = 14, zl = 0, rl = 0;
// variable for storing the input serial string by using the delimeter ' '. Buffer for storing substring of tokenizer.
char buffer[5][20], str[80];
// i for line increment while storing word k for index of word.
int i = 0, dlay = 0;
//Pins for controlling induction cooker.
int induct2_on = 23, induct2_up = 23, induct2_down = 27;
int induct1_on = 29, induct1_up = 31, induct1_down = 33;

int s1 = 35, s2 = 37, s3 = 39, s4 = 41, s5 = 43;

#define TIMER1_INTERRUPTS_ON TIMSK1 |= (1 << OCIE1A);
#define TIMER1_INTERRUPTS_OFF TIMSK1 &= ~(1 << OCIE1A);
//for saving the printing mode.
int mode = 0;

struct stepperInfo {
    // externally defined parameters
    float acceleration;
    volatile unsigned long minStepInterval; // ie. max speed, smaller is faster
    void( * dirFunc)(int);
    void( * stepFunc)();

    // derived parameters
    unsigned int c0; // step interval for first step, determines acceleration
    long stepPosition; // current position of stepper (total of all movements taken so far)

    // per movement variables (only changed once per movement)
    volatile int dir; // current direction of movement, used to keep track of position
    volatile unsigned long totalSteps; // number of steps requested for current movement
    volatile bool movementDone = false; // true if the current movement has been completed (used by main program to wait for completion)
    volatile unsigned long rampUpStepCount; // number of steps taken to reach either max speed, or half-way to the goal (will be zero until this number is known)
    volatile unsigned long estStepsToSpeed; // estimated steps required to reach max speed
    volatile unsigned long estTimeForMove; // estimated time (interrupt ticks) required to complete movement
    volatile unsigned long rampUpStepTime;
    volatile float speedScale; // used to slow down this motor to make coordinated movement with other motors

    // per iteration variables (potentially changed every interrupt)
    volatile unsigned long n; // index in acceleration curve, used to calculate next interval
    volatile float d; // current interval length
    volatile unsigned long di; // above variable truncated
    volatile unsigned int stepCount; // number of steps completed in current movement
};

void x1Step() {
    digitalWrite(x1p, HIGH);
    digitalWrite(x1p, LOW);
    /*X_STEP_HIGH
    X_STEP_LOW*/
}
void x1Dir(int dir) {
    digitalWrite(x1d, dir);
}

void x2Step() {
    digitalWrite(x2p, HIGH);
    digitalWrite(x2p, LOW);
}
void x2Dir(int dir) {
    digitalWrite(x2d, dir);
}

void zStep() {
    digitalWrite(zp, HIGH);
    digitalWrite(zp, LOW);
}
void zDir(int dir) {
    digitalWrite(zd, dir);
}

void rStep() {
    digitalWrite(rp, HIGH);
    digitalWrite(rp, LOW);
}
void rDir(int dir) {
    digitalWrite(rd, dir);
}

void resetStepperInfo(stepperInfo & si) {
    si.n = 0;
    si.d = 0;
    si.di = 0;
    si.stepCount = 0;
    si.rampUpStepCount = 0;
    si.rampUpStepTime = 0;
    si.totalSteps = 0;
    si.stepPosition = 0;
    si.movementDone = false;
}

#define NUM_STEPPERS 4

volatile stepperInfo steppers[NUM_STEPPERS];

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
    //output pins for spices.
    pinMode(s1, OUTPUT);
    pinMode(s2, OUTPUT);
    pinMode(s3, OUTPUT);
    pinMode(s4, OUTPUT);
    pinMode(s5, OUTPUT);
    pinMode(pump, OUTPUT);
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

    noInterrupts();
    TCCR1A = 0;
    TCCR1B = 0;
    TCNT1 = 0;

    OCR1A = 1000; // compare value
    TCCR1B |= (1 << WGM12); // CTC mode
    TCCR1B |= ((1 << CS11) | (1 << CS10)); // 64 prescaler
    interrupts();

    steppers[0].dirFunc = x1Dir;
    steppers[0].stepFunc = x1Step;
    steppers[0].acceleration = 1000;
    steppers[0].minStepInterval = 40;

    steppers[1].dirFunc = x2Dir;
    steppers[1].stepFunc = x2Step;
    steppers[1].acceleration = 1000;
    steppers[1].minStepInterval = 40;

    steppers[2].dirFunc = zDir;
    steppers[2].stepFunc = zStep;
    steppers[2].acceleration = 1000;
    steppers[2].minStepInterval = 20;

    steppers[3].dirFunc = rDir;
    steppers[3].stepFunc = rStep;
    steppers[3].acceleration = 1000;
    steppers[3].minStepInterval = 20;
}
int change = 0;

void resetStepper(volatile stepperInfo & si) {
    si.c0 = si.acceleration;
    si.d = si.c0;
    si.di = si.d;
    si.stepCount = 0;
    si.n = 0;
    si.rampUpStepCount = 0;
    si.movementDone = false;
    si.speedScale = 1;

    float a = si.minStepInterval / (float) si.c0;
    a *= 0.676;

    float m = ((a * a - 1) / (-2 * a));
    float n = m * m;

    si.estStepsToSpeed = n;
}

volatile byte remainingSteppersFlag = 0;

float getDurationOfAcceleration(volatile stepperInfo & s, unsigned int numSteps) {
    float d = s.c0;
    float totalDuration = 0;
    for (unsigned int n = 1; n < numSteps; n++) {
        d = d - (2 * d) / (4 * n + 1);
        totalDuration += d;
    }
    return totalDuration;
}

void prepareMovement(int whichMotor, long steps) {
    volatile stepperInfo & si = steppers[whichMotor];
    si.dirFunc(steps < 0 ? HIGH : LOW);
    si.dir = steps > 0 ? 1 : -1;
    si.totalSteps = abs(steps);
    resetStepper(si);

    remainingSteppersFlag |= (1 << whichMotor);

    unsigned long stepsAbs = abs(steps);

    if ((2 * si.estStepsToSpeed) < stepsAbs) {
        // there will be a period of time at full speed
        unsigned long stepsAtFullSpeed = stepsAbs - 2 * si.estStepsToSpeed;
        float accelDecelTime = getDurationOfAcceleration(si, si.estStepsToSpeed);
        si.estTimeForMove = 2 * accelDecelTime + stepsAtFullSpeed * si.minStepInterval;
    } else {
        // will not reach full speed before needing to slow down again
        float accelDecelTime = getDurationOfAcceleration(si, stepsAbs / 2);
        si.estTimeForMove = 2 * accelDecelTime;
    }
}

volatile byte nextStepperFlag = 0;

void setNextInterruptInterval() {

    bool movementComplete = true;

    unsigned long mind = 999999;
    for (int i = 0; i < NUM_STEPPERS; i++) {
        if (((1 << i) & remainingSteppersFlag) && steppers[i].di < mind) {
            mind = steppers[i].di;
        }
    }

    nextStepperFlag = 0;
    for (int i = 0; i < NUM_STEPPERS; i++) {
        if (!steppers[i].movementDone)
            movementComplete = false;
        if (((1 << i) & remainingSteppersFlag) && steppers[i].di == mind)
            nextStepperFlag |= (1 << i);
    }

    if (remainingSteppersFlag == 0) {
        TIMER1_INTERRUPTS_OFF
        OCR1A = 65500;
    }

    OCR1A = mind;
}

ISR(TIMER1_COMPA_vect) {
    unsigned int tmpCtr = OCR1A;

    OCR1A = 65500;

    for (int i = 0; i < NUM_STEPPERS; i++) {

        if (!((1 << i) & remainingSteppersFlag))
            continue;

        if (!(nextStepperFlag & (1 << i))) {
            steppers[i].di -= tmpCtr;
            continue;
        }

        volatile stepperInfo & s = steppers[i];

        if (s.stepCount < s.totalSteps) {
            s.stepFunc();
            s.stepCount++;
            s.stepPosition += s.dir;
            if (s.stepCount >= s.totalSteps) {
                s.movementDone = true;
                remainingSteppersFlag &= ~(1 << i);
            }
        }

        if (s.rampUpStepCount == 0) {
            s.n++;
            s.d = s.d - (2 * s.d) / (4 * s.n + 1);
            if (s.d <= s.minStepInterval) {
                s.d = s.minStepInterval;
                s.rampUpStepCount = s.stepCount;
            }
            if (s.stepCount >= s.totalSteps / 2) {
                s.rampUpStepCount = s.stepCount;
            }
            s.rampUpStepTime += s.d;
        } else if (s.stepCount >= s.totalSteps - s.rampUpStepCount) {
            s.d = (s.d * (4 * s.n + 1)) / (4 * s.n + 1 - 2);
            s.n--;
        }

        s.di = s.d * s.speedScale; // integer
    }

    setNextInterruptInterval();

    TCNT1 = 0;
}

void runAndWait() {
    adjustSpeedScales();
    setNextInterruptInterval();
    TIMER1_INTERRUPTS_ON;
}

void adjustSpeedScales() {
    float maxTime = 0;

    for (int i = 0; i < NUM_STEPPERS; i++) {
        if (!((1 << i) & remainingSteppersFlag))
            continue;
        if (steppers[i].estTimeForMove > maxTime)
            maxTime = steppers[i].estTimeForMove;
    }

    if (maxTime != 0) {
        for (int i = 0; i < NUM_STEPPERS; i++) {
            if (!((1 << i) & remainingSteppersFlag))
                continue;
            steppers[i].speedScale = maxTime / steppers[i].estTimeForMove;
        }
    }
}
void loop() {
    char cmd[80] = "";
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
        strcpy(cmd, str);
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
        if(mode == 0 && !(String(buffer[0]) == "py" || String(buffer[0]) == "\npy") ){
            Serial.println(cmd);
        }
        // change variable is used for check if the ';' is typed of not for marking the end of command;
        // comand fomat "command string speed direction steps ;"
        if (String(buffer[0]) == "py" || String(buffer[0]) == "\npy"){
            mode = atoi(buffer[1]);
        }else if (String(buffer[0]) == "x1" || String(buffer[0]) == "\nx1") {
            runx1(atol(buffer[1]));
        }else if (String(buffer[0]) == "xy" || String(buffer[0]) == "\nxy") {
            inverseKinematics(atol(buffer[1]), atol(buffer[2]));
        }else if (String(buffer[0]) == "x2" || String(buffer[0]) == "\nx2") {
            runx2(atol(buffer[1]));
        } else if (String(buffer[0]) == "e" || String(buffer[0]) == "\ne") {
            runee(atoi(buffer[2]), atoi(buffer[1]), atol(buffer[3]));
        } else if (String(buffer[0]) == "r" || String(buffer[0]) == "\nr") {
            runr(atoi(buffer[2]), atoi(buffer[1]), atol(buffer[3]));
        } else if (String(buffer[0]) == "z" || String(buffer[0]) == "\nz") {
            runz(atoi(buffer[2]), atoi(buffer[1]), atol(buffer[3]));
        } else if (String(buffer[0]) == "es" || String(buffer[0]) == "\nes") {
            ees.write(atoi(buffer[1]));
            delay(2000);
        } else if (String(buffer[0]) == "ts" || String(buffer[0]) == "\nts") {
            ts.write(atoi(buffer[1]));
            delay(2000);
        } else if (String(buffer[0]) == "x1en" || String(buffer[0]) == "\nx1en") {
            if (atol(buffer[1]) == 1) {
                digitalWrite(x1e, HIGH);
            } else {
                digitalWrite(x1e, LOW);
            }
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
            //command syntax eed 0/1 ;
        } else if (String(buffer[0]) == "eed" || String(buffer[0]) == "\need") {
            if (atol(buffer[1]) == 1) {
                digitalWrite(eedir, HIGH);
            } else {
                digitalWrite(eedir, LOW);
            }
            //command syntax eep pwm ;
        } else if (String(buffer[0]) == "eep" || String(buffer[0]) == "\neep") {
            analogWrite(eepwm, atoi(buffer[1]));
        } else if (String(buffer[0]) == "x2en" || String(buffer[0]) == "\nx2en") {
            if (atol(buffer[1]) == 1) {
                digitalWrite(x2e, HIGH);
            } else {
                digitalWrite(x2e, LOW);
            }
        } else if (String(buffer[0]) == "zen" || String(buffer[0]) == "\nzen") {
            if (atol(buffer[1]) == 1) {
                digitalWrite(ze, HIGH);
            } else {
                digitalWrite(ze, LOW);
            }
        } else if (String(buffer[0]) == "x1x2" || String(buffer[0]) == "\nx1x2") {
            prepareMovement(0, atol(buffer[1]));
            prepareMovement(1, atol(buffer[2]));
            runAndWait();
            while (remainingSteppersFlag);
            remainingSteppersFlag = 0;
            nextStepperFlag = 0;
        } else if (String(buffer[0]) == "x12zr" || String(buffer[0]) == "\nx12zr") {
            prepareMovement(0, atol(buffer[1]));
            prepareMovement(1, atol(buffer[2]));
            prepareMovement(2, atol(buffer[3]));
            prepareMovement(3, atol(buffer[4]));
            runAndWait();
            while (remainingSteppersFlag);
            remainingSteppersFlag = 0;
            nextStepperFlag = 0;
        } else if (String(buffer[0]) == "s1" || String(buffer[0]) == "\ns1"){
            digitalWrite(s1, HIGH);
            delay(500);
            digitalWrite(s1, LOW);
        }
        else if (String(buffer[0]) == "s2" || String(buffer[0]) == "\ns2"){
            digitalWrite(s2, HIGH);
            delay(500);
            digitalWrite(s2, LOW);
        }
        else if (String(buffer[0]) == "s3" || String(buffer[0]) == "\ns3"){
            digitalWrite(s3, HIGH);
            delay(500);
            digitalWrite(s3, LOW);
        }
        else if (String(buffer[0]) == "s4" || String(buffer[0]) == "\ns4"){
            digitalWrite(s4, HIGH);
            delay(500);
            digitalWrite(s4, LOW);
        }
        else if (String(buffer[0]) == "s5" || String(buffer[0]) == "\ns5"){
            digitalWrite(s5, HIGH);
            delay(500);
            digitalWrite(s5, LOW);
        } else if (String(buffer[0]) == "water" || String(buffer[0]) == "\nwater") {
            if (atol(buffer[1]) == 1) {
                digitalWrite(pump, HIGH);
            } else {
                digitalWrite(pump, LOW);
            }
        }
        else if (String(buffer[0]) == "een" || String(buffer[0]) == "\neen") {
            if (atol(buffer[1]) == 1) {
                digitalWrite(eee, HIGH);
            } else {
                digitalWrite(eee, LOW);
            }
        } else if (String(buffer[0]) == "delay" || String(buffer[0]) == "\ndelay") {
            delay(atoi(buffer[1]));
        }
        if(mode == 1){
          Serial.println("o");
        }
        change = 0;
        i = 0;
    }
}

void runz(int direction, int speed, long step) {
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

void runee(int direction, int speed, long step) {
    digitalWrite(eed, direction);
    for (int i = 0; i < step; i++) {
        if (digitalRead(eel) == HIGH || direction == HIGH) {
            digitalWrite(eep, LOW);
            digitalWrite(eep, HIGH);
            delayMicroseconds(speed);
        } else {
            break;
        }
    }
}

void runx1(long step) {
    prepareMovement(0, step);
    runAndWait();
    while (remainingSteppersFlag && (digitalRead(x1l) == LOW || digitalRead(x1d) == HIGH));
    remainingSteppersFlag = 0;
    nextStepperFlag = 0;
}

void runx2(long step) {
    prepareMovement(1, step);
    runAndWait();
    while (remainingSteppersFlag && (digitalRead(x2l) == LOW || digitalRead(x2d) == HIGH));
    remainingSteppersFlag = 0;
    nextStepperFlag = 0;
}

void runr(int direction, int speed, long step) {
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


void inverseKinematics(float x, float y) {
  theta2 = acos((sq(x) + sq(y) - sq(L1) - sq(L2)) / (2 * L1 * L2));
  if (x < 0 & y < 0) {
    theta2 = (-1) * theta2;
  }
  
  theta1 = atan(y / x) - atan((L2 * sin(theta2)) / (L1 + L2 * cos(theta2)));
  
  theta2 = (-1) * theta2 * 180 / PI;
  theta1 = theta1 * 180 / PI;

 // Angles adjustment depending in which quadrant the final tool coordinate x,y is
  if (x >= 0 & y >= 0) {       // 1st quadrant
    theta1 = 90 - theta1;
  }
  if (x < 0 & y > 0) {       // 2nd quadrant
    theta1 = 90 - theta1;
  }
  if (x < 0 & y < 0) {       // 3d quadrant
    theta1 = 270 - theta1;
  }
  if (x > 0 & y < 0) {       // 4th quadrant
    theta1 = -90 - theta1;
  }
  if (x < 0 & y == 0) {
    theta1 = 270 + theta1;
  }
  
  theta1=round(theta1);
  theta2=round(theta2);
  Serial.print("Theta1: ");
  Serial.println(theta1);
  Serial.print("Theta2: ");
  Serial.println(theta2);
  Serial.print("Z: ");
  Serial.println(z);
  
  prepareMovement(0, x * theta2AngleToSteps);
  prepareMovement(1, y * theta2AngleToSteps);
  runAndWait();
  while (remainingSteppersFlag);
  remainingSteppersFlag = 0;
  nextStepperFlag = 0;
}
