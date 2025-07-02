from PySide6.QtGui import *
from PySide6.QtQml import *
from PySide6.QtQuick import *
from PySide6.QtCore import *

class UniDeskBase(QQuickWindow):
    def __init__(self):
        super().__init__()
        self.setFlag(Qt.WindowType.FramelessWindowHint,True)
    