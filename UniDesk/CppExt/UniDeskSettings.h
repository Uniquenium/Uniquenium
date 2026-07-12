#ifndef UNIDESKSETTINGS_H
#define UNIDESKSETTINGS_H

#include "stdafx.h"
#include "singleton.h"
#include <QQuickItem>
#include <QColor>
#include <QString>
#include <QVariant>
#include <QList>
#include <QtQml/qqml.h>
#include <QJsonObject>
#include <QString>

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
    // 壁纸相关属性
    Q_PROPERTY_AUTO(int, wallpaperMode)           // 0=关闭, 1=Lolicon API, 2=自定义图片, 3=自定义视频
    Q_PROPERTY_AUTO(int, wallpaperRefreshInterval) // 刷新间隔（秒）
    Q_PROPERTY_AUTO(QString, wallpaperImageUrl)   // 自定义图片URL
    Q_PROPERTY_AUTO(QString, wallpaperVideoUrl)   // 自定义视频URL
    Q_PROPERTY_AUTO(int, wallpaperVolume)         // 音量（0-100，仅视频）
    // 语言设置
    Q_PROPERTY_AUTO(QString, language)            // "zh_CN" 或 "en_US"
    QML_NAMED_ELEMENT(UniDeskSettings)
    QML_SINGLETON
private:
    explicit UniDeskSettings(QQuickItem *parent = nullptr);
public:
    SINGLETON(UniDeskSettings)
    static auto create(QQmlEngine*, QJSEngine*) { return getInstance(); }
    
    
    Q_INVOKABLE QVariant get(const QString &prop);
    Q_INVOKABLE void set(const QString &prop, const QVariant &val);
    Q_INVOKABLE QVariant getAll();
    Q_INVOKABLE void setAll(const QVariant &val);

    Q_INVOKABLE void notify(const QString &prop);
};


#endif // UNIDESKSETTINGS_H
