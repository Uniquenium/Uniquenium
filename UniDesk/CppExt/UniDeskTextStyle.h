#ifndef UNIDESKTEXTSTYLE_H
#define UNIDESKTEXTSTYLE_H

#include "singleton.h"
#include "stdafx.h"
#include <QFont>
#include <QObject>
#include <QtQml/qqml.h>

/**
 * @brief The UniDeskTextStyle class
 */
class UniDeskTextStyle : public QObject {
    Q_OBJECT
    Q_PROPERTY_AUTO(QString, family)
    Q_PROPERTY_AUTO(QFont, tiny)
    Q_PROPERTY_AUTO(QFont, little)
    Q_PROPERTY_AUTO(QFont, littleStrong)
    Q_PROPERTY_AUTO(QFont, small_)
    Q_PROPERTY_AUTO(QFont, medium)
    Q_PROPERTY_AUTO(QFont, large)
    Q_PROPERTY_AUTO(QFont, huge_)
    QML_NAMED_ELEMENT(UniDeskTextStyle)
    QML_SINGLETON

private:
    explicit UniDeskTextStyle(QObject* parent = nullptr);

public:
    SINGLETON(UniDeskTextStyle)

    static UniDeskTextStyle* create(QQmlEngine*, QJSEngine*)
    {
        return getInstance();
    }
    Q_INVOKABLE void changeFontFamily(const QString& family) ;
};

#endif // UNIDESKTEXTSTYLE_H
