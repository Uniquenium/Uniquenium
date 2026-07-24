#pragma once

#ifndef UNIDESKCUSTOMWALLPAPER_H
#define UNIDESKCUSTOMWALLPAPER_H


#include "stdafx.h"
#include <QQuickWindow>
#include <QAbstractNativeEventFilter>
#include <QMouseEvent>
#include <QCursor>
#include <QtQml/qqml.h>
#include <QObject>
#include <QQmlProperty>
#include <QTimer>
#include <QCursor>
#include <QQuickItem>

#if (QT_VERSION >= QT_VERSION_CHECK(6, 0, 0))
using QT_NATIVE_EVENT_RESULT_TYPE = qintptr;
using QT_ENTER_EVENT_TYPE = QEnterEvent;
#else
using QT_NATIVE_EVENT_RESULT_TYPE = long;
using QT_ENTER_EVENT_TYPE = QEvent;
#endif

class UniDeskCustomWallpaper : public QQuickWindow, public QAbstractNativeEventFilter {
    Q_OBJECT
    Q_PROPERTY_AUTO(bool, attachedToWallpaper)
    Q_PROPERTY_AUTO(int, wallpaperMode)           // 0=关闭, 1=自定义API, 2=自定义图片, 3=自定义视频
    Q_PROPERTY_AUTO(QStringList, wallpaperImageUrls) // 自定义图片URL列表
    Q_PROPERTY_AUTO(QString, wallpaperVideoUrl)   // 视频壁纸URL
    Q_PROPERTY_AUTO(int, wallpaperVolume)         // 音量（0-100）
    Q_PROPERTY_AUTO(QString, wallpaperImageUrl) // 当前的图片URL
    // 自定义API相关属性
    Q_PROPERTY_AUTO(QString, wallpaperApiUrl)     // API地址
    Q_PROPERTY_AUTO(QString, wallpaperApiExpression) // 从响应中提取图片链接的表达式
    Q_PROPERTY_AUTO(bool, isMousePressed) // 是否正在按下鼠标键
    QML_NAMED_ELEMENT(UniDeskCustomWallpaper)
protected:
    bool eventFilter(QObject *obj, QEvent *event) override;
public:
    explicit UniDeskCustomWallpaper(QQuickWindow *parent = nullptr);
    ~UniDeskCustomWallpaper() override;
    bool nativeEventFilter(const QByteArray& eventType, void* message,
                          QT_NATIVE_EVENT_RESULT_TYPE* result) override;
    Q_INVOKABLE void attachToWallpaper();
    void showEvent(QShowEvent *event) override;
signals:
    void mouseMoved(const QPoint &pos);
    void mousePressed(const Qt::MouseButton &button, const QPoint &pos);
    void mouseReleased(const Qt::MouseButton &button, const QPoint &pos);
};

#endif // UNIDESKCUSTOMWALLPAPER_H