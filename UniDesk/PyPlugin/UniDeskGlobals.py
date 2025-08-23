from PySide6.QtGui import *
from PySide6.QtQml import *
from PySide6.QtQuick import *
from PySide6.QtCore import *
from .UniDeskData import UniDesk.ControlsSettings
import darkdetect
import threading

th=None

class UniDeskGlobals(QQuickItem):
    applicationQuit=Signal()
    props=[
        ["isLight","bool"]
    ]
    for i in props:
        exec("%sChanged=Signal(%s)"%(i[0],i[1]))
        exec("%s=Property(%s,fget=lambda self: self.__getattribute__(\"_%s\"),fset=lambda self,val: self.__setattr__(\"_%s\",val),notify=%sChanged)"%(i[0],i[1],i[0],i[0],i[0]))
    def __init__(self):
        global th
        super().__init__()
        self._isLight=True
        self._component_list=[]
        self.updateIsLight(None)
        th=threading.Thread(target=self.startListener,daemon=True)
    def startThread():
        global th
        th.start()
    def startListener(self):
        darkdetect.listener(self.updateIsLight)
    @Slot(int)
    def updateIsLight(self,val):
        colorMode=UniDeskSettings.get("colorMode")
        prev=self._isLight
        if colorMode==0:
            self._isLight=True
        elif colorMode==1:
            self._isLight=False
        else:
            self._isLight=darkdetect.isLight() 
        if prev!=self._isLight:
            self.isLightChanged.emit(self._isLight)
    @Slot()
    def emitApplicationQuit(self):
        self.applicationQuit.emit()
