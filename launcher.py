import sys
import os
import UniDesk

from main import updRes
from main import res

from UniDeskPlugin.UniDeskBases import UniDeskBase,UniDeskWindowBase
from UniDeskPlugin.UniDeskData import UniDeskSettings,UniDeskComponentsData
from UniDeskPlugin.UniDeskDefines import UniDeskDefines
from UniDeskPlugin.UniDeskTextStyle import UniDeskTextStyle
from UniDeskPlugin.UniDeskGlobals import UniDeskGlobals
from UniDeskPlugin.UniDeskTools import UniDeskTools

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
    app.setWindowIcon(QIcon(":/media/logo/uq-l-bg.png"))
    qmlRegisterType(UniDeskBase,"org.uniquenium.unidesk",1,0,"UniDeskBase")
    qmlRegisterType(UniDeskWindowBase,"org.uniquenium.unidesk",1,0,"UniDeskWindowBase")
    qmlRegisterSingletonType(UniDeskSettings,"org.uniquenium.unidesk",1,0,"UniDeskSettings")
    qmlRegisterSingletonType(UniDeskComponentsData,"org.uniquenium.unidesk",1,0,"UniDeskComponentsData")
    qmlRegisterSingletonType(UniDeskDefines,"org.uniquenium.unidesk",1,0,"UniDeskDefines")
    qmlRegisterSingletonType(UniDeskTextStyle,"org.uniquenium.unidesk",1,0,"UniDeskTextStyle")
    qmlRegisterSingletonType(UniDeskGlobals,"org.uniquenium.unidesk",1,0,"UniDeskGlobals")
    qmlRegisterSingletonType(UniDeskTools,"org.uniquenium.unidesk",1,0,"UniDeskTools")
    engine = QQmlApplicationEngine()
    engine.addImportPath(os.getcwd())
    engine.load("./main/main.qml")
    if not engine.rootObjects():
        sys.exit(-1)
    print("Application Launched Successfully.")
    UniDeskGlobals.startThread()
    sys.exit(app.exec())
