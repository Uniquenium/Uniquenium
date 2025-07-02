import sys
import os
import unidesk_qml

from main import updRes
from main import res
from main.UniDeskBase import UniDeskBase
from main.UniDeskData import UniDeskSettingsData
from main.UniDeskUnits import UniDeskUnits

from PySide6.QtGui import *
from PySide6.QtQml import *
from PySide6.QtQuick import *
from PySide6.QtCore import *

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    qmlRegisterType(UniDeskBase,"org.itcdt.unidesk",1,0,"UniDeskBase")
    qmlRegisterSingletonType(UniDeskUnits,"org.itcdt.unidesk",1,0,"UniDeskUnits")
    engine = QQmlApplicationEngine()
    engine.addImportPath(os.getcwd())
    engine.load("qrc:/main/main.qml")
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
