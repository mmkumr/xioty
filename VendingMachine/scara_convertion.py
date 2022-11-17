from firebase import firebase
from serial import Serial
import time
# Serial config.
ser = Serial('COM13')
ser.baudrate = 115200
time.sleep(2)
delay = 0.02
###################
# firebase creds
rtdb = firebase.FirebaseApplication(
    'https://scara-arm-default-rtdb.asia-southeast1.firebasedatabase.app',
    None)
data = rtdb.get("/SCARAPositions", "")
# unique id for each motor
motor = ["0", "0", "0", "0", "0"]
# Converting potentiometer value to step
pottostep = 10
# arraw for storing the relative steps for calculating the speed.
diff = [0] * 5
# Max speed
speed = 2000
# Homing
print("G00")
# G01 for linear interpolation.
print("G01", end=" ")
ser.write("G01 ".encode())
# Loop for printing steps.
for i in range(1, 6):
    # converting potentiometer value to step.
    temp = int(data["m" + str(i)][0]) * pottostep
    # eliminating the values which are zero
    if data["m" + str(i)][0] != "0":
        print(temp, end=" ")
        ser.write((str(temp) + " ").encode())
        # Store same value in diff because relative step for first step will
        # remain same. This array will be used to calculate the speed of each
        # motor.
        diff[i-1] = temp
# End of line for linear interpolation command.
print()
ser.write("\r\n".encode())
time.sleep(delay)
# print(max(diff))
# calculating time take by longest travelling motor.
maxtime = max(diff) * speed
print("S", end=" ")
ser.write("S ".encode())
for i in range(0, 5):
    if diff[i] != max(diff):
        spd = maxtime/int(data["m" + str(i+1)][0])
        print(round(spd, 2), end=" ")
        ser.write((str(round(spd, 2)) + " ").encode())
    else:
        spd = speed
        print(spd, end=" ")
        ser.write((str(round(spd, 2)) + " ").encode())
print()
ser.write("\r\n".encode())
time.sleep(delay)
# interpretation of next points
for i in range(1, len(data["m1"])):
    print("G01", end=" ")
    ser.write("G01 ".encode())
    for j in range(1, 6):
        if data["m" + str(j)][i] != "0":
            if j < 4:
                temp = int(data["m" + str(j)][i]) * pottostep
            elif j > 3:
                temp = int(data["m" + str(j)][i])
            diff[j-1] = temp - int(data["m" + str(j)][i-1])
            if temp != 0:
                print(temp, end=" ")
                ser.write((str(temp) + " ").encode())
    print()
    ser.write("\r\n".encode())
    time.sleep(delay)
    maxtime = max(diff) * speed
    print("S", end=" ")
    ser.write("S ".encode())
    for k in range(0, 5):
        if diff[k] != max(diff):
            spd = maxtime/int(data["m" + str(j)][i])
            print(round(spd, 2), end=" ")
            ser.write((str(round(spd, 2)) + " ").encode())
        else:
            spd = speed
            print(spd, end=" ")
            ser.write((str(round(spd, 2)) + " ").encode())
    print()
    ser.write("\r\n".encode())
    time.sleep(delay)
ser.write("-2\r\n".encode())
