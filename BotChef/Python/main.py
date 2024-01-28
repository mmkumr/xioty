#!/usr/bin/python
import serial
from time import sleep
from paho.mqtt import client as mqtt
import threading


# MQTT setup
mqtt_server = "6b3b54fa5f4a464fa80e2e0410aec35e.s2.eu.hivemq.cloud"
mqtt_port = 8883
mqtt_user = 'xioty'
mqtt_password = 'P@ssw0rd'
mqtt_topic_receive = 'xara/cmd'
mqtt_topic_send = 'response'
cmds = []


def on_message(client, userdata, message):
    """
    Callback function: called when a mqtt message is received
    """
    global cmds
    print(
        f"Received message\
                '{message.payload.decode()}'\
                \non topic '{message.topic}' \
        \nUserdata '{userdata}'")
    response = message.payload.decode()
    cmds = str(response).split('\n')


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


def command(ser, command):
    """
    For Sending commands through serial and waiting for the response('ok')
    """
    ser.write(str.encode(command))
    sleep(0)
    while True:
        line = ser.readline()
        if line == b'ok\n':
            break


def send_message():
    """
    For Sending commands through MQTT('ok')
    """
    global cmds
    if len(cmds) > 0:
        client.publish(mqtt_topic_send, 'received', qos=1)
        for cmd in cmds:
            command(ser, (cmd + '\r\n'))
        client.publish(mqtt_topic_send, 'ok', qos=1)
    cmds = []


while True:
    send_message()

ser = serial.Serial('/dev/ttyACM0', 250000)
sleep(2)
try:
    sleep(4)
    for j, c in enumerate(cmds, 0):
        print(c)
        if c[0] != ';':
            command(ser, (c + '\r\n'))
    sleep(2)
    print('Recipe completed')
except KeyboardInterrupt:
    ser.close()
    exit(0)
