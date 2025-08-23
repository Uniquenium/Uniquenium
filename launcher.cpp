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

namespace py = pybind11;

int main(int argc,char* argv[]){
    QGuiApplication app(argc,argv);
    app.setWindowIcon(QIcon(":/media/logo/uq-l-bg.png"));
    py::scoped_interpreter guard{}; // Start the Python interpreter
    py::exec(R"(
        print("Python Interpreter Initialized.")
    )");
    // py::module_ UniDeskBases = py::module_::import("temp.UniDesk.PyPlugin.UniDeskBases");
    // py::object UniDeskBase = UniDeskBases.attr("UniDeskBase");
    // qDebug()<<typeid(UniDeskBases).name();
    QQmlApplicationEngine engine;
    engine.addImportPath(QDir::currentPath()+"/temp");
    const QUrl url(QStringLiteral("qrc:/main/main.qml"));
    engine.load(url);
    if (engine.rootObjects().isEmpty())
        return -1;
    qDebug()<<"Application Launched Successfully.";
    // py::exec(R"(
    //     UniDeskGlobals.startThread()
    //     UniDeskComponentsData.startFuncs()
    // )");
    return app.exec();
}

#include "launcher.moc"
