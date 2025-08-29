#ifndef UniDeskSettings_H
#define UniDeskSettings_H

#include "stdafx.h"
#include "singleton.h"
#include <QQuickItem>
#include <QColor>
#include <QString>
#include <QVariant>
#include <QList>
#include <QtQml/qqml.h>

class UniDeskSettings : public QQuickItem {
    Q_OBJECT
    Q_PROPERTY_AUTO(bool, hideTaskbar)
    Q_PROPERTY_AUTO(int, colorMode)
    Q_PROPERTY_AUTO(QColor, primaryColor)
    Q_PROPERTY_AUTO(QString, globalFontFamily)
    Q_PROPERTY_AUTO(QList<QString>, customFontFamilyPaths)
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

#endif // UniDeskSettings_H