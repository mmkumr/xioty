from firebase import firebase
# firebase creds
rtdb = firebase.FirebaseApplication(
    'https://scara-arm-default-rtdb.asia-southeast1.firebasedatabase.app',
    None)
data = rtdb.get("/SCARAPositions", "")
# unique id for each motor
motor = ["A", "B", "C", "D", "E"]
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
# Loop for printing steps.
for i in range(1, 6):
    # converting potentiometer value to step.
    temp = int(data["m" + str(i)][0]) * pottostep
    # eliminating the values which are zero
    if data["m" + str(i)][0] != "0":
        print(motor[i-1] + str(temp), end=" ")
        # Store same value in diff because relative step for first step will
        # remain same. This array will be used to calculate the speed of each
        # motor.
        diff[i-1] = temp
# End of line for linear interpolation command.
print()
# print(max(diff))
# calculating time take by longest travelling motor.
maxtime = max(diff) * speed
print("S", end=" ")
for i in range(0, 5):
    if diff[i] != max(diff):
        spd = maxtime/int(data["m" + str(i+1)][0])
        print(round(spd, 2), end=" ")
    else:
        spd = speed
        print(spd, end=" ")
print()
# interpretation of next points
for i in range(1, len(data["m1"])):
    print("G01", end=" ")
    for j in range(1, 6):
        if data["m" + str(j)][i] != "0":
            if j < 4:
                temp = int(data["m" + str(j)][i]) * pottostep
            elif j > 3:
                temp = int(data["m" + str(j)][i])
            diff[j-1] = temp - int(data["m" + str(j)][i-1])
            if temp != 0:
                print(motor[j-1] + str(temp), end=" ")
    print()
    maxtime = max(diff) * speed
    print("S", end=" ")
    for k in range(0, 5):
        if diff[k] != max(diff):
            spd = maxtime/int(data["m" + str(j)][i])
            print(round(spd, 2), end=" ")
        else:
            spd = speed
            print(spd, end=" ")
    print()
