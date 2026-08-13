#ifndef UNIDESKPLUGINMGR_H
#define UNIDESKPLUGINMGR_H

#include <QQuickItem>
#include <QtQml/qqml.h>
#include <QDateTime>
#include <QThread>
#include <QMap>
#include "stdafx.h"
#include "singleton.h"
#include "UniDeskPluginInterface.h"

class QPluginLoader;

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
    Q_INVOKABLE void unloadPlugins();
    Q_INVOKABLE void setEngine(QQmlApplicationEngine* engine);
    Q_INVOKABLE QQmlApplicationEngine* getEngine();
    Q_INVOKABLE QString getPluginDir(const QString& comTypeId) const;

private:
    QList<QPluginLoader*> m_loaders;
    QQmlApplicationEngine* m_engine;
    QMap<QString, QString> m_typePluginDirs;
};

#endif // UNIDESKPLUGINMGR_H