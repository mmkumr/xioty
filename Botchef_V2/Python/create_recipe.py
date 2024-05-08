'''
This file contains functions for converting list of mqtt commands to list of
Marlin commands.
'''


def create_recipe(mqtt_data: list) -> list:
    '''Converting list of Mqtt commands to list of Marlin commands'''
    recipe: list = []
    file_path: str = ""
    for index, data in enumerate(mqtt_data):
        try:
            if index == 0:
                file_path = ""
            elif data[0:2] == "sm" or data[0:2] == "lm":
                if data[2] == "d":
                    file_path = f"./assets/{data[0]}m/{data[0]}md"
                elif data[2] == "u":
                    num: int = int(data[3]) + 1
                    file_path = f"./assets/{data[0]}m/u/{num}"
            elif data[0] == "M":
                num: int = int(data[1]) + 1
                file_path = f"./assets/M/{num}"
            elif data[0] == "w":
                num: int = int(data[1]) + 1
                file_path = f"./assets/o/w{num}"
            elif data[0] == "o":
                num: int = int(data[1]) + 1
                file_path = f"./assets/o/o{num}"
            elif data[0:2] == "G4" or data == "Shutdown":
                file_path = ""
                recipe = recipe + [data]
            else:
                file_path = f"./assets/o/{data}"
        except FileNotFoundError as e:
            print(f"Invalid command {data}, error: {str(e)}")

        if file_path != "":
            with open(file_path, 'r', encoding="utf-8") as file:
                recipe = recipe + file.readlines()
    return recipe
