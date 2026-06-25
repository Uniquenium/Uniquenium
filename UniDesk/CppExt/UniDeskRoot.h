#ifndef UNIDESKROOT_H
#define UNIDESKROOT_H

#pragma once

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

class UniDeskRoot : public QQuickWindow, public QAbstractNativeEventFilter {
    Q_OBJECT
    Q_PROPERTY_AUTO(int, margins)
    Q_PROPERTY_AUTO(Qt::Edges, edges)
    Q_PROPERTY_AUTO(bool, mouseClickThrough)
    QML_NAMED_ELEMENT(UniDeskRoot)
public:
    explicit UniDeskRoot(QQuickWindow *parent = nullptr);
    ~UniDeskRoot() override;

    void showEvent(QShowEvent *event) override;
    bool nativeEventFilter(const QByteArray& eventType, void* message,
                          QT_NATIVE_EVENT_RESULT_TYPE* result) override;
    Q_INVOKABLE void setCursorShape(Qt::CursorShape shape);
protected:
    bool eventFilter(QObject *obj, QEvent *event) override;

private slots:
    void onMouseClickThroughChanged();
    void checkMousePosition();

signals:
    void mouseMoved(const QPoint &pos);
    void mousePressed(const Qt::MouseButton &button, const QPoint &pos);
    void mouseReleased(const Qt::MouseButton &button, const QPoint &pos);
private:
    void updateClickThrough();
    QTimer *m_mouseTimer=nullptr;
    QPoint m_lastMousePos;
    QCursor *m_cursor=nullptr;
};      

#endif // UNIDESKROOT_H


