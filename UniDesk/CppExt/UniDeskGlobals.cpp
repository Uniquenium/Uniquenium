#include "UniDeskGlobals.h"
#include <QGuiApplication>
#include <QPalette>
#include <QTimer>
#include <QJsonObject>
#include <QQmlEngine>
#include <QJsonArray>
#include <QJsonDocument>
#include <QFile>
#include <QSettings>

static QMap<QString, QVariant> g_config;
static QTimer* themeTimer = nullptr;

UniDeskGlobals::UniDeskGlobals(QQuickItem *parent)
    : QQuickItem(parent)
{
    isLight(true);
    _translator = new QTranslator(this);
    QGuiApplication::installTranslator(_translator);
    QMetaObject::invokeMethod(this, "startListener", Qt::QueuedConnection);
}


static QJsonObject readJsonFile(const QString &file) {
    QFile f(file);
    if (!f.exists()||!f.open(QIODevice::ReadOnly | QIODevice::Text)) return QJsonObject();
    QJsonDocument doc = QJsonDocument::fromJson(f.readAll());
    f.close();
    return doc.object();
}

#ifdef Q_OS_WIN
static bool win10plusIsSystemDarkMode() {
    bool dark = false;
    QSettings reg("HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize",
                  QSettings::NativeFormat);
    QVariant appsUseLightTheme = reg.value("AppsUseLightTheme");
    QVariant systemUsesLightTheme = reg.value("SystemUsesLightTheme");
    if (appsUseLightTheme.isValid()) {
        dark = (appsUseLightTheme.toInt() == 0);
    } else if (systemUsesLightTheme.isValid()) {
        dark = (systemUsesLightTheme.toInt() == 0);
    } else {
        return true;
    }
    return !dark;
}
#endif

void UniDeskGlobals::updateIsLight() {
    QJsonObject obj = readJsonFile(QGuiApplication::applicationDirPath() + "/data/settings.json");
    int colorMode = obj.value("appearance.colorMode").toInt(2);
    bool newIsLight = true;
    if (colorMode == 0) {
        newIsLight = true;
    } else if (colorMode == 1) {
        newIsLight = false;
    } else {
#ifdef Q_OS_WIN
        newIsLight = win10plusIsSystemDarkMode();
#else
        QPalette pal = QGuiApplication::palette();
        newIsLight = pal.color(QPalette::Window).lightness() > 128;
#endif
    }
    if (newIsLight != isLight()) {
        isLight(newIsLight);
    }
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
    updateIsLight();
    startThread();
}

void UniDeskGlobals::translate(QObject* object, QString locale) {
    QQmlEngine* _engine = qmlEngine(object);
    bool p=_translator->load(":/uniquenium/i18n/uniquenium_" + locale);
    if(p){
        _engine->retranslate();
    }
}