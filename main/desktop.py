import sys
import os
import updRes
import res

from ..pyunidesk.UniDeskBase import UniDeskBase
from ..pyunidesk.UniDeskData import UniDeskSettingsData

from PySide6.QtGui import *
from PySide6.QtQml import *
from PySide6.QtQuick import *
from PySide6.QtCore import *

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    engine.load("qrc:/main/main.qml")
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
