/*Command of master
 * x/y/z/r +/-steps ;
 * ts/gs/ps/fs angle ;
 * tool/pump pwm direction ;
 * Direction of pump is 1.
*/
/*Command of slave
 * grn/spv/sph/pmp speed direction steps ;
 * ind 1/2 on/up/down ;
 * fry 1/0 ;
*/
#include <ESP32Servo.h>
#include <string.h>
#include <SPI.h>
#include <Wire.h>

Servo ts;  //Tool servo
Servo gs;  // Endeffector servo
Servo ps;  //Tool servo
Servo fs;  // Endeffector servo


//Stepper motor pins
int xd = 1, xp = 0, xe = 2;
int yd = 4, yp = 3, ye = 5;
int zd = 7, zp = 6, ze = 8;
int rd = 10, rp = 9, re = 11;
int eed = 0, eep = 0, eee = 0;
int tpwm = 42, tdir = 40;        //Pins for controlling endeffector detachable motor.
int pumppwm = 46, pumpdir = 44;  //Pins for controlling water pump.
//limit switch
int eel = 0, xl = 14, yl = 15, zl = 16, rl = 17;
//Feedback i/p pin from slave.
int wirercv = 31;
// variable for storing the input serial string by using the delimeter ' '. Buffer for storing substring of tokenizer.
char buffer[5][20], str[80];
// i for line increment while storing word k for index of word.
int i = 0, dlay = 0;

int tsPos = 0, gsPos = 0, psPos = 0, fsPos = 0;  // Position of servos.
int tsPin = 5, gsPin = 6, psPin = 3, fsPin = 2;  //pin no. of servos.



//#define TIMER1_INTERRUPTS_ON TIMSK1 |= (1 << OCIE1A);
//#define TIMER1_INTERRUPTS_OFF TIMSK1 &= ~(1 << OCIE1A);

hw_timer_t* timer = NULL;  //H/W timer defining (Pointer to the Structure)
portMUX_TYPE timerMux = portMUX_INITIALIZER_UNLOCKED;
volatile int OCR1A;

//for saving the printing mode.
int mode = 0;

struct stepperInfo {
  // externally defined parameters
  float acceleration;
  volatile unsigned long minStepInterval;  // ie. max speed, smaller is faster
  void (*dirFunc)(int);
  void (*stepFunc)();

  // derived parameters
  unsigned int c0;    // step interval for first step, determines acceleration
  long stepPosition;  // current position of stepper (total of all movements taken so far)

  // per movement variables (only changed once per movement)
  volatile int dir;                        // current direction of movement, used to keep track of position
  volatile unsigned long totalSteps;       // number of steps requested for current movement
  volatile bool movementDone = false;      // true if the current movement has been completed (used by main program to wait for completion)
  volatile unsigned long rampUpStepCount;  // number of steps taken to reach either max speed, or half-way to the goal (will be zero until this number is known)
  volatile unsigned long estStepsToSpeed;  // estimated steps required to reach max speed
  volatile unsigned long estTimeForMove;   // estimated time (interrupt ticks) required to complete movement
  volatile unsigned long rampUpStepTime;
  volatile float speedScale;  // used to slow down this motor to make coordinated movement with other motors

  // per iteration variables (potentially changed every interrupt)
  volatile unsigned long n;          // index in acceleration curve, used to calculate next interval
  volatile float d;                  // current interval length
  volatile unsigned long di;         // above variable truncated
  volatile unsigned long stepCount;  // number of steps completed in current movement
  volatile int homedir;              //inversion of direction from home.
  volatile int limit_switch;
};

void xStep() {
  digitalWrite(xp, HIGH);
  digitalWrite(xp, LOW);
}
void xDir(int dir) {
  digitalWrite(xd, dir);
}

