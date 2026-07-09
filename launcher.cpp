#include <QApplication>
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
#include <UniDeskPluginMgr.h>

int main(int argc,char* argv[]){
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc,argv);
    app.setWindowIcon(QIcon(":/media/logo/uq-l-bg.png"));
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("QQMLENGINE", &engine);
    engine.addImportPath(QDir::currentPath()+"/temp");
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    engine.load(url);
    if (engine.rootObjects().isEmpty())
        return -1;
    qDebug()<<"Application Launched Successfully.";
    return app.exec();
}

#include "launcher.moc"
