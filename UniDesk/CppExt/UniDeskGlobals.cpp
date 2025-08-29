#include <pybind11/embed.h>
#include "UniDeskGlobals.h"
#include "UniDeskSettings.h"
#include <QGuiApplication>
#include <QPalette>
#include <QTimer>
#include <thread>
namespace py = pybind11;

static QMap<QString, QVariant> g_config;
static std::thread th;

UniDeskGlobals::UniDeskGlobals(QQuickItem *parent)
    : QQuickItem(parent)
{
    isLight(true);

}

void UniDeskGlobals::updateIsLight(int val) {
    bool prev = isLight();
    int colorMode = UniDeskSettings::getInstance()->colorMode();
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