#ifndef UNIDESKSETTINGS_H
#define UNIDESKSETTINGS_H

#include "stdafx.h"
#include "singleton.h"
#include <QQuickItem>
#include <QColor>
#include <QString>
#include <QVariant>
#include <QVariantMap>
#include <QList>
#include <QtQml/qqml.h>
#include <QJsonObject>
#include <QHash>

class UniDeskSettings : public QQuickItem {
    Q_OBJECT
    Q_PROPERTY_AUTO(bool, hideTaskbar)
    Q_PROPERTY_AUTO(int, colorMode)
    Q_PROPERTY_AUTO(QColor, primaryColor)
    Q_PROPERTY_AUTO(QString, globalFontFamily)
    Q_PROPERTY_AUTO(QList<QString>, customFontFamilyPaths)
    Q_PROPERTY_AUTO(QColor, fontPrimaryColorDark)
    Q_PROPERTY_AUTO(QColor, fontSecondaryColorDark)
    Q_PROPERTY_AUTO(QColor, fontTertiaryColorDark)
    Q_PROPERTY_AUTO(QColor, fontPrimaryColorLight)
    Q_PROPERTY_AUTO(QColor, fontSecondaryColorLight)
    Q_PROPERTY_AUTO(QColor, fontTertiaryColorLight)
    Q_PROPERTY_AUTO(int, wallpaperMode)
    Q_PROPERTY_AUTO(int, wallpaperRefreshInterval)
    Q_PROPERTY_AUTO(QStringList, wallpaperImageUrls)
    Q_PROPERTY_AUTO(QString, wallpaperVideoUrl)
    Q_PROPERTY_AUTO(int, wallpaperVolume)
    Q_PROPERTY_AUTO(QString, wallpaperApiUrl)
    Q_PROPERTY_AUTO(QString, wallpaperApiExpression)
    Q_PROPERTY_AUTO(QString, language)
    Q_PROPERTY_AUTO(QString, hotkey_open_settings)
    Q_PROPERTY_AUTO(QString, hotkey_open_page_manager)
    Q_PROPERTY_AUTO(QColor, mainPanelColorDark)
    Q_PROPERTY_AUTO(QColor, mainPanelColorLight)
    Q_PROPERTY_AUTO(int, mainPanelOrientation)
    Q_PROPERTY_AUTO(int, mainPanelPosition)
    Q_PROPERTY_AUTO(bool, customCursorEnabled)
    Q_PROPERTY_AUTO(QString, customCursorStylePath)
    QML_NAMED_ELEMENT(UniDeskSettings)
    QML_SINGLETON
private:
    explicit UniDeskSettings(QQuickItem *parent = nullptr);
    static QHash<QString, QVariantMap> s_pluginDefaults;
public:
    SINGLETON(UniDeskSettings)
    static auto create(QQmlEngine*, QJSEngine*) { return getInstance(); }

    Q_INVOKABLE QVariant get(const QString &prop, const QString &pluginId = QString());
    Q_INVOKABLE void set(const QString &prop, const QVariant &val, const QString &pluginId = QString());
    Q_INVOKABLE QVariant getAll(const QString &pluginId = QString());
    Q_INVOKABLE void setAll(const QVariant &val, const QString &pluginId = QString());

    Q_INVOKABLE void notifyLoad();

    static bool isAppearanceProperty(const QString &key);
    static bool isHotkeysProperty(const QString &key);
    static bool isFunctionProperty(const QString &key);
    static QString stripPrefix(const QString &key);

    static QString settingsFilePath(const QString &pluginId = QString());
    static void setPluginDefaults(const QString &pluginId, const QVariantMap &defaults);
    static QVariantMap pluginDefaults(const QString &pluginId);
};


#endif // UNIDESKSETTINGS_H