import paho.mqtt.client as mqtt
import threading
from time import sleep

# MQTT setup
mqtt_server = "localhost"
mqtt_port = 1883
mqtt_user = 'xara'
mqtt_password = 'xara'
mqtt_topic_receive = 'response'
mqtt_topic_send = 'commands'
response = ''


def arm(param):
    client.publish("xara/arm", param, qos=0, retain=False)


def induction(param):
    client.publish("xara/induction", param, qos=0, retain=False)


def ingredients(param):
    client.publish("xara/ingredients", param, qos=0, retain=False)


def gripper(param):
    client.publish("xara/gripper", param, qos=0, retain=False)


def stir(param):
    client.publish("xara/stir", param, qos=0, retain=False)


# for assigning keyword to function.
commands = {'G0': arm, 'H': arm, 'ind': induction,
            'M': ingredients, 'S': gripper, 'stir': stir}


# Define callback function to be called when a message is received
def on_message(client, userdata, message):
    global response
    print(
        f"Received message '{message.payload.decode()}' on topic '{message.topic}'")
    response = message.payload.decode()


# Function to send MQTT messages
def send_message(client):
    global response
    file1 = open("xara.txt", "r")

    for lines in file1.readlines():
        try:
            if len(lines.split()) != 0:
                commands[lines.split()[0]](lines)
                print(lines)
                while response != 'o':
                    pass
                response = ''
        except KeyError:
            if lines.split()[0] != ';':
                print('incorrect command')
                print(lines)
    file1.close()
    sleep(5)
    client.loop_stop()
    client.disconnect()


# Create a MQTT client
client = mqtt.Client()
client.username_pw_set(mqtt_user, mqtt_password)
client.connect(mqtt_server, mqtt_port, 60)
client.on_message = on_message
client.subscribe(mqtt_topic_receive)
client.loop_start()

# Start the send_message thread
send_thread = threading.Thread(target=send_message, args=(client,))
send_thread.start()

# Keep the main thread running
while True:
    pass
