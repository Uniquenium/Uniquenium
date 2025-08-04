from PySide6.QtGui import *
from PySide6.QtQml import *
from PySide6.QtQuick import *
from PySide6.QtCore import *

class UniDeskDefines(QQuickItem):
    props=[
        [
            "ColorModeLight",
            "ColorModeDark",
            "ColorModeSystem",
        ]
    ]
    for prop in props:
        for i,j in enumerate(prop):
            exec("%s=Property(int,fget=lambda self: self.__getattribute__(\"_%s\"),notify=False)"%(j,j))
    def __init__(self):
        for prop in self.props:
            for i,j in enumerate(prop):
                exec("_%s=%s"%(j,i))
        super().__init__()