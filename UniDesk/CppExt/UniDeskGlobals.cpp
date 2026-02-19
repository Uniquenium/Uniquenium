#include <pybind11/embed.h>
#include "UniDeskGlobals.h"
#include <QGuiApplication>
#include <QPalette>
#include <QTimer>
#include <thread>
#include <QJsonObject>
#include <QJsonArray>
#include <QFile>
namespace py = pybind11;

static QMap<QString, QVariant> g_config;
static std::thread th;

UniDeskGlobals::UniDeskGlobals(QQuickItem *parent)
    : QQuickItem(parent)
{
    isLight(true);

}

static QJsonObject defaultSettings() {
    QJsonObject obj;
    obj["hideTaskbar"] = false;
    obj["colorMode"] = 2;
    QJsonObject color;
    color["<type>"] = "QColor";
    color["red"] = 0;
    color["green"] = 100;
    color["blue"] = 255;
    color["alpha"] = 255;
    obj["primaryColor"] = color;
    obj["globalFontFamily"] = QString::fromUtf8("微软雅黑");
    obj["customFontFamilyPaths"] = QJsonArray();
    return obj;
}
static void writeJsonFile(const QString &file, const QJsonObject &obj) {
    QFile f(file);
    py::exec(R"(
    import os
    if not os.path.exists("./data"):
        os.mkdir("./data")
    )");
    f.open(QIODevice::WriteOnly | QIODevice::Text);
    QJsonDocument doc(obj);
    f.write(doc.toJson(QJsonDocument::Indented));
    f.close();
}
static QJsonObject readJsonFile(const QString &file) {
    QFile f(file);
    if (!f.exists()) {
        QJsonObject obj = defaultSettings();
        writeJsonFile(file, obj);
        return obj;
    }
    if (!f.open(QIODevice::ReadOnly | QIODevice::Text)) return QJsonObject();
    QJsonDocument doc = QJsonDocument::fromJson(f.readAll());
    f.close();
    return doc.object();
}

void UniDeskGlobals::updateIsLight(int val) {
    bool prev = isLight();
    QJsonObject obj = readJsonFile("./data/settings.json");
    int colorMode = obj.value("colorMode").toInt();
    bool newIsLight = true;
    if (colorMode == 0) {
        newIsLight = true;
    } else if (colorMode == 1) {
        newIsLight = false;
    } else {
        // 自动检测系统主题
        QPalette pal = QGuiApplication::palette();
        newIsLight = pal.color(QPalette::Window).lightness() > 128;
    }
    if (prev != newIsLight) {
        isLight(newIsLight);
        emit isLightChanged(newIsLight);
    }
}

void UniDeskGlobals::emitApplicationQuit() {
    emit applicationQuit();
}

void UniDeskGlobals::startThread() {
    th = std::thread([this]() { startListener(); });
    th.detach();
}

void UniDeskGlobals::startListener() {
    py::scoped_interpreter guard{};
    py::module darkdetect = py::module::import("darkdetect");
    auto listener = darkdetect.attr("listener");
    listener([this](int val){
        QMetaObject::invokeMethod(this, [this, val](){ updateIsLight(val); }, Qt::QueuedConnection);
    });
}
