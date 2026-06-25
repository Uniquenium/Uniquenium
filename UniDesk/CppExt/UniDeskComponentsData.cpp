#include "UniDeskComponentsData.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QTextStream>
#include <QDir>
#include <QQmlEngine>
#include <QDebug>

static QString componentsFile = "./data/components.json";
static QString basicComTypeListFile = "./temp/UniDesk/Components/basic-com-list.json";
static QString extraComTypeListFile = "./temp/UniDesk/Components/extra-com-list.json";

static QJsonObject defaultComponents() {
    QJsonObject obj;
    obj["pages"] = QJsonArray();
    obj["currentPid"] = 0;
    obj["components"] = QJsonArray();
    return obj;
}
static void writeJsonFile(const QString &file, const QJsonObject &obj) {
    QFile f(file);
    QFileInfo fInfo(file);
    QDir().mkdir(fInfo.path());
    f.setFileName(file);
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

// static QVariant json2object(const QJsonValue &jso) {
//     if (jso.isObject()) {
//         QJsonObject obj = jso.toObject();
//         if (obj.value("<type>").toString() == "QColor") {
//             return QColor(obj.value("red").toInt(), obj.value("green").toInt(), obj.value("blue").toInt(), obj.value("alpha").toInt());
//         }
//         QVariantMap map;
//         for (auto it = obj.begin(); it != obj.end(); ++it)
//             map[it.key()] = json2object(it.value());
//         return QVariant::fromValue(map);
//     }
//     if (jso.isArray()) {
//         QVariantList list;
//         for (const QJsonValue &v : jso.toArray())
//             list << json2object(v);
//         return QVariant::fromValue(list);
//     }
//     return jso.toVariant();
// }

// static QJsonValue object2json(const QVariant &obj) {
//     // 使用typeId判断是否为QColor
//     if (obj.typeId() == qMetaTypeId<QColor>()) {
//         QColor c = obj.value<QColor>();
//         QJsonObject o;
//         o["<type>"] = "QColor";
//         o["red"] = c.red();
//         o["green"] = c.green();
//         o["blue"] = c.blue();
//         o["alpha"] = c.alpha();
//         return o;
//     }
//     // 使用typeId判断Map和List
//     if (obj.typeId() == qMetaTypeId<QVariantMap>()) {
//         QJsonObject o;
//         QVariantMap m = obj.toMap();
//         for (auto it = m.begin(); it != m.end(); ++it)
//             o[it.key()] = object2json(it.value());
//         return o;
//     }
//     if (obj.typeId() == qMetaTypeId<QVariantList>()) {
//         QJsonArray arr;
//         for (const QVariant &v : obj.toList())
//             arr.append(object2json(v));
//         return arr;
//     }
//     return QJsonValue::fromVariant(obj);
// }

UniDeskComponentsData::UniDeskComponentsData(QQuickItem *parent)
    : QQuickItem(parent)
{}

QJsonValue UniDeskComponentsData::getPages() {
    QJsonObject obj = readJsonFile(componentsFile);
    return obj.value("pages");
}

QJsonValue UniDeskComponentsData::getComponents() {
    QJsonObject obj = readJsonFile(componentsFile);
    return obj.value("components");
}

void UniDeskComponentsData::updatePage(int pIndex, const QJsonValue &page) {
    QJsonObject obj = readJsonFile(componentsFile);
    QJsonArray pages = obj.value("pages").toArray();
    if (pIndex < 0 || pIndex >= pages.size()) return;
    pages[pIndex] = page;
    obj["pages"] = pages;
    writeJsonFile(componentsFile, obj);
}

void UniDeskComponentsData::updateComponent(int componentIndex, const QJsonValue &component) {
    QJsonObject obj = readJsonFile(componentsFile);
    QJsonArray components = obj.value("components").toArray();
    if (componentIndex < 0 || componentIndex >= components.size()) return;
    components[componentIndex] = component;
    obj["components"] = components;
    writeJsonFile(componentsFile, obj);
}

void UniDeskComponentsData::addComponent(const QJsonObject &component) {
    QJsonObject obj = readJsonFile(componentsFile);
    QJsonArray components = obj.value("components").toArray();
    components.append(component);
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

void UniDeskComponentsData::addPage(const QJsonValue &page) {
    QJsonObject obj = readJsonFile(componentsFile);
    QJsonArray pages = obj.value("pages").toArray();
    pages.append(page);
    obj["pages"] = pages;
    writeJsonFile(componentsFile, obj);
}

void UniDeskComponentsData::insertPage(int index, const QJsonValue &page) {
    QJsonObject obj = readJsonFile(componentsFile);
    QJsonArray pages = obj.value("pages").toArray();
    if (index < 0 || index > pages.size()) return;
    pages.insert(index, page);
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

void UniDeskComponentsData::setCurrentPage(int id) {
    QJsonObject obj = readJsonFile(componentsFile);
    obj["currentPid"] = id;   
    writeJsonFile(componentsFile, obj);
}

int UniDeskComponentsData::getCurrentPage() {
    QJsonObject obj = readJsonFile(componentsFile);
    return obj.value("currentPid").toInt();
}

QVariant UniDeskComponentsData::getComponentTypes() {
    QVariantList componentList;
    
    // 读取基础组件列表
    QJsonObject basicObj = readJsonFile(basicComTypeListFile);
    QJsonArray basicArr = basicObj.value("componentTypes").toArray();
    for (const QJsonValue &v : basicArr) {
        QJsonObject obj = v.toObject();
        QVariantMap map;
        map["filename"] = obj.value("filename").toString();
        map["name"] = obj.value("name").toString();
        map["icon"] = obj.value("icon").toString();
        componentList.append(map);
    }
    
    // 读取额外组件列表
    QJsonObject extraObj = readJsonFile(extraComTypeListFile);
    QJsonArray extraArr = extraObj.value("componentTypes").toArray();
    for (const QJsonValue &v : extraArr) {
        QJsonObject obj = v.toObject();
        QVariantMap map;
        map["filename"] = obj.value("filename").toString();
        map["name"] = obj.value("name").toString();
        map["icon"] = obj.value("icon").toString();
        componentList.append(map);
    }
    
    return componentList;
}

QVariant UniDeskComponentsData::getBasicComponentTypes() {
    QVariantList componentList;
    QJsonObject obj = readJsonFile(basicComTypeListFile);
    QJsonArray arr = obj.value("componentTypes").toArray();
    for (const QJsonValue &v : arr) {
        QJsonObject com = v.toObject();
        QVariantMap map;
        map["filename"] = com.value("filename").toString();
        map["name"] = com.value("name").toString();
        map["icon"] = com.value("icon").toString();
        componentList.append(map);
    }
    return componentList;
}

QVariant UniDeskComponentsData::getExtraComponentTypes() {
    QVariantList componentList;
    QJsonObject obj = readJsonFile(extraComTypeListFile);
    QJsonArray arr = obj.value("componentTypes").toArray();
    for (const QJsonValue &v : arr) {
        QJsonObject com = v.toObject();
        QVariantMap map;
        map["filename"] = com.value("filename").toString();
        map["name"] = com.value("name").toString();
        map["icon"] = com.value("icon").toString();
        componentList.append(map);
    }
    return componentList;
}


// void UniDeskComponentsData::startFuncs() {
//     QFile listFile("./UniDesk/Components/components-list");
//     if (!listFile.open(QIODevice::ReadOnly | QIODevice::Text)) return;
//     QTextStream listStream(&listFile);
//     while (!listStream.atEnd()) {
//         QString componentName = listStream.readLine().trimmed();
//         if (componentName.isEmpty()) continue;
//         QFile pypluginsFile("./UniDesk/Components/" + componentName + "/plugins-list");
//         if (!pypluginsFile.open(QIODevice::ReadOnly | QIODevice::Text)) continue;
//         QTextStream pypluginsStream(&pypluginsFile);
//         while (!pypluginsStream.atEnd()) {
//             QString pluginName = pypluginsStream.readLine().trimmed();
//             if (pluginName.isEmpty()) continue;
//             // 这里假设插件信息可通过某种方式获取，实际需根据你的插件结构调整
//             // 伪代码：调用插件初始化函数
//             // plugin->startFuncs();
//             // qDebug() << "Start funcs for plugin:" << componentName << pluginName;
//         }
//         pypluginsFile.close();
//     }
//     listFile.close();
// }
