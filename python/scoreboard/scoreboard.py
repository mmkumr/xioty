"""Scoreboard """
from tkinter import Tk, StringVar, Label, Frame, Entry, TOP, LEFT,\
        RIGHT, BOTTOM
import tkinter.font
import pyrebase

firebaseConfig = {
    "apiKey": "AIzaSyCMbSrK8X7dK-SyjtAYFNK9IZxcWH3DpeQ",
    "authDomain": "scoreboard-15682.firebaseapp.com",
    "databaseURL": "https://scoreboard-15682-default-rtdb.asia-southeast1.firebasedatabase.app",
    "projectId": "scoreboard-15682",
    "storageBucket": "scoreboard-15682.appspot.com",
    "messagingSenderId": "467766974836",
    "appId": "1:467766974836:web:6dd80ca2e44a4960b53421",
    "measurementId": "G-SQ6GCWZWXR"
}

firebase = pyrebase.initialize_app(firebaseConfig)

db = firebase.database()

win = Tk()
win.title("Basketball Scoreboard")
# getting width and height - overflow
# w, h = win.winfo_screenwidth(), win.winfo_screenheight() - 70
# set size of window as per width and heigth
# win.geometry("%dx%d+0+0" % (w, h))
win.attributes('-fullscreen', True)
myFont = tkinter.font.Font(family='Helvetica', size=50, weight="bold")
periodFont = tkinter.font.Font(family='Helvetica', size=50, weight="bold")
scoreFont = tkinter.font.Font(family='Helvetica', size=90, weight="bold")
# variable of the number which is shown in level text label.
pnum = 1
name1 = StringVar()
name2 = StringVar()
# defined this frame to position team frames to top
tf = Frame(win)
tf.pack(side=TOP)
# pack_propagate(0) to tell frame not to let its children control its size
# top side widgets
Name1Frame = Frame(tf, bg="red", width=win.winfo_screenwidth() * 0.37,
                   height=win.winfo_screenheight() * 1/4)
Name1Frame.pack(expand=True, fill='both', side=LEFT)
Name1Frame.pack_propagate(0)
VSFrame = Frame(tf, bg="white", width=win.winfo_screenwidth() * 0.26)
VSFrame.pack(expand=True, fill='both', side=LEFT)
VSFrame.pack_propagate(0)
Name2Frame = Frame(tf, bg="blue", width=win.winfo_screenwidth() * 0.37)
Name2Frame.pack(expand=True, fill='both', side=RIGHT)
Name2Frame.pack_propagate(0)
# bottom side widgets
Score1Frame = Frame(win, bg="black", width=win.winfo_screenwidth() * 0.37,
                    height=win.winfo_screenheight() * 3/4)
Score1Frame.pack(expand=True, fill='both', side=LEFT)
Score1Frame.pack_propagate(0)
PeriodFrame = Frame(win, bg="black", width=win.winfo_screenwidth() * 0.26,
                    height=win.winfo_screenheight() * 1/2)
PeriodFrame.pack(expand=True, fill='both', side=LEFT)
PeriodFrame.pack_propagate(0)
Score2Frame = Frame(win, bg="black", width=win.winfo_screenwidth() * 0.37)
Score2Frame.pack(expand=True, fill='both', side=RIGHT)
Score2Frame.pack_propagate(0)

def score1(event):
    """callback function for increment or decrement the score of team1 with the
    help of mouse click event handler."""
    # cget("text") is used for getting the text property of the text label.
    if event.num == 1:
        if int(Score1.cget("text")) > 0:
            Score1.config(text=str(int(Score1.cget("text")) - 1))
            db.child("data").update({"score1": Score1.cget("text")})
    elif event.num == 3:
        Score1.config(text=str(int(Score1.cget("text")) + 1))
        db.child("data").update({"score1": Score1.cget("text")})


