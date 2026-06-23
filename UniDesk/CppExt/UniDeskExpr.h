#ifndef UNIDEKEXPR_H
#define UNIDEKEXPR_H

#include <QQuickItem>
#include <QtQml/qqml.h>
#include <QDateTime>
#include <QThread>
#include "stdafx.h"
#include "singleton.h"
#include "UniDeskSystemInfo.h"

class UniDeskExpr : public QQuickItem {
    Q_OBJECT
    Q_PROPERTY_READONLY_AUTO(SystemStats, systemStats)
    Q_PROPERTY_AUTO_P(QThread*,thread)
    QML_NAMED_ELEMENT(UniDeskExpr)
    QML_SINGLETON
    SINGLETON(UniDeskExpr)

public:
    explicit UniDeskExpr(QQuickItem *parent = nullptr);

    Q_INVOKABLE QString convertStr(const QString &text);

    Q_INVOKABLE void stopThread();

public slots:
    void startThread();

private:
    void updateData();
};

#endif // UNIDEKEXPR_H

