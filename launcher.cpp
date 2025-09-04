#include <pybind11/embed.h>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QUrl>
#include <QIcon>
#include <QQmlComponent>
#include <QQuickStyle>
#include <qqml.h>
#include <QQuickItem>
#include <QDebug>
#include <QDir>
#include <UniDeskGlobals.h>
#include <UniDeskComponentsData.h>

namespace py = pybind11;

int main(int argc,char* argv[]){
    QGuiApplication app(argc,argv);
    app.setWindowIcon(QIcon(":/media/logo/uq-l-bg.png"));
    py::scoped_interpreter guard{}; // Start the Python interpreter
    QQmlApplicationEngine engine;
    engine.addImportPath(QDir::currentPath()+"/temp");
    const QUrl url(QStringLiteral("qrc:/main/main.qml"));
    engine.load(url);
    if (engine.rootObjects().isEmpty())
        return -1;
    qDebug()<<"Application Launched Successfully.";
    // UniDeskGlobals::getInstance()->startThread();
    // UniDeskComponentsData::getInstance()->startFuncs();
    return app.exec();
}

#include "launcher.moc"
