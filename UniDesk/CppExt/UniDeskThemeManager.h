#ifndef UNIDESKTHEMEMANAGER_H
#define UNIDESKTHEMEMANAGER_H

#include "stdafx.h"
#include "singleton.h"
#include <QQuickItem>
#include <QString>
#include <QJsonValue>
#include <QSet>
#include <QHash>
#include <QtQml/qqml.h>

class UniDeskThemeManager : public QQuickItem {
    Q_OBJECT
    Q_PROPERTY_AUTO(qreal, progress)
    Q_PROPERTY_AUTO(QString, progressMessage)
    Q_PROPERTY_AUTO(bool, isWorking)
    QML_NAMED_ELEMENT(UniDeskThemeManager)
    QML_SINGLETON

private:
    explicit UniDeskThemeManager(QQuickItem *parent = nullptr);

public:
    SINGLETON(UniDeskThemeManager)
    static auto create(QQmlEngine*, QJSEngine*) { return getInstance(); }

    Q_INVOKABLE void saveTheme(const QString &themeDir);
    Q_INVOKABLE void loadTheme(const QString &themeDir);

signals:
    void errorOccurred(const QString &message);
    void finished(bool success, const QString &message);

private:
    void doSaveTheme(const QString &themeDir);
    void doLoadTheme(const QString &themeDir);
    void processJsonValue(QJsonValue &value, const QString &mediaDir);
    void processJsonValueForLoad(QJsonValue &value, const QString &mediaDir, const QHash<QString, QString> &renameMap = {});
    QString copyMediaFile(const QString &absPath, const QString &mediaDir);
    static bool copyPathRecursive(const QString &src, const QString &dst, bool skipDll);
    static bool clearDirectory(const QString &path);
    static bool clearPluginsDirPartially(const QString &path, const QStringList &markList);
    static bool clearMediaDirPartially(const QString &path, QStringList &markList);
    static QString extractAbsolutePath(const QString &str);
    void reportProgress(qreal value, const QString &message);
    void reportError(const QString &message);
    void reportFinished(bool success, const QString &message);

    bool copyMediaDirWithRename(const QString &src, const QString &dst, QHash<QString, QString> &renameMap);
    static bool processComponentsReassignUuids(const QString &componentsFile);
    static void markDllForDeletion(const QString &dllPath);
    static void markDllForCopy(const QString &srcDll, const QString &dstDll);
    static void cleanupPendingDeletesAtStartup();
    static void markMediaForDeletion(const QString &mediaPath);
    static void cleanupPendingMediaDeletesAtStartup();
    static void restartApp();

    QSet<QString> m_usedMediaNames;
    QHash<QString, QString> m_sourceToRelPath;
};

#endif // UNIDESKTHEMEMANAGER_H
