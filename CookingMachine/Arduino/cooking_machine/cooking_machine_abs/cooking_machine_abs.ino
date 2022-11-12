#include <string.h>

//for saving the printing mode.
int mode = 0;
char buffer[5][20], str[80];
int i = 0;

//variables for storing position
long xpos = 0, ypos = 0, rpos = 0, zpos = 0;

void setup() {
  Serial.begin(115200);
}
int change = 0;


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
    if (String(buffer[0]) == "x" || String(buffer[0]) == "\nx") {
      xpos += atol(buffer[1]);
    } else if (String(buffer[0]) == "y" || String(buffer[0]) == "\ny") {
      ypos += atol(buffer[1]);
    } else if (String(buffer[0]) == "r" || String(buffer[0]) == "\nr") {
      ypos += atol(buffer[1]);
    } else if (String(buffer[0]) == "z" || String(buffer[0]) == "\nz") {
      // dir, speed, step
      zpos += atol(buffer[1]);
    } else if (String(buffer[0]) == "xy" || String(buffer[0]) == "\nxy") {
      xpos += atol(buffer[1]);
      ypos += atol(buffer[2]);
    } else if (String(buffer[0]) == "xyzr" || String(buffer[0]) == "\nxyzr") {
      xpos += atol(buffer[1]);
      ypos += atol(buffer[2]);
      zpos += atol(buffer[3]);
      rpos += atol(buffer[4]);
    }
    Serial.print(cmd);
    Serial.print("  ");
    Serial.print(xpos);
    Serial.print("  ");
    Serial.print(ypos);
    Serial.print("  ");
    Serial.print(zpos);
    Serial.print("  ");
    Serial.print(rpos);
    change = 0;
    i = 0;
  }
}
