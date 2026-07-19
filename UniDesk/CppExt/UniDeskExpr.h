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
    static auto create(QQmlEngine*, QJSEngine*) { return getInstance(); }

    Q_INVOKABLE QString convertStr(const QString &text);

    // 解析API响应并执行表达式，支持字典和列表访问
    Q_INVOKABLE QVariant evalResponse(const QString &response, const QString &expression);

    Q_INVOKABLE void stopTimer();
    


private:
    QJSEngine* m_engine = nullptr;
    QTimer* m_timer = nullptr;
    void updateData();
};

#endif // UNIDEKEXPR_H

