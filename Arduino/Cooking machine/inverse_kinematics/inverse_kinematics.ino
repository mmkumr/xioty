const float theta1AngleToSteps = 170;
const float theta2AngleToSteps = 186.3;
const float zDistanceToSteps = 100;

float x_off = 400, y_off = 400;

double L1 = 228; // L1 = 228mm
double L2 = 136.5; // L2 = 136.5mm
double theta1, theta2, z;


int yd = A7, yp = A6, ye = A2;
int xd = A1, xp = A0, xe = 38;
int xl = 3, yl = 14;

float x = 250.0, y = 550.0;


void setup() {
    Serial.begin(9600);
    //output pins for x axis
    pinMode(xd, OUTPUT);
    pinMode(xp, OUTPUT);
    pinMode(xe, OUTPUT);
    pinMode(yd, OUTPUT);
    pinMode(yp, OUTPUT);
    pinMode(ye, OUTPUT);
    pinMode(xl, INPUT_PULLUP);
    pinMode(yl, INPUT_PULLUP);
    digitalWrite(xe, 0);
    digitalWrite(ye, 0);
    inverseKinematics(x, y);
}

void loop() {
  
}


// INVERSE KINEMATICS
void inverseKinematics(float x, float y) {
  x = x - x_off;
  y = y - y_off;

  theta2 = acos((sq(x) + sq(y) - sq(L1) - sq(L2)) / (2 * L1 * L2));
  
  theta1 = atan(y / x) - atan((L2 * sin(theta2)) / (L1 + L2 * cos(theta2)));
  
  theta2 = theta2 * 180 / PI;
  theta1 = theta1 * 180 / PI;

 // Angles adjustment depending in which quadrant the final tool coordinate x,y is
  
  if (x < 0 & y > 0) {       // 2nd quadrant
    theta1 = 90 - theta1;
    theta2 = (-1) * theta2;
  }
  if (x < 0 & y < 0) {       // 3d quadrant
    theta1 = 180 + theta1;
  }
  if (x > 0 & y < 0) {       // 4th quadrant
    theta1 = 270 - theta1;
    theta2 = (-1) * theta2;
  }
  if (x < 0 & y == 0) {
    theta1 = 270 + theta1;
  }
  
 
  Serial.print("Theta1: ");
  Serial.println(theta1);
  Serial.print("Theta2: ");
  Serial.println(theta2);
  Serial.print("Z: ");
  Serial.println(z);
  if(theta1 < 0) {
    digitalWrite(xd, LOW);
  } else{
    digitalWrite(xd, HIGH);
  }

  if(theta2 < 0) {
    digitalWrite(yd, LOW);
  } else{
    digitalWrite(yd, HIGH);
  }
  
  for (long i = 0; i < fabs(theta1 * theta1AngleToSteps); ++i) {
        if(digitalRead(xl) == 1){
          break;
        }
        digitalWrite(xp, LOW);
        digitalWrite(xp, HIGH);
        delayMicroseconds(400);
  }
  for (long i = 0; i < fabs(theta2 * theta2AngleToSteps); ++i) {
        if(digitalRead(yl) == 1){
          break;
        }
        digitalWrite(yp, LOW);
        digitalWrite(yp, HIGH);
        delayMicroseconds(400);
  }

}
