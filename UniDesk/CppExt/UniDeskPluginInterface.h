#ifndef UNIDESKPLUGININTERFACE_H
#define UNIDESKPLUGININTERFACE_H

#include <QtPlugin>
#include <QString>
#include <QQmlApplicationEngine>

class UniDeskPluginInterface
{
public:
    virtual ~UniDeskPluginInterface() = default;
    virtual void registerQmlTypes(QQmlApplicationEngine *engine) = 0;
    virtual void initialize() = 0;
};

#define UniDeskPluginInterface_iid "com.unidesk.plugin.PluginInterface"

Q_DECLARE_INTERFACE(UniDeskPluginInterface, UniDeskPluginInterface_iid)

#endif // UNIDESKPLUGININTERFACE_H