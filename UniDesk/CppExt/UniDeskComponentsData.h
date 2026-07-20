#ifndef UNIDESKCOMPONENTSDATA_H
#define UNIDESKCOMPONENTSDATA_H

#include "singleton.h"
#include <QQuickItem>
#include <QVariant>
#include <QString>
#include <QList>
#include <QJsonArray>
#include <QJsonObject>
#include <QtQml/qqml.h>

class UniDeskComponentsData : public QQuickItem {
    Q_OBJECT
    QML_NAMED_ELEMENT(UniDeskComponentsData)
    QML_SINGLETON
private:
    explicit UniDeskComponentsData(QQuickItem *parent = nullptr);
public:
    SINGLETON(UniDeskComponentsData)
    static auto create(QQmlEngine*, QJSEngine*) { return getInstance(); }

    Q_INVOKABLE QJsonArray getPages();
    Q_INVOKABLE QJsonArray getComponents();
    Q_INVOKABLE void updatePage(int pIndex, const QJsonValue &page);
    Q_INVOKABLE void updateComponent(int componentIndex, const QJsonValue &component);
    Q_INVOKABLE void addComponent(const QJsonObject &component);
    Q_INVOKABLE void removeComponent(const QString &componentIdentification);
    Q_INVOKABLE void addPage(const QJsonValue &page);
    Q_INVOKABLE void insertPage(int index, const QJsonValue &page);
    Q_INVOKABLE void removePage(const QString &idx);
    Q_INVOKABLE void setCurrentPage(const QString &id);
    Q_INVOKABLE QString getCurrentPage();
    Q_INVOKABLE QVariant getComponentTypes();
    Q_INVOKABLE QVariant getBasicComponentTypes();
    // Q_INVOKABLE void startFuncs();
};

#endif // UNIDESKCOMPONENTSDATA_H
