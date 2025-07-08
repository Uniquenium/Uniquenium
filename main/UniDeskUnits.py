from PySide6.QtGui import *
from PySide6.QtQml import *
from PySide6.QtQuick import *
from PySide6.QtCore import *

class UniDeskUnits(QQuickItem):
    props=[
        ["tiny","QFont"],
        ["little","QFont"],
        ["littleStrong","QFont"],
        ["small","QFont"],
        ["medium","QFont"],
        ["large","QFont"],
        ["huge","QFont"],
    ]
    for i in props:
        exec("%sChanged=Signal(%s)"%(i[0],i[1]))
        exec("%s=Property(%s,fget=lambda self: self.__getattribute__(\"_%s\"),notify=%sChanged)"%(i[0],i[1],i[0],i[0]))
    def __init__(self):
        super().__init__()
        _family="微软雅黑"
        self._tiny=QFont()
        self._tiny.setFamily(_family)
        self._tiny.setPixelSize(12)

        self._little=QFont()
        self._little.setFamily(_family)
        self._little.setPixelSize(13)

        self._littleStrong=QFont()
        self._littleStrong.setFamily(_family)
        self._littleStrong.setPixelSize(13)
        self._littleStrong.setWeight(QFont.Weight.DemiBold)

        self._small=QFont()
        self._small.setFamily(_family)
        self._small.setPixelSize(20)
        self._small.setWeight(QFont.Weight.DemiBold)

        self._medium=QFont()
        self._medium.setFamily(_family)
        self._medium.setPixelSize(28)
        self._medium.setWeight(QFont.Weight.DemiBold)

        self._large=QFont()
        self._large.setFamily(_family)
        self._large.setPixelSize(40)
        self._large.setWeight(QFont.Weight.DemiBold)

        self._huge=QFont()
        self._huge.setFamily(_family)
        self._huge.setPixelSize(68)
        self._huge.setWeight(QFont.Weight.DemiBold)
        


