from PySide6.QtGui import *
from PySide6.QtQml import *
from PySide6.QtQuick import *
from PySide6.QtCore import *

class UniDeskBase(QQuickWindow):
    focusOut=Signal()
    def __init__(self):
        super().__init__()
        self.setFlag(Qt.WindowType.FramelessWindowHint,True)
        self.setFlag(Qt.WindowType.WindowStaysOnBottomHint,True)
        self.setFlag(Qt.WindowType.Tool,True)
    def focusOutEvent(self, arg__1):
        self.focusOut.emit()
        return super().focusOutEvent(arg__1)
    