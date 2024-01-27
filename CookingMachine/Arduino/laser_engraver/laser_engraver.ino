#include <AccelStepper.h>
#include <MultiStepper.h>
#include "TimerThree.h"
#include <gcode.h>

//Variables for pin numbers.
int yd = 9, yp = 8, ye = 10;
int xd = 6, xp = 5, xe = 7;
int extp = 2, extd = 3, exte = 4;
int zp = 0, zd = 0, ze = 0;
int xl = 12, yl = 13, extl = 11;
int laser = 30;

AccelStepper xmotor(AccelStepper::FULL2WIRE, xp, xd);
AccelStepper ymotor(AccelStepper::FULL2WIRE, yp, yd);
AccelStepper zmotor(AccelStepper::FULL2WIRE, zp, zd);
AccelStepper ext(AccelStepper::FULL2WIRE, extp, extd);
MultiStepper xyze;

//inverse kinametics variables.
//angle to step for inverse kinametics.
const float theta1AngleToSteps = 1360;
const float theta2AngleToSteps = 1480;
const float zAngleToSteps = 500;
const float ext2AngleToSteps = 400;
//length variable for x1, x2 / x, y
double L1 = 228;
double L2 = 136.5;
float x_off = 0, y_off = 0;
double theta1, theta2;

//Gcode functions prototype.
void runxy();
void runl();
void inverseKinematics(float x, float y, float z, float e);

#define NumberOfCommands 3
commandscallback commands[NumberOfCommands] = { { "G0", runxy }, { "G1", runxy }, { "M106", runl } };
gcode Commands(NumberOfCommands, commands);


void setup() {
  Commands.begin(115200);
  //output pins for y axis
  pinMode(yd, OUTPUT);
  pinMode(yp, OUTPUT);
  pinMode(ye, OUTPUT);
  //output pins for x axis
  pinMode(xd, OUTPUT);
  pinMode(xp, OUTPUT);
  pinMode(xe, OUTPUT);
  //output pins for extruder axis
  pinMode(extd, OUTPUT);
  pinMode(extp, OUTPUT);
  pinMode(exte, OUTPUT);
  pinMode(laser, OUTPUT);

  //Limit switches set as input
  pinMode(xl, INPUT_PULLUP);
  pinMode(yl, INPUT_PULLUP);
  pinMode(extl, INPUT_PULLUP);
  //disabling all motors
  digitalWrite(xe, HIGH);
  digitalWrite(ye, HIGH);
  digitalWrite(exte, HIGH);
  xmotor.setMaxSpeed(10000);
  ymotor.setMaxSpeed(10000);
  zmotor.setMaxSpeed(10000);
  ext.setMaxSpeed(10000);
  // Then give them to MultiStepper to manage
  xyze.addStepper(xmotor);
  xyze.addStepper(ymotor);
  xyze.addStepper(zmotor);
  xyze.addStepper(ext);
  analogWrite(laser, 0);
}

float xpos = 0, ypos = 0, zpos = 0, eval = 0;
int s = 0;

void loop() {
  Commands.available();
}

void runxy() {
  if (Commands.availableValue('X')) {
    xpos = Commands.GetValue('X');
  }

  if (Commands.availableValue('Y')) {
    ypos = Commands.GetValue('Y');
  }
  if (Commands.availableValue('Z')) {
    zpos = Commands.GetValue('Z');
  }
  if (Commands.availableValue('E')) {
    eval = Commands.GetValue('E');
  }
  inverseKinematics(xpos, ypos, zpos, eval);
}

void runl() {
  if (Commands.availableValue('S')) {
    analogWrite(laser, lround(Commands.GetValue('S')));
  }
}


void inverseKinematics(float x, float y, float z, float e) {
  x = x - x_off;
  y = y - y_off;

  theta2 = acos((sq(x) + sq(y) - sq(L1) - sq(L2)) / (2 * L1 * L2));

  theta1 = atan(y / x) - atan((L2 * sin(theta2)) / (L1 + L2 * cos(theta2)));

  theta2 = theta2 * 180 / PI;
  theta1 = theta1 * 180 / PI;

  // Angles adjustment depending in which quadrant the final tool coordinate x,y is

  if (x < 0 & y > 0) {  // 2nd quadrant
    theta1 = 90 - theta1;
    theta2 = (-1) * theta2;
  }
  if (x < 0 & y < 0) {  // 3d quadrant
    theta1 = 180 + theta1;
  }
  if (x > 0 & y < 0) {  // 4th quadrant
    theta1 = 270 - theta1;
    theta2 = (-1) * theta2;
  }
  if (x < 0 & y == 0) {
    theta1 = 270 + theta1;
  }

  long positions[4] = { lround(theta1 * theta1AngleToSteps), lround(theta2 * theta2AngleToSteps), lround(z * zAngleToSteps), lround(e * ext2AngleToSteps) };
  xyze.moveTo(positions);
  while (xyze.run())
    ;
  /*
  Serial.print("Current Theta1: ");
  Serial.println(positions[0]);
  Serial.print("Current Theta2: ");
  Serial.println(positions[1]);
  Serial.print("Prev Theta1: ");
  Serial.println(prev_theta1);
  Serial.print("Prev Theta2: ");
  Serial.println(prev_theta2);
  prepareMovement(0, current_theta1 * theta2AngleToSteps);
  prepareMovement(1, current_theta2 * theta2AngleToSteps);
  runAndWait();
  */
}
