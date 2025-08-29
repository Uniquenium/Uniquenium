#include <pybind11/embed.h>
#include "UniDeskComponentsData.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QTextStream>
#include <QDir>
#include <QFile>
#include <QTextStream>
#include <QQmlEngine>
#include <QDebug>

namespace py = pybind11;

static QString componentsFile = "./data/components.json";

static QJsonObject defaultComponents() {
    QJsonObject obj;
    obj["pages"] = QJsonArray();
    obj["pageIndex"] = 0;
    obj["components"] = QJsonArray();
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
        QJsonObject obj = defaultComponents();
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

UniDeskComponentsData::UniDeskComponentsData(QQuickItem *parent)
    : QQuickItem(parent)
{}

QVariant UniDeskComponentsData::getPages() {
    QJsonObject obj = readJsonFile(componentsFile);
    return json2object(obj.value("pages"));
}

QVariant UniDeskComponentsData::getComponents() {
    QJsonObject obj = readJsonFile(componentsFile);
    return json2object(obj.value("components"));
}

void UniDeskComponentsData::updatePage(int pageIndex, const QVariant &page) {
    QJsonObject obj = readJsonFile(componentsFile);
    QJsonArray pages = obj.value("pages").toArray();
    if (pageIndex < 0 || pageIndex >= pages.size()) return;
    pages[pageIndex] = object2json(page);
    obj["pages"] = pages;
    writeJsonFile(componentsFile, obj);
}

void UniDeskComponentsData::updateComponent(int componentIndex, const QVariant &component) {
    QJsonObject obj = readJsonFile(componentsFile);
    QJsonArray components = obj.value("components").toArray();
    if (componentIndex < 0 || componentIndex >= components.size()) return;
    components[componentIndex] = object2json(component);
    obj["components"] = components;
    writeJsonFile(componentsFile, obj);
}

void UniDeskComponentsData::addComponent(const QVariant &component) {
    QJsonObject obj = readJsonFile(componentsFile);
    QJsonArray components = obj.value("components").toArray();
    components.append(object2json(component));
    obj["components"] = components;
    writeJsonFile(componentsFile, obj);
}

void UniDeskComponentsData::removeComponent(const QString &componentIdentification) {
    QJsonObject obj = readJsonFile(componentsFile);
    QJsonArray components = obj.value("components").toArray();
    QJsonArray newComponents;
    for (const QJsonValue &v : components) {
        QJsonObject comp = v.toObject();
        if (comp.value("identification").toString() != componentIdentification)
            newComponents.append(comp);
    }
    obj["components"] = newComponents;
    writeJsonFile(componentsFile, obj);
}

void UniDeskComponentsData::addPage(const QVariant &page) {
    QJsonObject obj = readJsonFile(componentsFile);
    QJsonArray pages = obj.value("pages").toArray();
    pages.append(object2json(page));
    obj["pages"] = pages;
    writeJsonFile(componentsFile, obj);
}

void UniDeskComponentsData::insertPage(int index, const QVariant &page) {
    QJsonObject obj = readJsonFile(componentsFile);
    QJsonArray pages = obj.value("pages").toArray();
    if (index < 0 || index > pages.size()) return;
    pages.insert(index, object2json(page));
    obj["pages"] = pages;
    writeJsonFile(componentsFile, obj);
}

void UniDeskComponentsData::removePage(int idx) {
    QJsonObject obj = readJsonFile(componentsFile);
    QJsonArray pages = obj.value("pages").toArray();
    QJsonArray newPages;
    for (const QJsonValue &v : pages) {
        QJsonObject page = v.toObject();
        if (page.value("idx").toInt() != idx)
            newPages.append(page);
    }
    obj["pages"] = newPages;
    writeJsonFile(componentsFile, obj);
}

void UniDeskComponentsData::setCurrentPage(int idx) {
    QJsonObject obj = readJsonFile(componentsFile);
    obj["pageIndex"] = idx;
    writeJsonFile(componentsFile, obj);
}

int UniDeskComponentsData::getCurrentPage() {
    QJsonObject obj = readJsonFile(componentsFile);
    return obj.value("pageIndex").toInt();
}

QVariant UniDeskComponentsData::getComponentTypes() {
    QFile f("./UniDesk/Components/components-list");
    QStringList types;
    if (f.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&f);
        while (!in.atEnd()) {
            QString line = in.readLine();
            if (!line.isEmpty())
                types << line;
        }
        f.close();
    }
    return types;
}

void UniDeskComponentsData::loadComponentPyPlugins() {
    QFile listFile("./UniDesk/Components/components-list");
    if (!listFile.open(QIODevice::ReadOnly | QIODevice::Text)) return;
    QTextStream listStream(&listFile);
    while (!listStream.atEnd()) {
        QString componentName = listStream.readLine().trimmed();
        if (componentName.isEmpty()) continue;
        QFile pypluginsFile("./UniDesk/Components/" + componentName + "/pyplugins-list");
        if (!pypluginsFile.open(QIODevice::ReadOnly | QIODevice::Text)) continue;
        QTextStream pypluginsStream(&pypluginsFile);
        while (!pypluginsStream.atEnd()) {
            QString pluginName = pypluginsStream.readLine().trimmed();
            if (pluginName.isEmpty()) continue;
            // 这里假设插件信息可通过某种方式获取，实际需根据你的插件结构调整
            // 伪代码：注册 QML 类型或单例
            // QQmlEngine::registerSingletonType(...);
            // QQmlEngine::registerType(...);
            // 可用 QPluginLoader 或自定义插件管理
            // qDebug() << "Register plugin:" << componentName << pluginName;
        }
        pypluginsFile.close();
    }
    listFile.close();
}

void UniDeskComponentsData::startFuncs() {
    QFile listFile("./UniDesk/Components/components-list");
    if (!listFile.open(QIODevice::ReadOnly | QIODevice::Text)) return;
    QTextStream listStream(&listFile);
    while (!listStream.atEnd()) {
        QString componentName = listStream.readLine().trimmed();
        if (componentName.isEmpty()) continue;
        QFile pypluginsFile("./UniDesk/Components/" + componentName + "/pyplugins-list");
        if (!pypluginsFile.open(QIODevice::ReadOnly | QIODevice::Text)) continue;
        QTextStream pypluginsStream(&pypluginsFile);
        while (!pypluginsStream.atEnd()) {
            QString pluginName = pypluginsStream.readLine().trimmed();
            if (pluginName.isEmpty()) continue;
            // 这里假设插件信息可通过某种方式获取，实际需根据你的插件结构调整
            // 伪代码：调用插件初始化函数
            // plugin->startFuncs();
            // qDebug() << "Start funcs for plugin:" << componentName << pluginName;
        }
        pypluginsFile.close();
    }
    listFile.close();
}
