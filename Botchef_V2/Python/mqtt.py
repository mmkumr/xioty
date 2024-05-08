'''
This file contains functions related to mqtt.
'''

import threading
from paho.mqtt import client as mqtt
from paho.mqtt.enums import CallbackAPIVersion


# MQTT setup
MQTT_SERVER = "6b3b54fa5f4a464fa80e2e0410aec35e.s2.eu.hivemq.cloud"
MQTT_PORT = 8883
MQTT_USER = 'xioty'
MQTT_PASSWORD = 'P@ssw0rd'
MQTT_TOPIC_RECEIVE = 'xara/cmds'
MQTT_TOPIC_SEND = 'response'
cmds: list[str] = []
pause: bool = False


def on_message(client, userdata, message) -> None:
    '''
    Callback function: called when a mqtt message is received
    '''
    global cmds, pause
    response = str(message.payload.decode()).split('\n')
    if response[0] == "Pause":
        pause = True
    elif response[0] == "Resume":
        pause = False
    elif response == [""]:
        cmds = []
    else:
        cmds = response
        pause = False
        print(cmds)
        client.publish(MQTT_TOPIC_SEND, "Received", qos=1, retain=True)


client: mqtt.Client = mqtt.Client(CallbackAPIVersion.VERSION1)
client.username_pw_set(MQTT_USER, MQTT_PASSWORD)
client.tls_set(ca_certs='./assets/ca.pem')
client.connect(MQTT_SERVER, MQTT_PORT, 60)
client.on_message = on_message
client.subscribe(MQTT_TOPIC_RECEIVE)
client_loop_thread = threading.Thread(target=client.loop_forever)
client_loop_thread.start()

if __name__ == "__main__":
    while True:
        pass
