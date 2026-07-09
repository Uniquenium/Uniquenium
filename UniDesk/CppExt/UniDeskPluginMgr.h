#ifndef UNIDESKPLUGINMGR_H
#define UNIDESKPLUGINMGR_H

#include <QQuickItem>
#include <QtQml/qqml.h>
#include <QDateTime>
#include <QThread>
#include "stdafx.h"
#include "singleton.h"
#include "UniDeskPluginInterface.h"

class UniDeskPluginMgr : public QQuickItem {
    Q_OBJECT
    Q_PROPERTY_AUTO_P(QVariantList, plugins_list)
    QML_NAMED_ELEMENT(UniDeskPluginMgr)
    QML_SINGLETON
    SINGLETON(UniDeskPluginMgr)

public:
    explicit UniDeskPluginMgr(QQuickItem *parent = nullptr);
    static auto create(QQmlEngine*, QJSEngine*) { return getInstance(); }

    Q_INVOKABLE void loadPlugins();
    Q_INVOKABLE void setEngine(QQmlApplicationEngine* engine);
    Q_INVOKABLE QQmlApplicationEngine* getEngine();

private:
    QList<UniDeskPluginInterface*> m_plugins;
    QQmlApplicationEngine* m_engine;
};

#endif // UNIDESKPLUGINMGR_H
