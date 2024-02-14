#!/usr/bin/python
import serial
from time import sleep
from paho.mqtt import client as mqtt
import threading
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
index = 0


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
        # pause_command()
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
    """
    print(command)
    if command[0] != ";":
        ser.write(str.encode(command))
        # sleep(1)
        while ser.readline() != b'ok\n':
            pass


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
                command(ser, (cmds[i] + '\r\n'))
            client.publish(mqtt_topic_send, 'ok', qos=1)
    cmds = []


while True:
    send_message()
