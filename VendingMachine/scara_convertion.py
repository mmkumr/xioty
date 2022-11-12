from firebase import firebase
rtdb = firebase.FirebaseApplication(
    'https://scara-arm-default-rtdb.asia-southeast1.firebasedatabase.app',
    None)
data = rtdb.get("/SCARAPositions", "")
motor = ["A", "B", "C", "D", "E"]
# First point interpretation
print("G00")
print("G01", end=" ")
for i in range(1, 6):
    if data["m" + str(i)][0] != "0":
        print(motor[i-1] + data["m" + str(i)][0], end=" ")
print()

# interpretation of next points
for i in range(1, len(data["m1"])):
    print("G01", end=" ")
    for j in range(1, 6):
        if data["m" + str(j)][i] != "0":
            if j < 4:
                temp = (int(data["m" + str(j)][i]) -
                        int(data["m" + str(j)][i-1]))
            elif j > 3:
                temp = temp = int(data["m" + str(j)][i])
            if temp != 0:
                print(motor[j-1] + str(temp), end=" ")
    print()