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
#include <QThread>
#include <QQuickWindow>
#include <QSGRendererInterface>
#include <iostream>
#include <sstream>

int main(int argc,char* argv[]){
    QApplication app(argc,argv);
    app.setWindowIcon(QIcon(":/media/logo/uq-l-bg.png"));

    // 检测是否为加载主题后的自动重启实例（此时旧实例可能尚未完全退出共享内存，需跳过 AlreadyExists 拦截但仍需持有共享内存）
    bool isRestarting = QCoreApplication::arguments().contains("--restarting");
    QString sharedMemoryKey = "Uniquenium_SingleInstance_Key";
    QSharedMemory sharedMemory;
    sharedMemory.setKey(sharedMemoryKey);

    if (isRestarting) {
        // 重启场景：旧实例可能尚未退出，循环等待并重试 create，成功后本实例持有共享内存
        // 这样后续用户双开时会被本实例拦截
        for (int i = 0; i < 30; ++i) {
            if (sharedMemory.create(1)) {
                break;
            }
            if (sharedMemory.error() != QSharedMemory::AlreadyExists) {
                break; // 其他错误，放弃但继续启动
            }
            QThread::msleep(100); // 旧实例还活着，等 100ms 重试
        }
        // 无论是否 create 成功都继续启动（重启场景不阻塞自己）
    } else {
        // 正常场景：防多开检查
        if (!sharedMemory.create(1)) {
            if (sharedMemory.error() == QSharedMemory::AlreadyExists) {
                QMessageBox::information(nullptr, "Uniquenium", "Uniquenium is already running!");
                return 0;
            }
        }
    }
    std::ostringstream* oss = new std::ostringstream();
    std::cout.rdbuf(oss->rdbuf());
    std::cerr.rdbuf(oss->rdbuf());
    QQmlApplicationEngine engine;
    qRegisterMetaType<std::ostringstream*>("std::ostringstream*");
    engine.rootContext()->setContextProperty("QQMLENGINE", &engine);
    engine.rootContext()->setContextProperty("OUTPUT", QVariant::fromValue(oss));
    engine.addImportPath(QCoreApplication::applicationDirPath()+"/temp");
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    engine.load(url);
    if (engine.rootObjects().isEmpty())
        return -1;
    QString graphicsApiUsed = "";
    switch (QQuickWindow::graphicsApi()) {
    case QSGRendererInterface::Unknown:
        graphicsApiUsed = "Unknown";
        break;
    case QSGRendererInterface::Software:
        graphicsApiUsed = "Software Rendering";
        break;
    case QSGRendererInterface::OpenGL:
        graphicsApiUsed = "OpenGL Rendering";
        break;
    case QSGRendererInterface::Vulkan:
        graphicsApiUsed = "Vulkan Rendering";
        break;
    case QSGRendererInterface::Direct3D11:
        graphicsApiUsed = "Direct3D11 Rendering";
        break;
    case QSGRendererInterface::Direct3D12:
        graphicsApiUsed = "Direct3D12 Rendering";
        break;
    default:
        graphicsApiUsed = "Unknown";
    }
    qDebug() << "Using graphical API: " << graphicsApiUsed;
    qDebug()<<"Application Launched Successfully.";
    return app.exec();
}

#include "launcher.moc"
