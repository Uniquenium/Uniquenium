#include <pybind11/embed.h>
#include "UniDeskSettings.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

namespace py=pybind11;

static QString settingsFile = "./data/settings.json";

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



static QVariant json2object(const QJsonValue &jso) {
    if (jso.isObject()) {
        QJsonObject obj = jso.toObject();
        if (obj.value("<type>").toString() == "QColor") {
            return QColor(obj.value("red").toInt(), obj.value("green").toInt(), obj.value("blue").toInt(), obj.value("alpha").toInt());
        }
        QVariantMap map;
        for (auto it = obj.begin(); it != obj.end(); ++it)
            map[it.key()] = json2object(it.value());
        return QVariant::fromValue(map);
    }
    if (jso.isArray()) {
        QVariantList list;
        for (const QJsonValue &v : jso.toArray())
            list << json2object(v);
        return QVariant::fromValue(list);
    }
    return jso.toVariant();
}

static QJsonValue object2json(const QVariant &obj) {
    // 使用typeId判断是否为QColor
    if (obj.typeId() == qMetaTypeId<QColor>()) {
        QColor c = obj.value<QColor>();
        QJsonObject o;
        o["<type>"] = "QColor";
        o["red"] = c.red();
        o["green"] = c.green();
        o["blue"] = c.blue();
        o["alpha"] = c.alpha();
        return o;
    }
    // 使用typeId判断Map和List
    if (obj.typeId() == qMetaTypeId<QVariantMap>()) {
        QJsonObject o;
        QVariantMap m = obj.toMap();
        for (auto it = m.begin(); it != m.end(); ++it)
            o[it.key()] = object2json(it.value());
        return o;
    }
    if (obj.typeId() == qMetaTypeId<QVariantList>()) {
        QJsonArray arr;
        for (const QVariant &v : obj.toList())
            arr.append(object2json(v));
        return arr;
    }
    return QJsonValue::fromVariant(obj);
}

UniDeskSettings::UniDeskSettings(QQuickItem *parent)
    : QQuickItem(parent)
{
    QJsonObject obj = readJsonFile(settingsFile);
    hideTaskbar(obj.value("hideTaskbar").toBool());
    colorMode(obj.value("colorMode").toInt());
    primaryColor(json2object(obj.value("primaryColor")).value<QColor>());
    globalFontFamily(obj.value("globalFontFamily").toString());
    QList<QString> fontPaths;
    for (const QJsonValue &v : obj.value("customFontFamilyPaths").toArray())
        fontPaths << v.toString();
    customFontFamilyPaths(fontPaths);
}

QVariant UniDeskSettings::get(const QString &prop) {
    QJsonObject obj = readJsonFile(settingsFile);
    return json2object(obj.value(prop));
}

void UniDeskSettings::set(const QString &prop, const QVariant &val) {
    QJsonObject obj = readJsonFile(settingsFile);
    obj[prop] = object2json(val);
    writeJsonFile(settingsFile, obj);
}

QVariant UniDeskSettings::getAll() {
    QJsonObject obj = readJsonFile(settingsFile);
    QVariantMap map;
    for (auto it = obj.begin(); it != obj.end(); ++it)
        map[it.key()] = json2object(it.value());
    return map;
}

void UniDeskSettings::setAll(const QVariant &val) {
    if (!val.canConvert<QVariantMap>()) return;
    QVariantMap map = val.toMap();
    QJsonObject obj;
    for (auto it = map.begin(); it != map.end(); ++it)
        obj[it.key()] = object2json(it.value());
    writeJsonFile(settingsFile, obj);
}

void UniDeskSettings::notify(const QString &prop) {
    // 触发属性变更信号
    if (prop == "hideTaskbar") emit hideTaskbarChanged();
    else if (prop == "colorMode") emit colorModeChanged();
    else if (prop == "primaryColor") emit primaryColorChanged();
    else if (prop == "globalFontFamily") emit globalFontFamilyChanged();
    else if (prop == "customFontFamilyPaths") emit customFontFamilyPathsChanged();
}

