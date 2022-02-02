#!/usr/bin/python3
"""Sending serial commands to arduino through specified file."""
import sys
import time
from serial import Serial

ser = Serial('/dev/ttyACM0')

ser.baudrate = 115200

time.sleep(2)

for i in range(1, len(sys.argv)):
    with open(sys.argv[i], "r", encoding='utf8') as file:
        cmd = file.readlines()
        ser.write(cmd[0].encode())
        ser.write(cmd[1].encode())
        ser.write(cmd[2].encode())
        while ser.readline() != b'1\r\n':
            pass
        for j, c in enumerate(cmd, 3):
            ser.write(cmd[j].encode())
            while ser.readline() != b'OK!\r\n':
                pass
        file.close()
