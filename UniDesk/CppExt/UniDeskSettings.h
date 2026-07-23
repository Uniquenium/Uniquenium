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
    Q_PROPERTY_AUTO(int, wallpaperMode)           // 0=关闭, 1=自定义API, 2=自定义图片, 3=自定义视频
    Q_PROPERTY_AUTO(int, wallpaperRefreshInterval) // 刷新间隔（秒）
    Q_PROPERTY_AUTO(QStringList, wallpaperImageUrls) // 自定义图片URL列表
    Q_PROPERTY_AUTO(QString, wallpaperVideoUrl)   // 自定义视频URL
    Q_PROPERTY_AUTO(int, wallpaperVolume)         // 音量（0-100，仅视频）
    // 自定义API相关属性
    Q_PROPERTY_AUTO(QString, wallpaperApiUrl)     // API地址
    Q_PROPERTY_AUTO(QString, wallpaperApiExpression) // 从响应中提取图片链接的表达式
    // 语言设置
    Q_PROPERTY_AUTO(QString, language)            // "zh_CN" 或 "en_US"
    // 快捷键设置
    Q_PROPERTY_AUTO(QString, hotkey_open_settings) // 打开设置窗口的快捷键
    Q_PROPERTY_AUTO(QString, hotkey_open_page_manager) // 打开页面管理器的快捷键
    // 主面板设置
    Q_PROPERTY_AUTO(QColor, mainPanelColorDark)    // 主面板颜色（深色模式）
    Q_PROPERTY_AUTO(QColor, mainPanelColorLight)   // 主面板颜色（浅色模式）
    Q_PROPERTY_AUTO(int, mainPanelOrientation)     // 主面板方向（0=横向, 1=纵向）
    Q_PROPERTY_AUTO(int, mainPanelPosition)        // 主面板位置（0=顶部, 1=底部）
    // 鼠标光标设置
    Q_PROPERTY_AUTO(bool, customCursorEnabled)      // 是否启用自定义光标
    Q_PROPERTY_AUTO(QString, customCursorStylePath) // 自定义光标样式路径
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

    Q_INVOKABLE void notifyLoad();
};


#endif // UNIDESKSETTINGS_H
