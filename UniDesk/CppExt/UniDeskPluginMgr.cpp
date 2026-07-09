#include <QDir>
#include <QPluginLoader>
#include <QMessageBox>
#include <QJsonDocument>
#include <QJsonObject>
#include <QFile>
#include <QJsonArray>
#include "UniDeskPluginMgr.h"
#include "UniDeskPluginInterface.h"

const QString pluginPath = QCoreApplication::applicationDirPath() + "/data/plugins";

UniDeskPluginMgr::UniDeskPluginMgr(QQuickItem *parent)
    : QQuickItem(parent)
{
}

void UniDeskPluginMgr::loadPlugins()
{
    QDir pluginsDir(pluginPath);
    if (!pluginsDir.exists()) {
        QDir().mkdir(pluginPath);
        return;
    }
    QVariantList pluginList;
    qDebug() << "Scanning plugins directory:" << pluginsDir.path();
    // Scan for directories in the directory
    for (const QString &pluginDirName : pluginsDir.entryList(QDir::Dirs)) {
        if ((!QDir(pluginsDir.absoluteFilePath(pluginDirName)).exists())||pluginDirName=="."||pluginDirName=="..") {
            continue;
        }
        QString pluginInfoPath = pluginsDir.absoluteFilePath(pluginDirName + "/plugin-info.json");
        QFile f(pluginInfoPath);
        if (!f.exists()) {
            qDebug() << "The plugin-info.json file does not exist:" << pluginDirName;
            continue;
        }
        if (!f.open(QIODevice::ReadOnly | QIODevice::Text)) {
            qDebug() << "Failed to open plugin-info.json file:" << pluginInfoPath;
            continue;
        }
        QJsonDocument doc = QJsonDocument::fromJson(f.readAll());
        f.close();
        QJsonObject obj = doc.object();
        if (obj.isEmpty()) {
            qDebug() << "Invalid plugin-info.json file:" << pluginInfoPath;
            continue;
        }
        for (const QJsonValue &dll : obj["dlls"].toArray()) {
            QString fileName = pluginsDir.absoluteFilePath(pluginDirName + "/" + dll.toString());
            QPluginLoader loader(fileName);
            QObject *plugin = loader.instance();
            if (plugin) {
                UniDeskPluginInterface *interface = qobject_cast<UniDeskPluginInterface*>(plugin);
                if (interface) {
                    interface->registerQmlTypes(m_engine);
                    interface->initialize();
                    
                } else {
                    qDebug() << "Plugin does not implement PluginInterface:" << fileName;
                }

            } else {
                qDebug() << "Failed to load plugin:" << fileName;
                qDebug() << "Error:" << loader.errorString();
            }
        }
        QVariantMap pluginInfo;
        qDebug()<<"Loaded plugin:"<<obj["name"].toString();
        pluginInfo["name"] = obj["name"].toString();
        pluginInfo["description"] = obj["description"].toString();
        pluginInfo["version"] = obj["version"].toString();
        pluginInfo["components"] = obj["components"].toArray();
        pluginInfo["dirpath"] = pluginsDir.absoluteFilePath(pluginDirName);
        pluginList.append(pluginInfo);
        m_engine->addImportPath(pluginsDir.absoluteFilePath(pluginDirName));
        qDebug()<< m_engine->importPathList();
    }
    plugins_list(pluginList);
}

void UniDeskPluginMgr::setEngine(QQmlApplicationEngine* engine)
{
    m_engine = engine;
}
QQmlApplicationEngine* UniDeskPluginMgr::getEngine()
{
    return m_engine;
}
