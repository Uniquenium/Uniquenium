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
#include <QSharedMemory>
#include <QMessageBox>
#include <UniDeskPluginMgr.h>

int main(int argc,char* argv[]){
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc,argv);
    app.setWindowIcon(QIcon(":/media/logo/uq-l-bg.png"));
    // 防止多开：使用QSharedMemory共享内存检测是否已有实例运行
    QString sharedMemoryKey = "Uniquenium_SingleInstance_Key";
    QSharedMemory sharedMemory;
    sharedMemory.setKey(sharedMemoryKey);
    // 尝试创建共享内存段
    if (!sharedMemory.create(1)) {
        // 创建失败，检查是否因为已有实例占用
        if (sharedMemory.error() == QSharedMemory::AlreadyExists) {
            QMessageBox::information(nullptr, "Uniquenium", "Uniquenium is already running!");
            return 0;
        }
    }
    
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
