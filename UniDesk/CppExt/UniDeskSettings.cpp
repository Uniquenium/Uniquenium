#include "UniDeskSettings.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDir>
#include <QCoreApplication>
#include <QSet>

QHash<QString, QVariantMap> UniDeskSettings::s_pluginDefaults;

QString UniDeskSettings::settingsFilePath(const QString &pluginId) {
    if (pluginId.isEmpty())
        return QCoreApplication::applicationDirPath() + "/data/settings.json";
    return QCoreApplication::applicationDirPath() + "/data/plugins/" + pluginId + "/settings.json";
}

QString UniDeskSettings::stripPrefix(const QString &key) {
    int dot = key.indexOf('.');
    return (dot > 0) ? key.mid(dot + 1) : key;
}
bool UniDeskSettings::isAppearanceProperty(const QString &key) { return key.startsWith("appearance."); }
bool UniDeskSettings::isHotkeysProperty(const QString &key) { return key.startsWith("hotkeys."); }
bool UniDeskSettings::isFunctionProperty(const QString &key) { return key.startsWith("function."); }

static QJsonObject mainDefaultSettings() {
    QJsonObject obj;
    obj["function.hideTaskbar"] = false;
    obj["appearance.colorMode"] = 2;
    QJsonObject color;
    color["<type>"] = "QColor";
    color["red"] = 0;
    color["green"] = 100;
    color["blue"] = 255;
    color["alpha"] = 255;
    obj["appearance.primaryColor"] = color;
    obj["appearance.globalFontFamily"] = QString::fromUtf8("微软雅黑");
    obj["appearance.customFontFamilyPaths"] = QJsonArray();
    QJsonObject fontPrimaryColorDark{{"<type>", "QColor"},{"red", 255},{"green",255},{"blue",255},{"alpha",255}};
    obj["appearance.fontPrimaryColorDark"]=fontPrimaryColorDark;
    QJsonObject fontPrimaryColorLight{{"<type>", "QColor"},{"red", 0},{"green",0},{"blue",0},{"alpha",255}};
    obj["appearance.fontPrimaryColorLight"]=fontPrimaryColorLight;
    QJsonObject fontSecondaryColorDark{{"<type>", "QColor"},{"red", 222},{"green",222},{"blue",222},{"alpha",255}};
    obj["appearance.fontSecondaryColorDark"]=fontSecondaryColorDark;
    QJsonObject fontSecondaryColorLight{{"<type>", "QColor"},{"red", 102},{"green",102},{"blue",102},{"alpha",255}};
    obj["appearance.fontSecondaryColorLight"]=fontSecondaryColorLight;
    QJsonObject fontTertiaryColorDark{{"<type>", "QColor"},{"red", 200},{"green",200},{"blue",200},{"alpha",255}};
    obj["appearance.fontTertiaryColorDark"]=fontTertiaryColorDark;
    QJsonObject fontTertiaryColorLight{{"<type>", "QColor"},{"red", 153},{"green",153},{"blue",153},{"alpha",255}};
    obj["appearance.fontTertiaryColorLight"]=fontTertiaryColorLight;
    obj["appearance.wallpaperMode"] = 0;
    obj["appearance.wallpaperRefreshInterval"] = 300;
    obj["appearance.wallpaperVideoUrl"] = QString();
    obj["appearance.wallpaperVolume"] = 0;
    obj["appearance.wallpaperApiUrl"] = QString();
    obj["appearance.wallpaperApiExpression"] = QString();
    obj["appearance.wallpaperImageUrls"] = QJsonArray();
    obj["function.language"] = "zh_CN";
    obj["hotkeys.hotkey_open_settings"] = "Ctrl+Shift+S";
    obj["hotkeys.hotkey_open_page_manager"] = "Ctrl+Shift+P";
    QJsonObject mainPanelColorDark{{"<type>", "QColor"},{"red", 0},{"green",0},{"blue",0},{"alpha",150}};
    obj["appearance.mainPanelColorDark"] = mainPanelColorDark;
    QJsonObject mainPanelColorLight{{"<type>", "QColor"},{"red", 255},{"green",255},{"blue",255},{"alpha",150}};
    obj["appearance.mainPanelColorLight"] = mainPanelColorLight;
    obj["appearance.mainPanelOrientation"] = 1;
    obj["appearance.mainPanelPosition"] = 0;
    obj["appearance.customCursorEnabled"] = false;
    obj["appearance.customCursorStylePath"] = QString();
    return obj;
}

static void writeJsonFile(const QString &file, const QJsonObject &obj) {
    QFile f(file);
    QDir().mkpath(QFileInfo(file).absolutePath());
    f.open(QIODevice::WriteOnly | QIODevice::Text);
    QJsonDocument doc(obj);
    f.write(doc.toJson(QJsonDocument::Indented));
    f.close();
}

