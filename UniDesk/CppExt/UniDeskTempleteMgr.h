#ifndef UNIDESKTEMPLETEMGR_H
#define UNIDESKTEMPLETEMGR_H

#include "stdafx.h"
#include "singleton.h"
#include <QQuickItem>
#include <QString>
#include <QJsonValue>
#include <QJsonArray>
#include <QJsonObject>
#include <QSet>
#include <QHash>
#include <QVariantList>
#include <QVariantMap>
#include <QFileSystemWatcher>
#include <QtQml/qqml.h>

class UniDeskTempleteMgr : public QQuickItem {
    Q_OBJECT
    Q_PROPERTY_AUTO(bool, isWorking)
    Q_PROPERTY(QVariantList templeteList READ templeteList NOTIFY templeteListChanged)
    QML_NAMED_ELEMENT(UniDeskTempleteMgr)
    QML_SINGLETON

private:
    explicit UniDeskTempleteMgr(QQuickItem *parent = nullptr);

public:
    SINGLETON(UniDeskTempleteMgr)
    static auto create(QQmlEngine*, QJSEngine*) { return getInstance(); }

    Q_INVOKABLE void saveTemplete(const QJsonArray &components, const QString &name);
    Q_INVOKABLE void loadTemplete(const QString &dir, const QVariantMap &presets = QVariantMap());
    Q_INVOKABLE QVariantList templeteList() const { return m_templeteList; }
    Q_INVOKABLE void refreshTempleteList();

signals:
    void errorOccurred(const QString &message);
    void finished(bool success, const QString &message, const QString &templeteDir, const QString &kind);
    void templeteListChanged();
    void templeteLoaded(const QVariantList &components, const QVariantMap &presets);

private:
    void doSaveTemplete(const QJsonArray &components, const QString &name, const QString &templeteDir);
    void doLoadTemplete(const QString &dir, const QVariantMap &presets);
    static QString applyPresetsToString(const QString &str, const QVariantMap &presets);
    void convertStrInJsonValue(QJsonValue &value, const QVariantMap &presets);
    void processJsonValue(QJsonValue &value, const QString &mediaDir);
    void processJsonValueForLoad(QJsonValue &value, const QString &mediaDir, const QHash<QString, QString> &renameMap);
    QString copyMediaFile(const QString &absPath, const QString &mediaDir);
    bool copyMediaDirWithRename(const QString &src, const QString &dst, QHash<QString, QString> &renameMap);
    static QString extractAbsolutePath(const QString &str);
    static bool copyPathRecursive(const QString &src, const QString &dst);
    static bool prepareOverwrite(const QString &path);
    static bool reassignUuidsInline(QJsonArray &components);

    QSet<QString> m_usedMediaNames;
    QHash<QString, QString> m_sourceToRelPath;
    QVariantList m_templeteList;
    QFileSystemWatcher *m_watcher;
};

#endif // UNIDESKTEMPLETEMGR_H