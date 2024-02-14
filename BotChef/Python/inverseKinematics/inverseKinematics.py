"""Program for converting points on cartisian system to degrees."""
from math import acos, sqrt, atan, sin, cos, pi

file = open("xara.txt", "r")
cmds = file.readlines()
output = []
x = 0
y = 0
L1 = 228
L2 = 136.5
theta1 = 0.0
theta2 = 0.0


def inverseKinematics():
    """Function for converting x, y points to angle."""
    global x, y, L1, L2, theta1, theta2
    if x != 0 or y != 0:
        theta2 = acos(
            (sqrt(x) + sqrt(y) - sqrt(L1) - sqrt(L2)) / (2 * L1 * L2))
        if x < 0 and y < 0:
            theta2 = (-1) * theta2
        theta1 = atan(x / y) - atan((L2 * sin(theta2)) /
                                    (L1 + L2 * cos(theta2)))
        theta2 = (-1) * theta2 * 180 / pi
        theta1 = theta1 * 180 / pi

        # Angles adjustment depending on the quadrant
        if x >= 0 and y >= 0:  # 1st quadrant
            theta1 = 90 - theta1
        if x < 0 and y > 0:  # 2nd quadrant
            theta1 = 90 - theta1
        if x < 0 and y < 0:  # 3d quadrant
            theta1 = 270 - theta1
        if x > 0 and y < 0:  # 4th quadrant
            theta1 = -90 - theta1
        if x < 0 and y == 0:
            theta1 = 270 + theta1
    return theta1, theta2


for cmd in cmds:
    datas = cmd.split()
    z = ""
    if len(datas) > 0:
        if datas[0] == "G00" or datas[0] == "G01":
            for i, data in enumerate(datas):
                if data[0] == "X":
                    x = float(data[1:])
                elif data[0] == "Y":
                    y = float(data[1:])
                elif i != 0:
                    z += " " + data
            t1, t2 = inverseKinematics()
            output.append(datas[0] + " X" + str(t1) +
                          " " + "X" + str(t2) + z)
        else:
            output.append(cmd)
outputFile = open('output.txt', 'w')
for item in output:
    outputFile.write(item + "\n")
outputFile.close()
