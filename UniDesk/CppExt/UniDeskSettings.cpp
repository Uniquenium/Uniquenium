#include "UniDeskSettings.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDir>

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
    QJsonObject fontPrimaryColorDark{{"<type>", "QColor"},{"red", 255},{"green",255},{"blue",255},{"alpha",255}};
    obj["fontPrimaryColorDark"]=fontPrimaryColorDark;
    QJsonObject fontPrimaryColorLight{{"<type>", "QColor"},{"red", 0},{"green",0},{"blue",0},{"alpha",255}};
    obj["fontPrimaryColorLight"]=fontPrimaryColorLight;
    QJsonObject fontSecondaryColorDark{{"<type>", "QColor"},{"red", 222},{"green",222},{"blue",222},{"alpha",255}};
    obj["fontSecondaryColorDark"]=fontSecondaryColorDark;
    QJsonObject fontSecondaryColorLight{{"<type>", "QColor"},{"red", 102},{"green",102},{"blue",102},{"alpha",255}};
    obj["fontSecondaryColorLight"]=fontSecondaryColorLight;
    QJsonObject fontTertiaryColorDark{{"<type>", "QColor"},{"red", 200},{"green",200},{"blue",200},{"alpha",255}};
    obj["fontTertiaryColorDark"]=fontTertiaryColorDark;
    QJsonObject fontTertiaryColorLight{{"<type>", "QColor"},{"red", 153},{"green",153},{"blue",153},{"alpha",255}};
    obj["fontTertiaryColorLight"]=fontTertiaryColorLight;
    // 壁纸相关默认值
    obj["wallpaperMode"] = 0;                   // 0=关闭
    obj["wallpaperRefreshInterval"] = 300;      // 5分钟
    obj["wallpaperVideoUrl"] = QString();
    obj["wallpaperVolume"] = 0;
    obj["wallpaperApiUrl"] = QString();
    obj["wallpaperApiExpression"] = QString();
    obj["wallpaperImageUrls"] = QJsonArray();

    // 语言设置默认值
    obj["language"] = "zh_CN";                 // 默认中文
    obj["hotkey_open_settings"] = "Ctrl+Shift+S";
    obj["hotkey_open_page_manager"] = "Ctrl+Shift+P";
    // 主面板默认值
    QJsonObject mainPanelColorDark{{"<type>", "QColor"},{"red", 0},{"green",0},{"blue",0},{"alpha",150}};
    obj["mainPanelColorDark"] = mainPanelColorDark;
    QJsonObject mainPanelColorLight{{"<type>", "QColor"},{"red", 255},{"green",255},{"blue",255},{"alpha",150}};
    obj["mainPanelColorLight"] = mainPanelColorLight;
    obj["mainPanelOrientation"] = 0;           // 默认横向
    obj["mainPanelPosition"] = 1;              // 默认底部
    obj["customCursorEnabled"] = false;          // 默认关闭自定义光标
    obj["customCursorStylePath"] = QString();
    return obj;
}
static void writeJsonFile(const QString &file, const QJsonObject &obj) {
    QFile f(file);
    QDir().mkdir("./data");
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
    notifyLoad();
}

QVariant UniDeskSettings::get(const QString &prop) {
    QJsonObject obj = readJsonFile(settingsFile);
    if (obj.value(prop).isUndefined()||obj.value(prop).isNull()) return json2object(defaultSettings()[prop]);
    return json2object(obj.value(prop));
}

void UniDeskSettings::set(const QString &prop, const QVariant &val) {
    QJsonObject obj = readJsonFile(settingsFile);
    obj[prop] = object2json(val);
    writeJsonFile(settingsFile, obj);
    notifyLoad();
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
    notifyLoad();
}

void UniDeskSettings::notifyLoad() {
    QJsonObject obj = readJsonFile(settingsFile);
    hideTaskbar(obj.value("hideTaskbar").toBool());
    colorMode(obj.value("colorMode").toInt());
    primaryColor(json2object(obj.value("primaryColor")).value<QColor>());
    fontPrimaryColorDark(json2object(obj.value("fontPrimaryColorDark")).value<QColor>());
    fontPrimaryColorLight(json2object(obj.value("fontPrimaryColorLight")).value<QColor>());
    fontSecondaryColorDark(json2object(obj.value("fontSecondaryColorDark")).value<QColor>());
    fontSecondaryColorLight(json2object(obj.value("fontSecondaryColorLight")).value<QColor>());
    fontTertiaryColorDark(json2object(obj.value("fontTertiaryColorDark")).value<QColor>());
    fontTertiaryColorLight(json2object(obj.value("fontTertiaryColorLight")).value<QColor>());
    globalFontFamily(obj.value("globalFontFamily").toString());
    QList<QString> fontPaths;
    for (const QJsonValue &v : obj.value("customFontFamilyPaths").toArray())
        fontPaths << v.toString();
    customFontFamilyPaths(fontPaths);
    // 加载壁纸设置
    wallpaperMode(obj.value("wallpaperMode").toInt());
    wallpaperRefreshInterval(obj.value("wallpaperRefreshInterval").toInt());
    wallpaperApiUrl(obj.value("wallpaperApiUrl").toString());
    wallpaperApiExpression(obj.value("wallpaperApiExpression").toString());
    QStringList imageUrls;
    for (const QJsonValue &v : obj.value("wallpaperImageUrls").toArray())
        imageUrls << v.toString();
    wallpaperImageUrls(imageUrls);
    wallpaperVideoUrl(obj.value("wallpaperVideoUrl").toString());
    wallpaperVolume(obj.value("wallpaperVolume").toInt());
    // 加载语言设置
    language(obj.value("language").toString());
    // 加载快捷键设置
    hotkey_open_settings(obj.value("hotkey_open_settings").toString());
    hotkey_open_page_manager(obj.value("hotkey_open_page_manager").toString());
    // 加载主面板设置
    mainPanelColorDark(json2object(obj.value("mainPanelColorDark")).value<QColor>());
    mainPanelColorLight(json2object(obj.value("mainPanelColorLight")).value<QColor>());
    mainPanelOrientation(obj.value("mainPanelOrientation").toInt());
    mainPanelPosition(obj.value("mainPanelPosition").toInt());
    customCursorEnabled(obj.value("customCursorEnabled").toBool());
    customCursorStylePath(obj.value("customCursorStylePath").toString());
}

