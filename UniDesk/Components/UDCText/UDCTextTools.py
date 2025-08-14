from PySide6.QtGui import *
from PySide6.QtQml import *
from PySide6.QtQuick import *
from PySide6.QtCore import *
import darkdetect
import os
import ctypes
from ctypes import wintypes
import winreg
import win32gui
import win32con
import psutil
import datetime
import calendar
import time
import threading
import math
import requests
user32 = ctypes.WinDLL('user32')
SM_CONTRAST = 221
SM_USERCOLORSET = 263


class UDCTextTools(QQuickItem):
    def __init__(self):
        global th
        super().__init__()
        self.cpuPercent=0
        self.bytesSend=0
        self.bytesRecv=0
        self.bytesSendPerSec=0
        self.bytesRecvPerSec=0
        self.dropPercent=0
        self.virtmemTotal=0
        self.virtmemUsed=0
        self.swapmemTotal=0
        self.swapmemUsed=0
        self.virtmemPercent=0
        self.swapmemPercent=0
        th=threading.Thread(target=self.updateData,daemon=True)
    def startThread():
        global th
        th.start()
    def updateData(self):
        while True:
            self.cpuPercent=psutil.cpu_percent()
            bytesSendPrev=self.bytesSend
            bytesRecvPrev=self.bytesRecv
            self.bytesSend=psutil.net_io_counters().bytes_sent
            self.bytesRecv=psutil.net_io_counters().bytes_recv
            self.bytesSendPerSec=self.bytesSend-bytesSendPrev
            self.bytesRecvPerSec=self.bytesRecv-bytesRecvPrev
            self.dropPercent=self.calcDropPercent()
            self.virtmemTotal=psutil.virtual_memory().total
            self.virtmemUsed=psutil.virtual_memory().used
            self.swapmemTotal=psutil.swap_memory().total
            self.swapmemUsed=psutil.swap_memory().used
            self.virtmemPercent=psutil.virtual_memory().percent
            self.swapmemPercent=psutil.swap_memory().percent
            time.sleep(1)
    
    @Slot(str,result=str)
    def convertStr(self,text: str):
        dt=QDateTime.currentDateTime()
        dt2=datetime.datetime.now()
        sensorbattery=psutil.sensors_battery()
        text=text.replace("%%","[(*&*%^*$^%#%%^^&&*^*&(^))]")
        text=text.replace("%isLeapYear",str(calendar.isleap(int(dt.toString("yyyy")))))
        text=text.replace("%yearDays",str(366 if calendar.isleap(int(dt.toString("yyyy")))else 365))
        text=text.replace("%monthDays",str(calendar.monthrange(int(dt.toString("yyyy")),int(dt.toString("M")))[1]))
        text=text.replace("%cpuPercent",str(self.cpuPercent))
        text=text.replace("%bytesSendTotal",str(self.bytesSend))
        text=text.replace("%bytesRecvTotal",str(self.bytesRecv))
        text=text.replace("%bytesSendPerSec",str(self.bytesSendPerSec))
        text=text.replace("%bytesRecvPerSec",str(self.bytesRecvPerSec))
        text=text.replace("%dropPercent",str(self.dropPercent))
        text=text.replace("%virtmemTotal",str(self.virtmemTotal))
        text=text.replace("%virtmemUsed",str(self.virtmemUsed))
        text=text.replace("%swapmemTotal",str(self.swapmemTotal))
        text=text.replace("%swapmemUsed",str(self.swapmemUsed))
        text=text.replace("%virtmemPercent",str(self.virtmemPercent))
        text=text.replace("%swapmemPercent",str(self.swapmemPercent))
        text=text.replace("%dayOfYear",str(dt2.timetuple().tm_yday))
        text=text.replace("%bpercent",str(sensorbattery.percent))
        text=text.replace("%bleftdays",str(sensorbattery.secsleft//86400 if not sensorbattery.power_plugged else "UNLIMITED"))
        text=text.replace("%blefthoursr",str((sensorbattery.secsleft%86400)//6400 if not sensorbattery.power_plugged else "UNLIMITED"))
        text=text.replace("%bleftminsr",str((sensorbattery.secsleft%3600)//60 if not sensorbattery.power_plugged else "UNLIMITED"))
        text=text.replace("%bleftsecsr",str(sensorbattery.secsleft%60 if not sensorbattery.power_plugged else "UNLIMITED"))
        text=text.replace("%blefthours",str(sensorbattery.secsleft//3600 if not sensorbattery.power_plugged else "UNLIMITED"))
        text=text.replace("%bleftmins",str(sensorbattery.secsleft//60 if not sensorbattery.power_plugged else "UNLIMITED"))
        text=text.replace("%bleftsecs",str(sensorbattery.secsleft if not sensorbattery.power_plugged else "UNLIMITED"))
        text=text.replace("%bplug",str(sensorbattery.power_plugged))
        text=text.replace("%yyyy",dt.toString("yyyy"))
        text=text.replace("%yy",dt.toString("yy"))
        text=text.replace("%MMMM",dt.toString("MMMM"))
        text=text.replace("%MMM",dt.toString("MMM"))
        text=text.replace("%MM",dt.toString("MM"))
        text=text.replace("%M",dt.toString("M"))
        text=text.replace("%dddd",dt.toString("dddd"))
        text=text.replace("%ddd",dt.toString("ddd"))
        text=text.replace("%dd",dt.toString("dd"))
        text=text.replace("%d",dt.toString("d"))
        text=text.replace("%hh",dt.toString("hh"))
        text=text.replace("%h",dt.toString("h"))
        text=text.replace("%H",dt2.strftime("%I"))
        text=text.replace("%mm",dt.toString("mm"))
        text=text.replace("%m",dt.toString("m"))
        text=text.replace("%ss",dt.toString("ss"))
        text=text.replace("%s",dt.toString("s"))
        text=text.replace("%zzzzzz",dt2.strftime("%f"))
        text=text.replace("%zzz",dt.toString("zzz"))
        text=text.replace("%z",dt.toString("z"))
        text=text.replace("%U",dt2.strftime("%U"))
        text=text.replace("%W",dt2.strftime("%W"))
        text=text.replace("%j",str(int(dt2.strftime("%j"))))
        text=text.replace("%J",dt2.strftime("%j"))
        text=text.replace("%p",dt.toString("ap"))
        text=text.replace("%P",dt.toString("AP"))
        text=text.replace("%t",dt.toString("t"))
        while text.find("%{")!=-1:
            idx=text.find("%{")
            idx2=text.find("}",idx)
            exp=""
            res=""
            if idx2!=-1:
                exp=text[idx+2:idx2]
                try:
                    res=str(eval(exp))
                except Exception as e:
                    res="ERROR: "+e.args[0]
            else: 
                break
            text=text.replace("%{"+exp+"}",res)
        text=text.replace("[(*&*%^*$^%#%%^^&&*^*&(^))]","%")
        return text
    def calcDropPercent(self):
        io=psutil.net_io_counters()
        try:
            result= (io.dropin+io.dropout)/(io.dropin+io.dropout+io.bytes_recv+io.bytes_sent)
            return result
        except:
            return 0
        
__pluginloadlist__=[
    ("singleton",UDCTextTools,"UDCTextTools",[UDCTextTools.startThread])
]