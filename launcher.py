import sys
import os
import UniDesk

from main import updRes
from main import res
from main.UniDeskBases import UniDeskBase,UniDeskWindowBase
from main.UniDeskData import UniDeskSettings
from main.UniDeskUnits import UniDeskUnits
from main.UniDeskGlobals import UniDeskGlobals
from main.UniDeskTools import UniDeskTools

from PySide6.QtGui import *
from PySide6.QtQml import *
from PySide6.QtQuick import *
from PySide6.QtCore import *

try:
    from ctypes import windll
    windll.shell32.SetCurrentProcessExplicitAppUserModelID('org.lingmo.webbrowser')
except ImportError:
    pass

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    app.setWindowIcon(QIcon(":/media/logo/unidesk-l.png"))
    qmlRegisterType(UniDeskBase,"org.uniquenium.unidesk",1,0,"UniDeskBase")
    qmlRegisterType(UniDeskWindowBase,"org.uniquenium.unidesk",1,0,"UniDeskWindowBase")
    qmlRegisterSingletonType(UniDeskSettings,"org.uniquenium.unidesk",1,0,"UniDeskSettings")
    qmlRegisterSingletonType(UniDeskUnits,"org.uniquenium.unidesk",1,0,"UniDeskUnits")
    qmlRegisterSingletonType(UniDeskGlobals,"org.uniquenium.unidesk",1,0,"UniDeskGlobals")
    qmlRegisterSingletonType(UniDeskTools,"org.uniquenium.unidesk",1,0,"UniDeskTools")
    engine = QQmlApplicationEngine()
    engine.addImportPath(os.getcwd())
    engine.load("qrc:/main/main.qml")
    if not engine.rootObjects():
        sys.exit(-1)
    print("Application Launched Successfully.")
    UniDeskGlobals.startThread()
    sys.exit(app.exec())
