#!/usr/bin/python3
"""Sending serial commands to arduino through specified file."""
import sys
import time
from serial import Serial

ser = Serial('/dev/ttyACM0')

ser.baudrate = 9600

time.sleep(2)

for i in range(1, len(sys.argv)):
    with open(sys.argv[i], "r") as file:
        cmd = file.readlines()
        for j, c in enumerate(cmd):
            ser.write(cmd[j].encode())
            while ser.readline() != b'o\r\n':
                print("waiting")
            print("Executed " + cmd[j])
        file.close()
