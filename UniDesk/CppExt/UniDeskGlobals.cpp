#include "UniDeskGlobals.h"
#include <QGuiApplication>
#include <QPalette>
#include <QTimer>
#include <QJsonObject>
#include <QQmlEngine>
#include <QJsonArray>
#include <QFile>

static QMap<QString, QVariant> g_config;
static QTimer* themeTimer = nullptr;

UniDeskGlobals::UniDeskGlobals(QQuickItem *parent)
    : QQuickItem(parent)
{
    isLight(true);
    _translator = new QTranslator(this);
    QGuiApplication::installTranslator(_translator);
}


static QJsonObject readJsonFile(const QString &file) {
    QFile f(file);
    if (!f.exists()||!f.open(QIODevice::ReadOnly | QIODevice::Text)) return QJsonObject();
    QJsonDocument doc = QJsonDocument::fromJson(f.readAll());
    f.close();
    return doc.object();
}

void UniDeskGlobals::updateIsLight() {
    QJsonObject obj = readJsonFile(QGuiApplication::applicationDirPath() + "/data/settings.json");
    int colorMode = obj.value("appearance.colorMode").toInt(2);
    bool newIsLight = true;
    if (colorMode == 0) {
        newIsLight = true;
    } else if (colorMode == 1) {
        newIsLight = false;
    } else {
        QPalette pal = QGuiApplication::palette();
        newIsLight = pal.color(QPalette::Window).lightness() > 128;
    }
    isLight(newIsLight);
}

void UniDeskGlobals::emitApplicationQuit() {
    emit applicationQuit();
    QCoreApplication::exit(0);//force the application to quit
}

void UniDeskGlobals::startThread() {
    if (themeTimer) return;
    themeTimer = new QTimer(this);
    connect(themeTimer, &QTimer::timeout, this, [this]() {
        updateIsLight();
    });
    themeTimer->start(1000); // 每秒检测一次主题变化
}

void UniDeskGlobals::startListener() {
    startThread();
}

void UniDeskGlobals::translate(QObject* object, QString locale) {
    QQmlEngine* _engine = qmlEngine(object);
    bool p=_translator->load(":/uniquenium/i18n/uniquenium_" + locale);
    if(p){
        _engine->retranslate();
    }
}