static QJsonObject readJsonFile(const QString &file, bool isPlugin) {
    QFile f(file);
    if (!f.exists()) {
        QJsonObject obj;
        if (!isPlugin)
            obj = mainDefaultSettings();
        writeJsonFile(file, obj);
        return obj;
    }
    if (!f.open(QIODevice::ReadOnly | QIODevice::Text)) return QJsonObject();
    QJsonDocument doc = QJsonDocument::fromJson(f.readAll());
    f.close();
    if (doc.isNull()) {
        QJsonObject obj;
        if (!isPlugin)
            obj = mainDefaultSettings();
        writeJsonFile(file, obj);
        return obj;
    }
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

QVariant UniDeskSettings::get(const QString &key, const QString &pluginId) {
    bool isPlugin = !pluginId.isEmpty();
    QString file = settingsFilePath(pluginId);
    QJsonObject obj = readJsonFile(file, isPlugin);
    QJsonValue v = obj.value(key);
    if (v.isUndefined() || v.isNull()) v = obj.value(stripPrefix(key));
    if (v.isUndefined() || v.isNull()) {
        if (isPlugin) {
            QVariantMap defaults = s_pluginDefaults.value(pluginId);
            if (defaults.contains(key)) return defaults.value(key);
            QString prefixFree = stripPrefix(key);
            if (defaults.contains(prefixFree)) return defaults.value(prefixFree);
            return QVariant();
        }
        return json2object(mainDefaultSettings()[key]);
    }
    return json2object(v);
}

void UniDeskSettings::set(const QString &key, const QVariant &val, const QString &pluginId) {
    bool isPlugin = !pluginId.isEmpty();
    QString file = settingsFilePath(pluginId);
    QJsonObject obj = readJsonFile(file, isPlugin);
    obj[key] = object2json(val);
    if (key.contains('.'))
        obj.remove(stripPrefix(key));
    writeJsonFile(file, obj);
    if (!isPlugin)
        notifyLoad();
}

QVariant UniDeskSettings::getAll(const QString &pluginId) {
    bool isPlugin = !pluginId.isEmpty();
    QString file = settingsFilePath(pluginId);
    QJsonObject obj = readJsonFile(file, isPlugin);
    QVariantMap map;
    QVariantMap defaults = isPlugin ? s_pluginDefaults.value(pluginId) : QVariantMap();
    for (auto it = defaults.begin(); it != defaults.end(); ++it)
        map[it.key()] = it.value();
    for (auto it = obj.begin(); it != obj.end(); ++it)
        map[it.key()] = json2object(it.value());
    return map;
}

void UniDeskSettings::setAll(const QVariant &val, const QString &pluginId) {
    if (!val.canConvert<QVariantMap>()) return;
    QVariantMap map = val.toMap();
    QJsonObject obj;
    for (auto it = map.begin(); it != map.end(); ++it)
        obj[it.key()] = object2json(it.value());
    QString file = settingsFilePath(pluginId);
    writeJsonFile(file, obj);
    if (pluginId.isEmpty())
        notifyLoad();
}

void UniDeskSettings::setPluginDefaults(const QString &pluginId, const QVariantMap &defaults) {
    s_pluginDefaults[pluginId] = defaults;
}

QVariantMap UniDeskSettings::pluginDefaults(const QString &pluginId) {
    return s_pluginDefaults.value(pluginId);
}

void UniDeskSettings::notifyLoad() {
    QString file = settingsFilePath();
    QJsonObject obj = readJsonFile(file, false);
    auto getVal = [&obj](const QString &key) -> QJsonValue {
        QJsonValue v = obj.value(key);
        if (v.isUndefined() || v.isNull()) v = obj.value(stripPrefix(key));
        return v;
    };
    hideTaskbar(getVal("function.hideTaskbar").toBool());
    colorMode(getVal("appearance.colorMode").toInt());
    primaryColor(json2object(getVal("appearance.primaryColor")).value<QColor>());
    fontPrimaryColorDark(json2object(getVal("appearance.fontPrimaryColorDark")).value<QColor>());
    fontPrimaryColorLight(json2object(getVal("appearance.fontPrimaryColorLight")).value<QColor>());
    fontSecondaryColorDark(json2object(getVal("appearance.fontSecondaryColorDark")).value<QColor>());
    fontSecondaryColorLight(json2object(getVal("appearance.fontSecondaryColorLight")).value<QColor>());
    fontTertiaryColorDark(json2object(getVal("appearance.fontTertiaryColorDark")).value<QColor>());
    fontTertiaryColorLight(json2object(getVal("appearance.fontTertiaryColorLight")).value<QColor>());
    globalFontFamily(getVal("appearance.globalFontFamily").toString());
    QList<QString> fontPaths;
    for (const QJsonValue &v : getVal("appearance.customFontFamilyPaths").toArray())
        fontPaths << v.toString();
    customFontFamilyPaths(fontPaths);
    wallpaperMode(getVal("appearance.wallpaperMode").toInt());
    wallpaperRefreshInterval(getVal("appearance.wallpaperRefreshInterval").toInt());
    wallpaperApiUrl(getVal("appearance.wallpaperApiUrl").toString());
    wallpaperApiExpression(getVal("appearance.wallpaperApiExpression").toString());
    QStringList imageUrls;
    for (const QJsonValue &v : getVal("appearance.wallpaperImageUrls").toArray())
        imageUrls << v.toString();
    wallpaperImageUrls(imageUrls);
    wallpaperVideoUrl(getVal("appearance.wallpaperVideoUrl").toString());
    wallpaperVolume(getVal("appearance.wallpaperVolume").toInt());
    language(getVal("function.language").toString());
    hotkey_open_settings(getVal("hotkeys.hotkey_open_settings").toString());
    hotkey_open_page_manager(getVal("hotkeys.hotkey_open_page_manager").toString());
    mainPanelColorDark(json2object(getVal("appearance.mainPanelColorDark")).value<QColor>());
    mainPanelColorLight(json2object(getVal("appearance.mainPanelColorLight")).value<QColor>());
    mainPanelOrientation(getVal("appearance.mainPanelOrientation").toInt());
    mainPanelPosition(getVal("appearance.mainPanelPosition").toInt());
    customCursorEnabled(getVal("appearance.customCursorEnabled").toBool());
    customCursorStylePath(getVal("appearance.customCursorStylePath").toString());
}