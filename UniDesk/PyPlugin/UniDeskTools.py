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
from .UniDeskData import UniDeskSettings
from .UniDeskDefines import UniDeskDefines
import requests
user32 = ctypes.WinDLL('user32')
SM_CONTRAST = 221
SM_USERCOLORSET = 263

class UniDeskTools(QQuickItem):
    customFontsChanged = Signal()
    def __init__(self):
        global th
        super().__init__()
        self.familyPaths=UniDeskSettings.get("customFontFamilyPaths")
        self.appFonts=[QFontDatabase.addApplicationFont(i) for i in self.familyPaths if os.path.exists(i)]
    @Slot(QColor,QColor,QColor,QColor,bool,bool,bool,result=QColor)
    def switchColor(self,normal,hover,press,disable,hovered,pressed,disabled):
        if disabled:
            return disable
        elif pressed:
            return press
        elif hovered:
            return hover
        else:
            return normal
    
    @Slot(str)
    def systemCommand(self,command):
        os.system(command)
        
    @Slot(str,int,result=QFont)
    def font(self,family,size):
        f=QFont()
        if family=="":
            family="微软雅黑"
        f.setFamily(family)
        f.setPixelSize(size)
        return f
    
    @Slot(result=bool)
    def isSystemColorLight(self):
        return darkdetect.isLight()
    
    @Slot(str)
    def web_browse(self,url):
        os.system("start "+url)

    @Slot(bool)
    def setTaskbarVisible(self,vis):
        hwnd = ctypes.windll.user32.FindWindowW("Shell_TrayWnd", None)
        ctypes.windll.user32.ShowWindow(hwnd, 5 if vis else 0)
    
    @Slot(result=QUrl)
    def get_wallpaper(self):
        key = winreg.OpenKey(winreg.HKEY_CURRENT_USER,
                            r'Control Panel\Desktop')
        wallpaper_path, _ = winreg.QueryValueEx(key, "Wallpaper")
        return QUrl.fromLocalFile(wallpaper_path)
    
    @Slot(QQuickWindow,result=QRect)
    def desktopGeometry(self,window: QQuickWindow):
        return window.screen().geometry()

    @Slot(QUrl)
    def set_wallpaper(self,path: QUrl):
        path = path.toLocalFile()
        # 修改注册表
        key = winreg.OpenKey(
            winreg.HKEY_CURRENT_USER,
            r"Control Panel\Desktop",
            0,
            winreg.KEY_SET_VALUE
        )
        winreg.SetValueEx(key, "Wallpaper", 0, winreg.REG_SZ, str(path))
        winreg.CloseKey(key)
        # 通知系统刷新壁纸
        ctypes.windll.user32.SystemParametersInfoW(
            0x0014,  # SPI_SETDESKWALLPAPER
            0,
            str(path),
            0x01 | 0x02 | 0x04
        )
        
    
    @Slot(str,result=QUrl)
    def fromLocalFile(self,path):
        return QUrl.fromLocalFile(path)
    
    @Slot(result=list)
    def applicationFontFamilies(self):
        return QFontDatabase.families()+[QFontDatabase.applicationFontFamilies(i)[0] for i in self.appFonts]

    @Slot(str,result=int)
    def fontIndex(self,familyName):
        try:
            return self.applicationFontFamilies().index(familyName)
        except ValueError:
            return -1
    @Slot(str)
    def addFontFamily(self,path):
        id=QFontDatabase.addApplicationFont(path)
        self.appFonts.append(id)
        self.customFontsChanged.emit()
        self.familyPaths.append(path)
        UniDeskSettings.set("customFontFamilyPaths",self.familyPaths)
    
    @Slot(str)
    def removeFontFamily(self,id):
        id=int(id)
        QFontDatabase.removeApplicationFont(id)
        self.familyPaths.pop(self.appFonts.index(id))
        self.appFonts.remove(id)
        self.customFontsChanged.emit()
        UniDeskSettings.set("customFontFamilyPaths",self.familyPaths)

    @Slot(result=list)
    def getCustomFonts(self):
        return [[i,QFontDatabase.applicationFontFamilies(i)[0]] for i in self.appFonts]
    
    @Slot(QUrl,result=bool)
    def isValidUrl(self,url: QUrl):
        return url.isValid()

    def apiRequest(reqType: UniDeskDefines.ApiRequestType,url,data,timeout):
        if reqType==UniDeskDefines.ApiRequestType.ApiTypeGet:
            response=requests.get(url,data=data,timeout=timeout)
        if reqType==UniDeskDefines.ApiRequestType.ApiTypePost:
            response=requests.post(url,data=data,timeout=timeout)
        return response.json()
        

