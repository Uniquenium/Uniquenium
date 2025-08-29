#ifndef UNIDESKGLOBALS_H
#define UNIDESKGLOBALS_H

#include "singleton.h"
#include "stdafx.h"
#include <QQuickItem>
#include <QtQml/qqml.h>

class UniDeskGlobals : public QQuickItem {
    Q_OBJECT
    Q_PROPERTY_AUTO(bool, isLight)
    QML_NAMED_ELEMENT(UniDeskGlobals)
    QML_SINGLETON
private:
    explicit UniDeskGlobals(QQuickItem *parent = nullptr);
public:
    SINGLETON(UniDeskGlobals)
    static auto create(QQmlEngine*, QJSEngine*) { return getInstance(); }

    Q_INVOKABLE void updateIsLight(int val = -1);
    Q_INVOKABLE void emitApplicationQuit();
    Q_INVOKABLE void startThread();
    Q_INVOKABLE void startListener();

signals:
    void isLightChanged(bool);
    void applicationQuit();
};

#endif // UNIDESKGLOBALS_H
