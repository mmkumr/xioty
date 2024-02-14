#include <Arduino.h>
#line 1 "/run/media/mmkumr/MyWorkspace/Projects/xioty/BotChef/Arduino/botchef/botchef.ino"
#include <gcode.h>
#include <Servo_Hardware_PWM.h>
#include <Wire.h>


// Setup for Gcode
#define NumberOfCommands 6
void move();
void pwm();
void servo();
void ind();
void disable();
void en();

commandscallback commands[NumberOfCommands] = {
  { "G0", move },
  { "M42", pwm },
  { "M280", servo },
  { "M260", ind },
  { "M18", disable },
  { "M17", en }
};
gcode Commands(NumberOfCommands, commands);
int x = 0, y = 0, z = 0, a = 0, b = 0, p = 0, s = 0, t = 0, i = 0, f = 0;
// Setup for Gcode

// Servo setup
struct servoInfo {
  int position = 0;
  int pin = 0;
};

#define NUM_SERVOS 2
volatile servoInfo servos[NUM_SERVOS];
// End of servo setup

// Setup for stepper motors
int enable = LOW;
int xd = 3, xp = 4, xe = 5, xl = 6;
int yd = 12, yp = 8, ye = 9, yl = 10;
int zd = 14, zp = 15, ze = 16, zl = 17;
int ad = 0, ap = 0, ae = 0, al = 0;
int bd = 0, bp = 0, be = 0, bl = 0;
long xpos = 0, ypos = 0, zpos = 0, apos = 0, bpos = 0;
// Registers manupulation for switching steppers' step pins.
#define x_high PORTG |= 0b00100000;
#define x_low PORTG &= ~0b00100000;

#define y_high PORTH |= 0b00100000;
#define y_low PORTH &= ~0b00100000;

#define z_high PORTJ |= 0b00000001;
#define z_low PORTJ &= ~0b00000001;

#define a_high PORTA |= 0b00010000;
#define a_low PORTA &= ~0b00010000;

#define b_high PORTC |= 0b00000010;
#define b_low PORTC &= ~0b00000010;
// End of registers manupulation for switching steppers' step pins..

// Timer flag configuration
#define TIMER1_INTERRUPTS_ON TIMSK1 |= (1 << OCIE1A);
#define TIMER1_INTERRUPTS_OFF TIMSK1 &= ~(1 << OCIE1A);

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
  x_high;
  x_low;
}
void xDir(int dir) {
  digitalWrite(xd, dir);
}

void yStep() {
  y_high;
  y_low;
}
void yDir(int dir) {
  digitalWrite(yd, dir);
}
void zStep() {
  z_high;
  z_low;
}
void zDir(int dir) {
  digitalWrite(zd, dir);
}
void aStep() {
  a_high;
  a_low;
}
void aDir(int dir) {
  digitalWrite(ad, dir);
}
void bStep() {
  b_high;
  b_low;
}
void bDir(int dir) {
  digitalWrite(bd, dir);
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
#define NUM_STEPPERS 5

volatile stepperInfo steppers[NUM_STEPPERS];
// end of stepper motors setup

void setup() {
  Commands.begin(115200);
  Wire.begin();
  // stepper pins config.
  //x motor
  pinMode(xp, OUTPUT);
  pinMode(xd, OUTPUT);
  pinMode(xe, OUTPUT);
  pinMode(xl, INPUT_PULLUP);
  //y motor
  pinMode(yp, OUTPUT);
  pinMode(yd, OUTPUT);
  pinMode(ye, OUTPUT);
  pinMode(yl, INPUT_PULLUP);
  //z motor
  pinMode(zp, OUTPUT);
  pinMode(zd, OUTPUT);
  pinMode(ze, OUTPUT);
  pinMode(zl, INPUT_PULLUP);
  //a motor
  pinMode(ap, OUTPUT);
  pinMode(ad, OUTPUT);
  pinMode(ae, OUTPUT);
  pinMode(al, INPUT_PULLUP);
  //b motor
  pinMode(bp, OUTPUT);
  pinMode(bd, OUTPUT);
  pinMode(be, OUTPUT);
  pinMode(bl, INPUT_PULLUP);
  // Default value of enable pins
  digitalWrite(xe, !enable);
  digitalWrite(ye, !enable);
  digitalWrite(ze, !enable);
  digitalWrite(ae, !enable);
  digitalWrite(be, !enable);

  //Intialising timers, interrupts and stepper control structs.
  noInterrupts();
  TCCR1A = 0;
  TCCR1B = 0;
  TCNT1 = 0;

  OCR1A = 1000;                           // compare value
  TCCR1B |= (1 << WGM12);                 // CTC mode
  TCCR1B |= ((1 << CS11) | (1 << CS10));  // 64 prescaler
  interrupts();

  steppers[0].dirFunc = xDir;
  steppers[0].stepFunc = xStep;
  steppers[0].acceleration = 50000;
  steppers[0].minStepInterval = 200;
  steppers[0].homedir = LOW;
  steppers[0].limit_switch = xl;

  steppers[1].dirFunc = yDir;
  steppers[1].stepFunc = yStep;
  steppers[1].acceleration = 50000;
  steppers[1].minStepInterval = 200;
  steppers[1].homedir = LOW;
  steppers[1].limit_switch = yl;

  steppers[2].dirFunc = zDir;
  steppers[2].stepFunc = zStep;
  steppers[2].acceleration = 20;
  steppers[2].minStepInterval = 2;
  steppers[2].homedir = LOW;
  steppers[2].limit_switch = zl;

  steppers[3].dirFunc = aDir;
  steppers[3].stepFunc = aStep;
  steppers[3].acceleration = 200;
  steppers[3].minStepInterval = 1;
  steppers[3].homedir = LOW;
  steppers[3].limit_switch = al;

  steppers[3].dirFunc = bDir;
  steppers[3].stepFunc = bStep;
  steppers[3].acceleration = 200;
  steppers[3].minStepInterval = 1;
  steppers[3].homedir = LOW;
  steppers[3].limit_switch = bl;
  // end of stepper pins config.

  // Servo pins config.
  servos[0].pin = 5;
  servos[0].position = 0;
  Servo myServo;
  myServo.attach(servos[0].pin);
  myServo.write(servos[0].position);
  servos[1].pin = 6;
  servos[1].position = 0;
  myServo.attach(servos[1].pin);
  myServo.write(servos[1].position);
  // end of stepper pins config.
}

// Funtions for coordinated motion.
// For setting timers and stepper control structs
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

volatile byte remainingSteppersFlag = 0;

float getDurationOfAcceleration(volatile stepperInfo& s, unsigned long numSteps) {
  float d = s.c0;
  float totalDuration = 0;
  for (unsigned long n = 1; n < numSteps; n++) {
    d = d - (2 * d) / (4 * n + 1);
    totalDuration += d;
  }
  return totalDuration;
}
// Function for moving motors in coordinated motion.
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

volatile byte nextStepperFlag = 0;
// Function for calculating next interrupt interval
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
    TIMER1_INTERRUPTS_OFF
    OCR1A = 65500;
  }

  OCR1A = mind;
}
// Interrupt service routine on timer overflow.
ISR(TIMER1_COMPA_vect) {
  unsigned int tmpCtr = OCR1A;

  OCR1A = 65500;

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
#if (s.stepCount >= s.totalSteps || (digitalRead(s.limit_switch) == LOW && s.homedir == (s.dir == 1 ? HIGH : LOW)))
      if (digitalRead(s.limit_switch) == LOW && s.homedir == (s.dir == 1 ? HIGH : LOW)) {
        s.stepPosition = 0;
      }
      s.movementDone = true;
      remainingSteppersFlag &= ~(1 << i);
#endif
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

  TCNT1 = 0;
}
// Function for running motors in coordinated motion and blocking until all are done.
void runAndWait() {
  adjustSpeedScales();
  setNextInterruptInterval();
  TIMER1_INTERRUPTS_ON;
  while (remainingSteppersFlag)
    ;
  remainingSteppersFlag = 0;
  nextStepperFlag = 0;
}
// For adjusting speed scale in coordinated motion
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
// End of untions for coordinated motion.

