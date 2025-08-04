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
    def systemFontFamilies(self):
        return QFontDatabase.families()

    @Slot(str,result=int)
    def fontIndex(self,familyName):
        return QFontDatabase.families().index(familyName)




