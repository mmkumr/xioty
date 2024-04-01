#!/usr/bin/python
import serial
from time import sleep
from paho.mqtt import client as mqtt
import threading
from detect_color import detect_color, vid
from inverseKinematics import lastPoint
from os import system


# MQTT setup
mqtt_server = "6b3b54fa5f4a464fa80e2e0410aec35e.s2.eu.hivemq.cloud"
mqtt_port = 8883
mqtt_user = 'xioty'
mqtt_password = 'P@ssw0rd'
mqtt_topic_receive = 'xara/cmd'
mqtt_topic_send = 'response'
cmds = []
prev_cmds = []
pause = False
colorerror = False
x, y = 0, 0
index = 0
colors = {
    "SolidMacro1": "red",
    "SolidMacro2": "orange",
    "SolidMacro3": "yellow",
    "SolidMacro4": "green",
    "SolidMacro5": "blue",
    "SolidMacro6": "violet",

    "LiquidMacro1": "red",
    "LiquidMacro2": "orange",
    "LiquidMacro3": "yellow",
    "LiquidMacro4": "green",
    "Macro1": "blue",
    "Macro2": "violet",
    "Macro3": "black",
    "Macro4": "white",

    "Lid": "black",

    "StirTool": "yellow"
}

color = "red"


def on_message(client, userdata, message):
    """
    Callback function: called when a mqtt message is received
    """
    global cmds, pause, prev_cmds
#   print(
#       f"Received message\
#               '{message.payload.decode()}'\
#               \non topic '{message.topic}' \
#       \nUserdata '{userdata}'")
    response = str(message.payload.decode()).split('\n')
    if response[0] == "pause":
        pause = True
    else:
        prev_cmds = cmds
        cmds = response
        pause = False


client = mqtt.Client()
client.username_pw_set(mqtt_user, mqtt_password)
client.tls_set(ca_certs='./ca.pem')
client.connect(mqtt_server, mqtt_port, 60)
client.on_message = on_message
client.subscribe(mqtt_topic_receive)
client_loop_thread = threading.Thread(target=client.loop_forever)
client_loop_thread.start()
# end of MQTT setup.

ser = serial.Serial('/dev/ttyACM0', 250000)
sleep(2)


def pause_command():
    """
    Function: called when a pause command is sent through mqtt.
    This function will return the index of changed file or index of current
    line.
    """
    global cmds, prev_cmds, index
    temp_index = 0
    for i in range(len(prev_cmds)):
        if (cmds[i] != prev_cmds[i]):
            temp_index = i
            if temp_index < index:
                index = temp_index
            break
    return index


def command(ser, command):
    """
    For Sending commands through serial and waiting for the response('ok')
    For checking the color if it encounters M280 P0
    """
    global color, colors, pause, x, y, colorerror
    print(command)
    if command[0] == ";":
        command = command.replace(";", "")
        try:
            color = colors[command.split()[0]]
            print("Setting color to {}".format(color))
        except KeyError:
            pass
    else:
        ser.write(str.encode(command))
        while ser.readline() != b'ok\n':
            pass


def check_color():
    global color, colors, pause, x, y, colorerror
    if index != len(cmds) - 1:
        subcommands = cmds[index + 1].split()
        if subcommands[0] == "M280" and subcommands[1] == "P0":
            if detect_color() in color.capitalize():
                print("Matching color")
            else:
                client.publish(mqtt_topic_send, 'pause', qos=1)
                print("Color not matched")
                ser.write(str.encode(
                    "G0 X{} Y{} F5000\r\n".format("100", "200")))
                ser.write(str.encode("home" + '\r\n'))
                x, y = lastPoint(cmds[0:index])
                colorerror = True
                pause = True


def send_message():
    """
    For Sending commands through MQTT('ok')
    """
    global cmds, index, pause
    if len(cmds) > 0:
        client.publish(mqtt_topic_send, 'received', qos=1)
        if len(cmds) == 1:
            if cmds[0] == "shutdown":
                client.publish(mqtt_topic_send, 'shutdown', qos=1)
                system("sudo shutdown now")
            else:
                command(ser, (cmds[0] + '\r\n'))
                client.publish(mqtt_topic_send, 'ok', qos=1)
        else:
            for i in range(3):
                ser.write(str.encode(cmds[i]))
            for i in range(3, len(cmds)):
                index = i
                if pause:
                    while pause:
                        pass
                    i = pause_command()
                    if colorerror:
                        command(
                            ser, ("G0 X{} Y{} F5000\r\n".format("100", "200")))
                        command(ser, ("G0 X{} Y{} F5000\r\n".format(x, y)))
                command(ser, (cmds[i] + '\r\n'))
                check_color()
            for i in range(3):
                client.publish(mqtt_topic_send, 'ok', qos=1)
    cmds = []


while True:
    send_message()
