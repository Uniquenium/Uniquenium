from PySide6.QtGui import *
from PySide6.QtQml import *
from PySide6.QtQuick import *
from PySide6.QtCore import *
import json
import datetime
import os


data = {
    "./data/settings.json": {

    },
}
for i in data:
    try:
        with open(i, "r", encoding="utf-8") as f:
            data[i] = json.load(f)
    except:
        with open(i, "w", encoding="utf-8") as f:
            json.dump(data[i], f, indent=4)
        with open(i, "r", encoding="utf-8") as f:
            data[i] = json.load(f)


def Data(file, prop):
    return data[file][prop]


def dumpData(file, prop, val):
    data[file][prop] = val
    with open(file, "w", encoding="utf-8") as f:
        json.dump(data[file], f, indent=4)


def DataAll(file):
    return data[file]


def dumpDataAll(file, val):
    data[file] = val
    with open(file, "w", encoding="utf-8") as f:
        json.dump(data[file], f, indent=4)


class UniDeskSettingsData(QQuickItem):
    for i in data["./data/settings.json"]:
        exec(
            i
            + "Changed=Signal(type(Data('../resources/data/settings.json','"
            + i
            + "')))"
        )
        exec(
            i
            + "=Property(type(Data('../resources/data/settings.json','"
            + i
            + "')),(lambda self: Data('../resources/data/settings.json','"
            + i
            + "')),(lambda self,val: dumpData('../resources/data/settings.json','"
            + i
            + "',val)),notify="
            + i
            + "Changed)"
        )

    def __init__(self, parent=None):
        super().__init__(parent)


# class DownloadHistoryData(QQuickItem):
#     downloadHistory: list = Data("../resources/data/downloadHistory.json", "list")

#     def __init__(self, parent=None):
#         super().__init__(parent)

#     @Slot(int, str, result=type)
#     def get(self, index, prop):
#         return self.downloadHistory[index][prop]

#     @Slot(int, str, type)
#     def set(self, index, prop, val):
#         self.downloadHistory[index][prop] = val
#         dumpData("../resources/data/downloadHistory.json", "list", self.downloadHistory)

#     @Slot(str, str, str, str, bool, bool)
#     def append(
#         self, downloadDirectory, downloadFileName, mimeType, url, cancelled, deleted
#     ):
#         self.downloadHistory.append(
#             {
#                 "downloadDirectory": downloadDirectory,
#                 "downloadFileName": downloadFileName,
#                 "mimeType": mimeType,
#                 "url": url,
#                 "cancelled": cancelled,
#                 "deleted": deleted,
#             }
#         )
#         dumpData("../resources/data/downloadHistory.json", "list", self.downloadHistory)

#     @Slot(int)
#     def delete(self, index):
#         self.downloadHistory.pop(index)
#         dumpData("../resources/data/downloadHistory.json", "list", self.downloadHistory)
    
#     @Slot()
#     def clear(self):
#         self.downloadHistory.clear()
#         dumpData("../resources/data/downloadHistory.json", "list", self.downloadHistory)


# class HistoryData(QQuickItem):
#     history: dict = DataAll("../resources/data/history.json")

#     def __init__(self, parent=None):
#         super().__init__(parent)

#     @Slot(str, int, str, result=str)
#     def get(self, date, index, prop):
#         return self.history[date][index][prop]
    
#     @Slot(str, result=str)
#     def getLast(self, prop):
#         if list(self.history.keys())==[]:
#             return None
#         if self.history[list(self.history.keys())[-1]]==[]:
#             return None
#         return self.history[list(self.history.keys())[-1]][-1][prop]
    
#     @Slot(result=list)
#     def getDates(self):
#         return list(self.history.keys())
    
#     @Slot(str, result=list)
#     def getDateList(self, date):
#         return self.history.get(date)

#     @Slot(str, str, str)
#     def append(
#         self, title, favicon, url
#     ):
#         nowdate=datetime.datetime.now().strftime("%Y-%m-%d")
#         if not (nowdate in self.history.keys()):
#             self.history[nowdate]=[]
#         self.history[nowdate].append(
#             {
#                 "title": title,
#                 "favicon": favicon,
#                 "url": url,
#                 "time": datetime.datetime.now().strftime("%H:%M")
#             }
#         )
#         dumpDataAll("../resources/data/history.json", self.history)


#     @Slot(str, str, str)
#     def setLast(
#         self, title, favicon, url
#     ):
#         self.history[list(self.history.keys())[-1]][-1]["title"]=title
#         self.history[list(self.history.keys())[-1]][-1]["favicon"]=favicon
#         self.history[list(self.history.keys())[-1]][-1]["url"]=url
#         dumpDataAll("../resources/data/history.json", self.history)

#     @Slot(str, int)
#     def delete(self, date, index):
#         self.history[date].pop(index)
#         if self.history[date]==[]:
#             self.remove(date)
#         dumpDataAll("../resources/data/history.json", self.history)

#     @Slot(str)
#     def remove(self, date):
#         self.history.pop(date)
#         dumpDataAll("../resources/data/history.json", self.history)

#     @Slot()
#     def clear(self):
#         self.history.clear()
#         dumpDataAll("../resources/data/history.json", self.history)
