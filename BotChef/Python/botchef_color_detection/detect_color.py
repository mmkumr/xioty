import cv2
import pandas as pd

vid = cv2.VideoCapture(0)

# declaring global variables (are used later on)
r = g = b = 0

x_pos = vid.get(3) / 2
y_pos = vid.get(4) / 2

# Reading csv file with pandas and giving names to each column
index = ["color", "color_name", "hex", "R", "G", "B"]
csv = pd.read_csv('./colors.csv', names=index, header=None)


# function to calculate minimum distance from all colors and get the most
# matching color
def get_color_name(R, G, B):
    minimum = 10000
    for i in range(len(csv)):
        d = abs(R - int(csv.loc[i, "R"])) + abs(G -
                                                int(csv.loc[i, "G"])) + abs(
            B - int(csv.loc[i, "B"]))
        if d <= minimum:
            minimum = d
            cname = csv.loc[i, "color_name"]
    return cname


# cv2.namedWindow('image')
# cv2.setMouseCallback('image', draw_function)

def detect_color():
    ret, img = vid.read()
    b, g, r = img[int(y_pos), int(x_pos)]
    b = int(b)
    g = int(g)
    r = int(r)
    # img = cv2.rectangle(img, (int(x_pos), int(y_pos)),
    #                     (int(x_pos) + 10, int(y_pos) + 10), (255, 0, 0), 5)
    color = get_color_name(r, g, b)
    print(color)
    # cv2.putText(img, text, (50, 50), 2, 0.8, (255, 255, 255), 2, cv2.LINE_AA)
    # cv2.imshow("image", img)
    # For very light colours we will display text in black colour
    if r + g + b >= 600:
        pass
        # cv2.putText(img, text, (50, 50), 2, 0.8, (0, 0, 0), 2, cv2.LINE_AA)
    cv2.destroyAllWindows()
    return color
