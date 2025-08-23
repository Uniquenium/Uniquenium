import sys
import os
import UniDesk.Controls

from main import updRes
from legacy import res

from UniDesk.PyPlugin.UniDeskBases import UniDesk.ControlsBase,UniDeskWindowBase,UniDeskTreeModel
from UniDesk.PyPlugin.UniDeskData import UniDesk.ControlsSettings,UniDeskComponentsData
from UniDesk.PyPlugin.UniDeskDefines import UniDesk.ControlsDefines
from UniDesk.PyPlugin.UniDeskTextStyle import UniDesk.ControlsTextStyle
from UniDesk.PyPlugin.UniDeskGlobals import UniDesk.ControlsGlobals
from UniDesk.PyPlugin.UniDeskTools import UniDesk.ControlsTools

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
    qmlRegisterType(UniDeskBase,"UniDesk.PyPlugin",1,0,"UniDeskBase")
    qmlRegisterType(UniDeskWindowBase,"UniDesk.PyPlugin",1,0,"UniDeskWindowBase")
    qmlRegisterType(UniDeskTreeModel,"UniDesk.PyPlugin",1,0,"UniDeskTreeModel")
    qmlRegisterSingletonType(UniDeskSettings,"UniDesk.PyPlugin",1,0,"UniDeskSettings")
    qmlRegisterSingletonType(UniDeskComponentsData,"UniDesk.PyPlugin",1,0,"UniDeskComponentsData")
    qmlRegisterSingletonType(UniDeskDefines,"UniDesk.PyPlugin",1,0,"UniDeskDefines")
    qmlRegisterSingletonType(UniDeskTextStyle,"UniDesk.PyPlugin",1,0,"UniDeskTextStyle")
    qmlRegisterSingletonType(UniDeskGlobals,"UniDesk.PyPlugin",1,0,"UniDeskGlobals")
    qmlRegisterSingletonType(UniDeskTools,"UniDesk.PyPlugin",1,0,"UniDeskTools")
    UniDeskComponentsData.loadComponentPyPlugins()
    engine = QQmlApplicationEngine()
    engine.addImportPath(os.getcwd())
    engine.load("./main/main.qml")
    if not engine.rootObjects():
        sys.exit(-1)
    print("Application Launched Successfully.")
    UniDeskGlobals.startThread()
    UniDeskComponentsData.startFuncs()
    app.exec()