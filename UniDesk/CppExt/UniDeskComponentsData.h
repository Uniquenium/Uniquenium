#ifndef UNIDESKCOMPONENTSDATA_H
#define UNIDESKCOMPONENTSDATA_H

#include "singleton.h"
#include "stdafx.h"
#include <QQuickItem>
#include <QVariant>
#include <QString>
#include <QList>
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

    Q_INVOKABLE QVariant getPages();
    Q_INVOKABLE QVariant getComponents();
    Q_INVOKABLE void updatePage(int pageIndex, const QVariant &page);
    Q_INVOKABLE void updateComponent(int componentIndex, const QVariant &component);
    Q_INVOKABLE void addComponent(const QVariant &component);
    Q_INVOKABLE void removeComponent(const QString &componentIdentification);
    Q_INVOKABLE void addPage(const QVariant &page);
    Q_INVOKABLE void insertPage(int index, const QVariant &page);
    Q_INVOKABLE void removePage(int idx);
    Q_INVOKABLE void setCurrentPage(int idx);
    Q_INVOKABLE int getCurrentPage();
    Q_INVOKABLE QVariant getComponentTypes();

    Q_INVOKABLE void loadComponentPyPlugins();
    Q_INVOKABLE void startFuncs();
};

#endif // UNIDESKCOMPONENTSDATA_H