def score2(event):
    """callback function for increment or decrement the score of team1 with the
    help of mouse click event handler."""
    if event.num == 1:
        if int(Score2.cget("text")) > 0:
            Score2.config(text=str(int(Score2.cget("text")) - 1))
            db.child("data").update({"score2": Score2.cget("text")})
    elif event.num == 3:
        Score2.config(text=str(int(Score2.cget("text")) + 1))
        db.child("data").update({"score2": score2.cget("text")})


def period(event):
    """callback function for incrementing or decrementing the pnum variable,
    which is shown in the period text label by combining with level string.
    With the help of mouse click event handler."""
    global pnum
    if event.num == 1:
        if pnum > 1:
            pnum -= 1
            Period.config(text="PERIOD\n" + str(pnum))
            db.child("data").update({"period": str(pnum)})
    elif event.num == 3:
        if pnum < 9:
            pnum += 1
            Period.config(text="PERIOD\n" + str(pnum))
            db.child("data").update({"period": str(pnum)})


# Top left Team1 textbox
Team1name = Entry(Name1Frame, font=myFont, width=5, bg="red", fg="white",
                  justify="center", textvariable=name1)
Team1name.pack(expand=True)
# Top center text label
VS = Label(VSFrame, text="V/S", bg="white", font=myFont)
VS.pack(expand=True, fill='x')
# Top right Team2 textbox
Team2name = Entry(Name2Frame, font=myFont, width=5, bg="blue", fg="white",
                  justify="center", textvariable=name2)
Team2name.pack(expand=True)
# Bottom left score of team1 text label attached with
# mouse click event for increment and decrement
Score1 = Label(Score1Frame, text="00", bg="black", fg="white", font=scoreFont)
Score1.bind("<Button>", score1)
Score1.pack(expand=True, fill='x')
# Bottom center period of the game text label attached with
# mouse click event for increment and decrement
Period = Label(PeriodFrame, text="PERIOD\n" + str(pnum), bg="#5e9dff",
               fg="black", font=periodFont)
Period.bind("<Button>", period)
Period.pack(side=TOP, fill='both')
# Bottom center divider under period text label. It's just a blank text label.
Blank = Label(PeriodFrame, text="", bg="#5e9dff", fg="black", font=periodFont)
Blank.pack(expand=True, fill='y', side=BOTTOM)
# Bottom right score of team2 text label attached with
# mouse click event for increment and decrement
Score2 = Label(Score2Frame, text="00", bg="black", fg="white", font=scoreFont)
Score2.bind("<Button>", score2)
Score2.pack(expand=True, fill='x')


# AutoCapitalizing the Team names.
def autocapitalize1(*args):
    """AutoCapitalizing the Team1 name in realtime"""
    name1.set(name1.get().upper())


def autocapitalize2(*args):
    """AutoCapitalizing the Team2 name in realtime"""
    name2.set(name2.get().upper())


# Writing values capitalized name to team text input variables.
name1.trace("w", autocapitalize1)
name2.trace("w", autocapitalize2)


# Continues running the code of the app.
def stream_handler(message):
    """Callback function for data parent change"""
    global pnum
    # print(message["event"])
    if (str(message["path"]) == "/" and len(message["data"]) != 1):
        pnum = int(message["data"]["period"])
        Period.config(text="PERIOD\n" + str(pnum))
        name1.set(message["data"]["player1"])
        name2.set(message["data"]["player2"])
        Score1.config(text=str(message["data"]["score1"]))
        Score2.config(text=str(message["data"]["score2"]))
    elif str(message["path"]) == "/" and len(message["data"]) == 1:
        if "period" in message["data"]:
            pnum = int(message["data"]["period"])
            Period.config(text="PERIOD\n" + str(pnum))
        elif "player1" in message["data"]:
            name1.set(message["data"]["player1"])
        elif "player2" in message["data"]:
            name2.set(message["data"]["player2"])
        elif "score1" in message["data"]:
            Score1.config(text=str(message["data"]["score1"]))
        elif "score2" in message["data"]:
            Score2.config(text=str(message["data"]["score2"]))


db.child("data").stream(stream_handler)
win.mainloop()
