#ifndef UDCTEXTTOOLS_H
#define UDCTEXTTOOLS_H

#include <QQuickItem>
#include <QtQml/qqml.h>
#include <QDateTime>
#include "stdafx.h"
#include "singleton.h"

class UDCTextTools : public QQuickItem {
    Q_OBJECT
    Q_PROPERTY_READONLY_AUTO(double, cpuPercent)
    Q_PROPERTY_READONLY_AUTO(qint64, bytesSend)
    Q_PROPERTY_READONLY_AUTO(qint64, bytesRecv)
    Q_PROPERTY_READONLY_AUTO(qint64, bytesSendPerSec)
    Q_PROPERTY_READONLY_AUTO(qint64, bytesRecvPerSec)
    Q_PROPERTY_READONLY_AUTO(double, dropPercent)
    Q_PROPERTY_READONLY_AUTO(qint64, virtmemTotal)
    Q_PROPERTY_READONLY_AUTO(qint64, virtmemUsed)
    Q_PROPERTY_READONLY_AUTO(qint64, swapmemTotal)
    Q_PROPERTY_READONLY_AUTO(qint64, swapmemUsed)
    Q_PROPERTY_READONLY_AUTO(double, virtmemPercent)
    Q_PROPERTY_READONLY_AUTO(double, swapmemPercent)
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
    double m_cpuPercent;
    qint64 m_bytesSend;
    qint64 m_bytesRecv;
    qint64 m_bytesSendPerSec;
    qint64 m_bytesRecvPerSec;
    double m_dropPercent;
    qint64 m_virtmemTotal;
    qint64 m_virtmemUsed;
    qint64 m_swapmemTotal;
    qint64 m_swapmemUsed;
    double m_virtmemPercent;
    double m_swapmemPercent;
};

#endif // UDCTEXTTOOLS_H

