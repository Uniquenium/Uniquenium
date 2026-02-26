#ifndef UDCTEXTTOOLS_H
#define UDCTEXTTOOLS_H

#include <QQuickItem>
#include <QtQml/qqml.h>
#include <QDateTime>
#include "stdafx.h"
#include "singleton.h"
#include "UDCTextUtils.h"

class UDCTextTools : public QQuickItem {
    Q_OBJECT
    Q_PROPERTY_READONLY_AUTO(SystemStats, systemStats)
    QML_NAMED_ELEMENT(UDCTextTools)
    QML_SINGLETON

    SINGLETON(UDCTextTools)

public:
    explicit UDCTextTools(QQuickItem *parent = nullptr);

    Q_INVOKABLE QString convertStr(const QString &text);

public slots:
    void startThread();

private:
    void updateData();
};

#endif // UDCTEXTTOOLS_H

