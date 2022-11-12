"""Sending serial commands to arduino through specified file."""
import sys
import time
from serial import Serial

ser = Serial('COM4')

ser.baudrate = 115200

time.sleep(2)

for i in range(1, len(sys.argv)):
    with open(sys.argv[i], "r") as file:
        cmd = file.readlines()
        for j, c in enumerate(cmd):
            ser.write(cmd[j].encode())
            rcv = ser.readline()
            print(rcv)
            while rcv != b'o\r\n':
                rcv = ser.readline()
                print(rcv)
        file.close()
