#include <QDir>
#include <QPluginLoader>
#include <QMessageBox>
#include <QJsonDocument>
#include <QJsonObject>
#include <QFile>
#include <QJsonArray>
#ifdef Q_OS_WIN
#define NOMINMAX
#include <windows.h>
#endif
#include "UniDeskPluginMgr.h"
#include "UniDeskPluginInterface.h"
#include "UniDeskSettings.h"
#include "UniDeskGlobals.h"

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

        QString pluginDirPath = pluginsDir.absoluteFilePath(pluginDirName);
        m_engine->addImportPath(pluginDirPath);
        QCoreApplication::addLibraryPath(pluginDirPath);

#ifdef Q_OS_WIN
        SetDllDirectoryW(pluginDirPath.toStdWString().c_str());
#endif

        for (const QJsonValue &dll : obj["dlls"].toArray()) {
            QString fileName = pluginDirPath + "/" + dll.toString();
            QPluginLoader *loader = new QPluginLoader(fileName);
            QObject *plugin = loader->instance();
            if (plugin) {
                UniDeskPluginInterface *pluginInterface = qobject_cast<UniDeskPluginInterface*>(plugin);
                if (pluginInterface) {
                    pluginInterface->registerQmlTypes(m_engine);
                    pluginInterface->initialize();
                    m_loaders.append(loader);
                } else {
                    qDebug() << "Plugin does not implement PluginInterface:" << fileName;
                    delete loader;
                }
            } else {
                qDebug() << "Failed to load plugin:" << fileName;
                qDebug() << "Error:" << loader->errorString();
                delete loader;
            }
        }

#ifdef Q_OS_WIN
        SetDllDirectoryW(nullptr);
#endif
        QVariantMap pluginInfo;
        qDebug()<<"Loaded plugin:"<<obj["author"].toString()<<"."<<obj["id"].toString()<<"("<<obj["name"].toString()<<")";
        pluginInfo["author"] = obj["author"].toString();
        pluginInfo["id"] = obj["id"].toString();
        pluginInfo["name"] = obj["name"].toString();
        pluginInfo["description"] = obj["description"].toString();
        pluginInfo["version"] = obj["version"].toString();
        pluginInfo["components"] = obj["components"].toArray();
        pluginInfo["dirpath"] = pluginDirPath;
        pluginInfo["settings"] = obj.value("settings").toString();
        pluginInfo["signals"] = obj.value("signals").toString();

        QString pluginId = obj["id"].toString();

        QString defaultsPath = pluginDirPath + "/defaultSettings.json";
        QFile defaultsFile(defaultsPath);
        if (defaultsFile.exists() && defaultsFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
            QJsonDocument defaultsDoc = QJsonDocument::fromJson(defaultsFile.readAll());
            defaultsFile.close();
            QJsonObject defaultsObj = defaultsDoc.object();
            if (!defaultsObj.isEmpty()) {
                QVariantMap defaultsMap;
                for (auto it = defaultsObj.begin(); it != defaultsObj.end(); ++it) {
                    QJsonValue val = it.value();
                    if (val.isString()) defaultsMap[it.key()] = val.toString();
                    else if (val.isDouble()) defaultsMap[it.key()] = val.toDouble();
                    else if (val.isBool()) defaultsMap[it.key()] = val.toBool();
                    else if (val.isArray()) defaultsMap[it.key()] = val.toArray().toVariantList();
                    else if (val.isObject()) defaultsMap[it.key()] = val.toObject().toVariantMap();
                }
                UniDeskSettings::setPluginDefaults(pluginId, defaultsMap);
            }
        }

        pluginList.append(pluginInfo);

        QString author = obj["author"].toString();
        QString id = obj["id"].toString();
        for (const QJsonValue &comp : obj["components"].toArray()) {
            QString comTypeId = author + "." + id + "." + comp.toObject()["name"].toString();
            m_typePluginDirs[comTypeId] = pluginDirPath;
        }
    }
    plugins_list(pluginList);
}

void UniDeskPluginMgr::unloadPlugins()
{
    for (QPluginLoader *loader : m_loaders) {
        if (loader) {
            loader->unload();
            delete loader;
        }
    }
    m_loaders.clear();
    m_typePluginDirs.clear();
    plugins_list(QVariantList());
}

QString UniDeskPluginMgr::getPluginDir(const QString& comTypeId) const
{
    return m_typePluginDirs.value(comTypeId, "");
}

void UniDeskPluginMgr::setEngine(QQmlApplicationEngine* engine)
{
    m_engine = engine;
}
QQmlApplicationEngine* UniDeskPluginMgr::getEngine()
{
    return m_engine;
}