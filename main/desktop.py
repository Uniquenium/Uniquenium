import sys
import os
from handlers import *
import updRes
import LingmoUIPy
import res

if __name__ == "__main__":
    os.environ["QTWEBENGINE_REMOTE_DEBUGGING"] = "1112"
    scheme = QWebEngineUrlScheme(QByteArray("browser"))
    scheme.setSyntax(QWebEngineUrlScheme.Syntax.HostAndPort)
    scheme.setDefaultPort(2345)
    scheme.setFlags(QWebEngineUrlScheme.Flag.SecureScheme)
    QWebEngineUrlScheme.registerScheme(scheme)
    QtWebEngineQuick.initialize()
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    engine.load("qrc:/main/main.qml")
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
