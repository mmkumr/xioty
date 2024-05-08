from os import system
from timeit import default_timer as timer
from time import sleep
from firebase_admin import credentials, firestore, initialize_app
import serial
import mqtt
from create_recipe import create_recipe

cred = credentials.Certificate("./assets/xara-firebase.json")
app = initialize_app(cred)
db = firestore.client()
ser = serial.Serial('/dev/ttyACM0', 250000)
sleep(2)


def sendSerialCommand(ser, command):
    """
    For Sending commands through serial and waiting for the response('ok')
    """
    print(command)
    if command[0] == ";" or command == "Shutdown":
        return
    ser.write(str.encode(command))
    while ser.readline() != b'ok\n':
        pass
    # sleep(2)  # for testing


while True:
    if len(mqtt.cmds) != 0:
        vid: str = mqtt.cmds[0]
        start: float = timer()
        cmds: list = create_recipe(mqtt.cmds)
        for i in range(3):
            sendSerialCommand(ser, cmds[i].replace('\n', '') + '\r\n')
        for i in range(3, len(cmds)):
            sendSerialCommand(ser, cmds[i].replace('\n', '') + '\r\n')
            while mqtt.pause:
                pass
            # If shutdown command encounters
            if cmds[i] == "Shutdown":
                mqtt.client.publish(mqtt.MQTT_TOPIC_SEND,
                                    'Done', qos=1, retain=True)
                end: float = timer()
                total: float = end - start
                db.collection("variants").document(
                    vid).update({"cookingTime": str(int(total))})
                system("sudo shutdown now")
            # End of If shutdown command encounters
        mqtt.client.publish(mqtt.MQTT_TOPIC_SEND, "Done", qos=1, retain=True)
        end: float = timer()
        total: float = end - start  # calculating total time for cooking
        db.collection("variants").document(
            vid).update({"cookingTime": str(int(total))})
        print(total)
        mqtt.cmds = []