void loop() {
  String("").startsWith("G0");

  Commands.available();
}
// Callbacks for commands
// Function for interpolation of motors.
void move() {
  if (Commands.availableValue('X')) {
    x = Commands.GetValue('X');
    x = x - xpos;
    xpos += x;
    if (x != 0) {
      prepareMovement(0, x);
    }
    digitalWrite(xe, enable);
  }
  if (Commands.availableValue('Y')) {
    y = Commands.GetValue('Y');
    y = y - ypos;
    ypos += y;
    if (y != 0) {
      prepareMovement(1, y);
    }
    digitalWrite(ye, enable);
  }
  if (Commands.availableValue('Z')) {
    z = Commands.GetValue('Z');
    z = z - zpos;
    zpos += z;
    if (z != 0) {
      prepareMovement(2, z);
    }
    digitalWrite(ze, enable);
  }
  if (Commands.availableValue('A')) {
    a = Commands.GetValue('A');
    a = a - apos;
    apos += a;
    if (a != 0) {
      prepareMovement(3, a);
    }
    digitalWrite(ae, enable);
  }
  if (Commands.availableValue('B')) {
    b = Commands.GetValue('B');
    b = b - bpos;
    bpos += b;
    if (b != 0) {
      prepareMovement(4, b);
    }
    digitalWrite(be, enable);
  }
  if (Commands.availableValue('F')) {
    f = Commands.GetValue('F');
    for (int i = 0; i < NUM_STEPPERS; ++i) {
      steppers[i].acceleration = f;
    }
  }
  runAndWait();
}

void pwm() {
  if (Commands.availableValue('P')) {
    p = Commands.GetValue('P');
  }
  if (Commands.availableValue('S')) {
    s = Commands.GetValue('S');
  }
  analogWrite(p, s);
}
void ind() {
  if (Commands.availableValue('I')) {
    i = Commands.GetValue('I');
  }
  Wire.beginTransmission(8);
  Wire.write(i / 100);
  Wire.endTransmission();
}

void servo() {
  if (Commands.availableValue('P')) {
    p = Commands.GetValue('P');
  }
  if (Commands.availableValue('S')) {
    s = Commands.GetValue('S');
  }
  if (Commands.availableValue('T')) {
    t = Commands.GetValue('T');
  }
  Servo myServo;
  myServo.attach(servos[p].pin);
  if (s > servos[p].position) {
    for (int i = servos[p].position; i <= s; i++) {
      myServo.write(i);
      delay(t);
    }
  } else {
    for (int i = servos[p].position; i >= s; i--) {
      myServo.write(i);
      delay(t);
    }
  }
  servos[p].position = s;
}
void disable() {
  digitalWrite(xe, !enable);
  digitalWrite(ye, !enable);
  digitalWrite(ze, !enable);
  digitalWrite(ae, !enable);
  digitalWrite(be, !enable);
}
void en() {
  digitalWrite(xe, enable);
  digitalWrite(ye, enable);
  digitalWrite(ze, enable);
  digitalWrite(ae, enable);
  digitalWrite(be, enable);
}
// end of callbacks for commands