void yStep() {
  digitalWrite(yp, HIGH);
  digitalWrite(yp, LOW);
}
void yDir(int dir) {
  digitalWrite(yd, dir);
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

void resetStepperInfo(stepperInfo& si) {
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
volatile byte remainingSteppersFlag = 0;

volatile byte nextStepperFlag = 0;

void IRAM_ATTR onTimer() {
  unsigned int tmpCtr = OCR1A;

  OCR1A = 65500;
  timerAlarmWrite(timer, OCR1A, true);

  for (long i = 0; i < NUM_STEPPERS; i++) {

    if (!((1 << i) & remainingSteppersFlag))
      continue;

    if (!(nextStepperFlag & (1 << i))) {
      steppers[i].di -= tmpCtr;
      continue;
    }

    volatile stepperInfo& s = steppers[i];

    if (s.stepCount < s.totalSteps) {
      s.stepFunc();
      s.stepCount++;
      s.stepPosition += s.dir;
      if (s.stepCount >= s.totalSteps || (digitalRead(s.limit_switch) == LOW && s.homedir == (s.dir == 1 ? HIGH : LOW))) {
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

    s.di = s.d * s.speedScale;  // integer
  }

  setNextInterruptInterval();

  timerWrite(timer, 0);
}

void setup() {
  Serial.begin(115200);
  Wire.begin();
  pinMode(wirercv, INPUT_PULLUP);  //feedback pin of slave
  //setting tool pins
  fs.attach(2);
  ps.attach(3);
  gs.attach(5);
  ts.attach(6);
  //Setting pinmode for all Output pins
  //output pins for z axis
  pinMode(zd, OUTPUT);
  pinMode(zp, OUTPUT);
  pinMode(ze, OUTPUT);
  //output pins for endeffector axis
  pinMode(eed, OUTPUT);
  pinMode(eep, OUTPUT);
  pinMode(eee, OUTPUT);
  //output pins for y axis
  pinMode(yd, OUTPUT);
  pinMode(yp, OUTPUT);
  pinMode(ye, OUTPUT);
  //output pins for x axis
  pinMode(xd, OUTPUT);
  pinMode(xp, OUTPUT);
  pinMode(xe, OUTPUT);
  //output pins for Rail axis
  pinMode(rd, OUTPUT);
  pinMode(rp, OUTPUT);
  pinMode(re, OUTPUT);
  //output pins for spices.
  //Limit switches set as input
  pinMode(zl, INPUT_PULLUP);
  pinMode(eel, INPUT_PULLUP);
  pinMode(xl, INPUT_PULLUP);
  pinMode(yl, INPUT_PULLUP);
  pinMode(rl, INPUT_PULLUP);
  //disabling all motors
  digitalWrite(ze, 0);
  digitalWrite(eee, 0);
  digitalWrite(xe, 0);
  digitalWrite(ye, 0);
  digitalWrite(re, 0);
  // higher speed number lower speed
  //runx(LOW, 60, 10000);
  //for writing angle to servo.
  gs.write(0);
  ts.write(0);
  fs.write(0);
  ps.write(0);

  noInterrupts();

  OCR1A = 1000;
  timer = timerBegin(0, 64, true);              // timer 0, prescalar: 64, UP counting
  timerAttachInterrupt(timer, &onTimer, true);  // Attach interrupt
  timerAlarmWrite(timer, OCR1A, true);          // Match value= 1000000 for 1 sec. delay.
  timerAlarmEnable(timer);                      // Enable Timer with interrupt (Alarm Enable)


  interrupts();

  steppers[0].dirFunc = xDir;
  steppers[0].stepFunc = xStep;
  steppers[0].acceleration = 1000;
  steppers[0].minStepInterval = 10;
  steppers[0].homedir = LOW;
  steppers[0].limit_switch = xl;

  steppers[1].dirFunc = yDir;
  steppers[1].stepFunc = yStep;
  steppers[1].acceleration = 1000;
  steppers[1].minStepInterval = 10;
  steppers[1].homedir = LOW;
  steppers[1].limit_switch = yl;

  steppers[2].dirFunc = zDir;
  steppers[2].stepFunc = zStep;
  steppers[2].acceleration = 20;
  steppers[2].minStepInterval = 2;
  steppers[2].homedir = LOW;
  steppers[2].limit_switch = zl;

  steppers[3].dirFunc = rDir;
  steppers[3].stepFunc = rStep;
  steppers[3].acceleration = 200;
  steppers[3].minStepInterval = 1;
  steppers[3].homedir = LOW;
  steppers[3].limit_switch = rl;
}
int change = 0;

void resetStepper(volatile stepperInfo& si) {
  si.c0 = si.acceleration;
  si.d = si.c0;
  si.di = si.d;
  si.stepCount = 0;
  si.n = 0;
  si.rampUpStepCount = 0;
  si.movementDone = false;
  si.speedScale = 1;

  float a = si.minStepInterval / (float)si.c0;
  a *= 0.676;

  float m = ((a * a - 1) / (-2 * a));
  float n = m * m;

  si.estStepsToSpeed = n;
}


float getDurationOfAcceleration(volatile stepperInfo& s, unsigned long numSteps) {
  float d = s.c0;
  float totalDuration = 0;
  for (unsigned long n = 1; n < numSteps; n++) {
    d = d - (2 * d) / (4 * n + 1);
    totalDuration += d;
  }
  return totalDuration;
}

void prepareMovement(int whichMotor, long steps) {
  volatile stepperInfo& si = steppers[whichMotor];
  si.dirFunc(steps < 0 ? LOW : HIGH);
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



void setNextInterruptInterval() {

  bool movementComplete = true;

  unsigned long mind = 999999;
  for (long i = 0; i < NUM_STEPPERS; i++) {
    if (((1 << i) & remainingSteppersFlag) && steppers[i].di < mind) {
      mind = steppers[i].di;
    }
  }

  nextStepperFlag = 0;
  for (long i = 0; i < NUM_STEPPERS; i++) {
    if (!steppers[i].movementDone)
      movementComplete = false;
    if (((1 << i) & remainingSteppersFlag) && steppers[i].di == mind)
      nextStepperFlag |= (1 << i);
  }

  if (remainingSteppersFlag == 0) {
    timerAlarmDisable(timer);
    OCR1A = 65500;
    timerAlarmWrite(timer, OCR1A, true);
  }

  OCR1A = mind;
  timerAlarmWrite(timer, OCR1A, true);
}

void runAndWait() {
  adjustSpeedScales();
  setNextInterruptInterval();
  timerAlarmEnable(timer);
  while (remainingSteppersFlag)
    ;
  remainingSteppersFlag = 0;
  nextStepperFlag = 0;
}

void adjustSpeedScales() {
  float maxTime = 0;

  for (long i = 0; i < NUM_STEPPERS; i++) {
    if (!((1 << i) & remainingSteppersFlag))
      continue;
    if (steppers[i].estTimeForMove > maxTime)
      maxTime = steppers[i].estTimeForMove;
  }

  if (maxTime != 0) {
    for (long i = 0; i < NUM_STEPPERS; i++) {
      if (!((1 << i) & remainingSteppersFlag))
        continue;
      steppers[i].speedScale = maxTime / steppers[i].estTimeForMove;
    }
  }
}
void loop() {
  char cmd[80] = "";
  while (Serial.available()) {
    char temp = (char)Serial.read();
    str[i] = temp;
    if (str[i] == ';') {
      str[i] = '\0';
      change = 1;
    }
    ++i;
  }
  if (change == 1) {
    strcpy(cmd, str);
    if (mode == 0 && !(String(buffer[0]) == "py" || String(buffer[0]) == "\npy")) {
      Serial.println(cmd);
    }
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
    if (String(buffer[0]) == "py" || String(buffer[0]) == "\npy") {
      mode = atoi(buffer[1]);
    } else if (String(buffer[0]) == "x" || String(buffer[0]) == "\nx") {
      runx(atol(buffer[1]));
    } else if (String(buffer[0]) == "y" || String(buffer[0]) == "\ny") {
      runy(atol(buffer[1]));
    } else if (String(buffer[0]) == "e" || String(buffer[0]) == "\ne") {
      runee(atoi(buffer[2]), atoi(buffer[1]), atol(buffer[3]));
    } else if (String(buffer[0]) == "r" || String(buffer[0]) == "\nr") {
      digitalWrite(re, HIGH);
      prepareMovement(3, atol(buffer[1]));
      runAndWait();
      digitalWrite(re, LOW);
    } else if (String(buffer[0]) == "z" || String(buffer[0]) == "\nz") {
      // dir, speed, step
      prepareMovement(2, atol(buffer[1]));
      runAndWait();
    } else if (String(buffer[0]) == "xy" || String(buffer[0]) == "\nxy") {
      prepareMovement(0, atol(buffer[1]));
      prepareMovement(1, atol(buffer[2]));
      runAndWait();
    } else if (String(buffer[0]) == "xyzr" || String(buffer[0]) == "\nxyzr") {
      digitalWrite(re, HIGH);
      prepareMovement(0, atol(buffer[1]));
      prepareMovement(1, atol(buffer[2]));
      prepareMovement(2, atol(buffer[3]));
      prepareMovement(3, atol(buffer[4]));
      runAndWait();
      digitalWrite(re, LOW);
    } else if (String(buffer[0]) == "ts" || String(buffer[0]) == "\nts") {
      moveServo(&tsPos, atoi(buffer[1]), tsPin);
      delay(2000);
    } else if (String(buffer[0]) == "gs" || String(buffer[0]) == "\ngs") {
      moveServo(&gsPos, atoi(buffer[1]), gsPin);
      delay(2000);
    } else if (String(buffer[0]) == "ps" || String(buffer[0]) == "\nps") {
      moveServo(&psPos, atoi(buffer[1]), psPin);
      delay(2000);
    } else if (String(buffer[0]) == "fs" || String(buffer[0]) == "\nfs") {
      moveServo(&fsPos, atoi(buffer[1]), fsPin);
      delay(2000);
    } else if (String(buffer[0]) == "xen" || String(buffer[0]) == "\nxen") {
      if (atol(buffer[1]) == 1) {
        digitalWrite(xe, HIGH);
      } else {
        digitalWrite(xe, LOW);
      }
    } else if (String(buffer[0]) == "yen" || String(buffer[0]) == "\nyen") {
      if (atol(buffer[1]) == 1) {
        digitalWrite(ye, HIGH);
      } else {
        digitalWrite(ye, LOW);
      }
    } else if (String(buffer[0]) == "zen" || String(buffer[0]) == "\nzen") {
      if (atol(buffer[1]) == 1) {
        digitalWrite(ze, HIGH);
      } else {
        digitalWrite(ze, LOW);
      }
    } else if (String(buffer[0]) == "tool" || String(buffer[0]) == "\ntool") {
      analogWrite(tpwm, atoi(buffer[1]));
      if (atol(buffer[2]) == 1) {
        digitalWrite(tdir, HIGH);
      } else {
        digitalWrite(tdir, LOW);
      }
    } else if (String(buffer[0]) == "pump" || String(buffer[0]) == "\npump") {
      analogWrite(pumppwm, atoi(buffer[1]));
      if (atol(buffer[2]) == 1) {
        digitalWrite(pumpdir, HIGH);
      } else {
        digitalWrite(pumpdir, LOW);
      }
    } else if (String(buffer[0]) == "een" || String(buffer[0]) == "\neen") {
      if (atol(buffer[1]) == 1) {
        digitalWrite(eee, HIGH);
      } else {
        digitalWrite(eee, LOW);
      }
    } else if (String(buffer[0]) == "delay" || String(buffer[0]) == "\ndelay") {
      delay(atoi(buffer[1]));
    } else {
      Wire.beginTransmission(8);  // transmit to device #8
      Wire.write(cmd);
      Wire.write(" ;");
      Wire.endTransmission();
      delay(500);
      while (digitalRead(wirercv) == LOW)
        ;
      if (mode == 0) {
        Serial.println("completed");
      }
    }
    if (mode == 1) {
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

void runx(long step) {
  prepareMovement(0, step);
  runAndWait();
}

void runy(long step) {
  prepareMovement(1, step);
  runAndWait();
}

void runr(int direction, int speed, long step) {
  digitalWrite(rd, direction);
  digitalWrite(re, HIGH);
  for (int i = 0; i < step; i++) {
    if (digitalRead(rl) == HIGH || direction == LOW) {
      digitalWrite(rp, LOW);
      digitalWrite(rp, HIGH);
      delayMicroseconds(speed);
    } else {
      break;
    }
  }
  digitalWrite(re, LOW);
}


void moveServo(int* prevPos, int pos, int serpin) {
  Servo myservo;
  myservo.attach(serpin);
  if (pos > *prevPos) {
    for (int i = *prevPos; i <= pos; i++) {
      myservo.write(i);
      delay(20);
    }
  } else {
    for (int i = *prevPos; i >= pos; i--) {
      myservo.write(i);
      delay(20);
    }
  }
  *prevPos = pos;
}
