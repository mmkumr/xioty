"""Program for finding last X and Y points."""

x = 0
y = 0


def lastPoint(cmds):
    """
    For getting last x and y points
    """
    global x, y
    for cmd in cmds:
        datas = cmd.split()
        if len(datas) > 0:
            if datas[0] == "G0" or datas[0] == "G1":
                for data in datas:
                    if data[0] == "X":
                        x = float(data[1:])
                    elif data[0] == "Y":
                        y = float(data[1:])
    return x, y
