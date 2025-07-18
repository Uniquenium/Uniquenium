from PySide6.QtGui import *
from PySide6.QtQml import *
from PySide6.QtQuick import *
from PySide6.QtCore import *
import darkdetect
import os
import ctypes
from ctypes import wintypes
import winreg
user32 = ctypes.WinDLL('user32')
SM_CONTRAST = 221
SM_USERCOLORSET = 263

class UniDeskTools(QQuickItem):
    def __init__(self):
        super().__init__()

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
        path=path.toLocalFile()
        print(path)
        ctypes.windll.user32.SystemParametersInfoW(20, 0, path, 0x01 | 0x02)




