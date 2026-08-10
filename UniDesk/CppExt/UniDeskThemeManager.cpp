#include "UniDeskThemeManager.h"
#include "UniDeskSettings.h"
#include "UniDeskComponentsData.h"
#include "UniDeskPluginMgr.h"
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
#include <QUuid>
#include <QUrl>
#include <QRegularExpression>
#include <QtConcurrent>
#include <QThreadPool>
#include <QMetaObject>
#include <QCoreApplication>
#include <QColor>
#include <QVariantMap>
#include <QVariantList>
#include <QSet>
#include <QProcess>
#include <QTimer>
#include <functional>

static QString pluginRootPath = QCoreApplication::applicationDirPath() + "/data/plugins";
static QString dataRootPath = QCoreApplication::applicationDirPath() + "/data";
static QString pendingDllOpsFile = dataRootPath + "/.pending_dll_ops.json";
static QString pendingPluginsTempDir = dataRootPath + "/.pending_plugins_temp";
static QString pendingMediaOpsFile = dataRootPath + "/.pending_media_ops.json";

static bool prepareOverwrite(const QString &path) {
    if (!QFile::exists(path)) return true;
    QFile f(path);
    f.setPermissions(f.permissions() | QFile::WriteOwner);
    return f.remove();
}

UniDeskThemeManager::UniDeskThemeManager(QQuickItem *parent)
    : QQuickItem(parent)
{
    progress(0.0);
    progressMessage(QString(tr("未进行任务")));
    isWorking(false);
    cleanupPendingDeletesAtStartup();
    cleanupPendingMediaDeletesAtStartup();
}

void UniDeskThemeManager::reportProgress(qreal value, const QString &message) {
    QMetaObject::invokeMethod(this, [this, value, message]() {
        progress(value);
        progressMessage(message);
    }, Qt::QueuedConnection);
}

void UniDeskThemeManager::reportError(const QString &message) {
    QMetaObject::invokeMethod(this, [this, message]() {
        Q_EMIT errorOccurred(message);
    }, Qt::QueuedConnection);
}

void UniDeskThemeManager::reportFinished(bool success, const QString &message) {
    QMetaObject::invokeMethod(this, [this, success, message]() {
        if (success) progress(1.0);
        isWorking(false);
        Q_EMIT finished(success, message);
    }, Qt::QueuedConnection);
}

void UniDeskThemeManager::saveTheme(const QString &themeDir) {
    if (isWorking()) {
        Q_EMIT errorOccurred(tr("已有保存任务正在进行"));
        return;
    }

    QString safeDir = themeDir;
    safeDir.replace("\\", "/");

    if (safeDir.startsWith("file:/", Qt::CaseInsensitive)) {
        QUrl url(safeDir);
        safeDir = url.toLocalFile();
    }

    if (safeDir.isEmpty()) {
        Q_EMIT errorOccurred(tr("保存路径不能为空"));
        return;
    }

    QFileInfo info(safeDir);
    QString absolutePath = info.absoluteFilePath();

    if (info.exists() && !info.isDir()) {
        Q_EMIT errorOccurred(tr("路径不是目录: %1").arg(absolutePath));
        return;
    }

    QDir dir(absolutePath);
    if (!dir.exists()) {
        if (!dir.mkpath(absolutePath)) {
            Q_EMIT errorOccurred(tr("无法创建主题目录: %1").arg(absolutePath));
            return;
        }
    }

    isWorking(true);
    progress(0.0);
    progressMessage(tr("准备保存..."));

    QThreadPool::globalInstance()->start([this, absolutePath]() { doSaveTheme(absolutePath); });
}

void UniDeskThemeManager::loadTheme(const QString &themeDir) {
    if (isWorking()) {
        Q_EMIT errorOccurred(tr("已有任务正在进行"));
        return;
    }

    QString safeDir = themeDir;
    safeDir.replace("\\", "/");

    if (safeDir.startsWith("file:/", Qt::CaseInsensitive)) {
        QUrl url(safeDir);
        safeDir = url.toLocalFile();
    }

    if (safeDir.isEmpty()) {
        Q_EMIT errorOccurred(tr("加载路径不能为空"));
        return;
    }

    QFileInfo info(safeDir);
    QString absolutePath = info.absoluteFilePath();

    if (!info.exists() || !info.isDir()) {
        Q_EMIT errorOccurred(tr("主题目录不存在: %1").arg(absolutePath));
        return;
    }

    if (!QFile::exists(absolutePath + "/settings.json") &&
        !QFile::exists(absolutePath + "/components.json") &&
        !QDir(absolutePath + "/media").exists() &&
        !QDir(absolutePath + "/plugins").exists()) {
        Q_EMIT errorOccurred(tr("该目录不包含有效主题文件"));
        return;
    }

    isWorking(true);
    progress(0.0);
    progressMessage(tr("准备加载..."));
    QThreadPool::globalInstance()->start([this, absolutePath]() { doLoadTheme(absolutePath); });
}

void UniDeskThemeManager::doSaveTheme(const QString &themeDir) {
    m_usedMediaNames.clear();
    m_sourceToRelPath.clear();

    QString mediaDir = themeDir + "/media";
    QString pluginsDir = themeDir + "/plugins";
    QString settingsFilePath = themeDir + "/settings.json";
    QString componentsFilePath = themeDir + "/components.json";

    QDir().mkpath(mediaDir);
    QDir().mkpath(pluginsDir);

    reportProgress(0.05, tr("正在保存外观设置..."));

    QVariantMap settingsMap = UniDeskSettings::getInstance()->getAll().toMap();
    QJsonObject settingsObj;
    for (auto it = settingsMap.begin(); it != settingsMap.end(); ++it) {
        if (!UniDeskSettings::isAppearanceProperty(it.key())) continue;
        const QVariant &var = it.value();
        const QString &key = it.key();
        if (var.typeId() == qMetaTypeId<QColor>()) {
            QColor c = var.value<QColor>();
            QJsonObject colorObj;
            colorObj["<type>"] = "QColor";
            colorObj["red"] = c.red();
            colorObj["green"] = c.green();
            colorObj["blue"] = c.blue();
            colorObj["alpha"] = c.alpha();
            settingsObj[key] = colorObj;
        } else if (var.typeId() == qMetaTypeId<QVariantList>()) {
            QJsonArray arr;
            for (const QVariant &v : var.toList()) {
                if (v.typeId() == qMetaTypeId<QColor>()) {
                    QColor c = v.value<QColor>();
                    QJsonObject colorObj;
                    colorObj["<type>"] = "QColor";
                    colorObj["red"] = c.red();
                    colorObj["green"] = c.green();
                    colorObj["blue"] = c.blue();
                    colorObj["alpha"] = c.alpha();
                    arr.append(colorObj);
                } else {
                    arr.append(QJsonValue::fromVariant(v));
                }
            }
            settingsObj[key] = arr;
        } else {
            settingsObj[key] = QJsonValue::fromVariant(var);
        }
    }

    {
        QJsonValue settingsValue(settingsObj);
        processJsonValue(settingsValue, mediaDir);
        settingsObj = settingsValue.toObject();
    }

    {
        prepareOverwrite(settingsFilePath);
        QFile f(settingsFilePath);
        if (!f.open(QIODevice::WriteOnly | QIODevice::Text)) {
            reportError(tr("无法写入文件: %1").arg(settingsFilePath));
            reportFinished(false, tr("保存失败"));
            return;
        }
        QJsonDocument doc(settingsObj);
        f.write(doc.toJson(QJsonDocument::Indented));
        f.close();
    }

    reportProgress(0.30, tr("正在复制插件..."));
    QDir sourcePluginsDir(pluginRootPath);
    QStringList pluginSubDirs;
    if (sourcePluginsDir.exists()) {
        pluginSubDirs = sourcePluginsDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
    }
    int pluginCount = pluginSubDirs.size();
    if (pluginCount == 0) pluginCount = 1;

    for (int i = 0; i < (int)pluginSubDirs.size(); ++i) {
        const QString &pluginName = pluginSubDirs[i];
        QString src = pluginRootPath + "/" + pluginName;
        QString dst = pluginsDir + "/" + pluginName;
        // 保存主题时完整复制（含 DLL），确保加载主题后重启可完整替换 plugins
        if (!copyPathRecursive(src, dst, false)) {
            reportError(tr("复制插件失败: %1").arg(pluginName));
            reportFinished(false, tr("保存失败"));
            return;
        }
        reportProgress(0.30 + 0.40 * (i + 1) / pluginCount, tr("正在复制插件: %1").arg(pluginName));
    }

    reportProgress(0.75, tr("正在保存组件信息..."));
    QJsonObject componentsObj;
    componentsObj["pages"] = UniDeskComponentsData::getInstance()->getPages();
    componentsObj["components"] = UniDeskComponentsData::getInstance()->getComponents();
    componentsObj["currentPid"] = UniDeskComponentsData::getInstance()->getCurrentPage();

    {
        QJsonValue componentsValue(componentsObj);
        processJsonValue(componentsValue, mediaDir);
        componentsObj = componentsValue.toObject();
    }

    {
        prepareOverwrite(componentsFilePath);
        QFile f(componentsFilePath);
        if (!f.open(QIODevice::WriteOnly | QIODevice::Text)) {
            reportError(tr("无法写入文件: %1").arg(componentsFilePath));
            reportFinished(false, tr("保存失败"));
            return;
        }
        QJsonDocument doc(componentsObj);
        f.write(doc.toJson(QJsonDocument::Indented));
        f.close();
    }

    reportProgress(0.90, tr("正在同步模版库..."));
    {
        QString srcTempletesDir = dataRootPath + "/templetes";
        QString dstTempletesDir = themeDir + "/templetes";
        if (QDir(srcTempletesDir).exists()) {
            if (QDir(dstTempletesDir).exists()) {
                QDir(dstTempletesDir).removeRecursively();
            }
            QDir().mkpath(dstTempletesDir);
            copyPathRecursive(srcTempletesDir, dstTempletesDir, false);
        }
    }

    reportProgress(1.0, tr("保存完成"));
    reportFinished(true, tr("主题已保存至: %1").arg(themeDir));
}

void UniDeskThemeManager::processJsonValue(QJsonValue &value, const QString &mediaDir) {
    if (value.isString()) {
        QString str = value.toString();
        QString absPath = extractAbsolutePath(str);
        if (!absPath.isEmpty()) {
            QString newPath = copyMediaFile(absPath, mediaDir);
            if (!newPath.isEmpty()) {
                value = QJsonValue(newPath);
            }
        }
    } else if (value.isArray()) {
        QJsonArray arr = value.toArray();
        for (int i = 0; i < arr.size(); ++i) {
            QJsonValue child = arr[i];
            processJsonValue(child, mediaDir);
            arr[i] = child;
        }
        value = arr;
    } else if (value.isObject()) {
        QJsonObject obj = value.toObject();
        for (auto it = obj.begin(); it != obj.end(); ++it) {
            QJsonValue child = it.value();
            processJsonValue(child, mediaDir);
            obj[it.key()] = child;
        }
        value = obj;
    }
}

QString UniDeskThemeManager::copyMediaFile(const QString &absPath, const QString &mediaDir) {
    auto it = m_sourceToRelPath.find(absPath);
    if (it != m_sourceToRelPath.end()) {
        return it.value();
    }

    QFileInfo info(absPath);
    bool isDir = info.isDir();
    QString baseName = isDir ? info.fileName() : info.completeBaseName();
    QString ext = (isDir || info.suffix().isEmpty()) ? QString() : ("." + info.suffix());

    QString newName = baseName + ext;
    if (m_usedMediaNames.contains(newName)) {
        int counter = 1;
        QString candidate = baseName + "_" + QString::number(counter) + ext;
        while (m_usedMediaNames.contains(candidate)) {
            ++counter;
            candidate = baseName + "_" + QString::number(counter) + ext;
        }
        newName = candidate;
    }
    m_usedMediaNames.insert(newName);

    QString destPath = mediaDir + "/" + newName;
    QString relPath = "media/" + newName;

    bool ok = false;
    if (isDir) {
        ok = copyPathRecursive(absPath, destPath, false);
    } else {
        prepareOverwrite(destPath);
        ok = QFile::copy(absPath, destPath);
    }
    if (!ok) return QString();

    m_sourceToRelPath.insert(absPath, relPath);
    return relPath;
}

bool UniDeskThemeManager::copyPathRecursive(const QString &src, const QString &dst, bool skipDll) {
    QDir srcDir(src);
    if (!srcDir.exists()) return false;

    QDir dstDir(dst);
    if (!dstDir.exists()) {
        if (!dstDir.mkpath(dst)) return false;
    }

    QStringList files = srcDir.entryList(QDir::Files);
    for (const QString &file : files) {
        bool isDll = file.endsWith(".dll", Qt::CaseInsensitive);
        if (skipDll && isDll) continue;

        QString srcFile = src + "/" + file;
        QString dstFile = dst + "/" + file;

        // 目标已存在：先尝试删除
        if (QFile::exists(dstFile)) {
            if (!prepareOverwrite(dstFile)) {
                // 删不掉
                if (skipDll) {
                    // skipDll 模式下单个文件复制失败不中断（重启后会完整替换 plugins）
                    continue;
                } else {
                    return false;
                }
            }
        }

        if (!QFile::copy(srcFile, dstFile)) {
            if (skipDll) {
                continue;  // skipDll 模式下单个文件失败跳过
            } else {
                return false;
            }
        }
    }

    QStringList dirs = srcDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
    for (const QString &dir : dirs) {
        // 子目录：skipDll 模式下也继续递归，不因为单个子目录失败就中断
        bool subOk = copyPathRecursive(src + "/" + dir, dst + "/" + dir, skipDll);
        if (!subOk && !skipDll) return false;
    }

    return true;
}

QString UniDeskThemeManager::extractAbsolutePath(const QString &str) {
    if (str.isEmpty()) return QString();

    QUrl url(str);
    if (url.isLocalFile()) {
        QString local = url.toLocalFile();
        QFileInfo info(local);
        if (info.isAbsolute() && info.exists()) return info.absoluteFilePath();
    }

    static QRegularExpression winPathRe("^[A-Za-z]:[\\\\/].+");
    static QRegularExpression unixPathRe("^/.");

    if (winPathRe.match(str).hasMatch() || unixPathRe.match(str).hasMatch()) {
        QFileInfo info(str);
        if (info.exists() && info.isAbsolute()) return info.absoluteFilePath();
    }

    return QString();
}

bool UniDeskThemeManager::clearDirectory(const QString &path) {
    QDir dir(path);
    if (!dir.exists()) return dir.mkpath(path);
    for (const QString &entry : dir.entryList(QDir::Dirs | QDir::Files | QDir::NoDotAndDotDot)) {
        QString entryPath = path + "/" + entry;
        if (QFileInfo(entryPath).isDir()) {
            QDir subDir(entryPath);
            if (!subDir.removeRecursively()) return false;
        } else {
            QFile f(entryPath);
            f.setPermissions(f.permissions() | QFile::WriteOwner);
            if (!f.remove()) return false;
        }
    }
    return true;
}

// 局部 helper：递归清理一个目录，尽量删除所有文件；DLL 删不掉时记录单个文件路径到 markDlls
static void clearPluginsDirRecursivelyHelper(const QString &path, QStringList &markDlls) {
    QDir dir(path);
    if (!dir.exists()) return;
    const auto entries = dir.entryList(QDir::Dirs | QDir::Files | QDir::NoDotAndDotDot);
    for (const QString &entry : entries) {
        QString entryPath = path + "/" + entry;
        if (QFileInfo(entryPath).isDir()) {
            // 递归进入子目录清理
            clearPluginsDirRecursivelyHelper(entryPath, markDlls);
            // 子目录清理完后尝试删空目录本身
            QDir(entryPath).rmdir(entryPath);
        } else {
            QFile sf(entryPath);
            sf.setPermissions(sf.permissions() | QFile::WriteOwner);
            if (!sf.remove()) {
                // 删不掉：如果是 DLL，只记录该 DLL 文件路径（重启后只删这个 DLL）
                if (entryPath.endsWith(".dll", Qt::CaseInsensitive)) {
                    markDlls.append(entryPath);
                }
                // 非 DLL 删不掉静默忽略（一般不会出现，避免中断复制）
            }
        }
    }
}

bool UniDeskThemeManager::clearPluginsDirPartially(const QString &path, const QStringList &markList) {
    QDir dir(path);
    if (!dir.exists()) return dir.mkpath(path);

    const auto entries = dir.entryList(QDir::Dirs | QDir::Files | QDir::NoDotAndDotDot);
    for (const QString &entry : entries) {
        QString entryPath = path + "/" + entry;
        if (QFileInfo(entryPath).isDir()) {
            // 递归清理子目录内容（删不掉的 DLL 只记录文件本身）
            clearPluginsDirRecursivelyHelper(entryPath, const_cast<QStringList&>(markList));
            QDir(entryPath).rmdir(entryPath);
        } else {
            QFile f(entryPath);
            f.setPermissions(f.permissions() | QFile::WriteOwner);
            if (!f.remove()) {
                if (entryPath.endsWith(".dll", Qt::CaseInsensitive)) {
                    if (!const_cast<QStringList&>(markList).contains(entryPath)) {
                        const_cast<QStringList&>(markList).append(entryPath);
                    }
                }
                // 非 DLL 删不掉静默忽略
            }
        }
    }
    return true;
}

void UniDeskThemeManager::processJsonValueForLoad(QJsonValue &value, const QString &mediaDir, const QHash<QString, QString> &renameMap) {
    if (value.isString()) {
        QString str = value.toString();
        if (str.startsWith("media/")) {
            QString relName = str.mid(6);
            auto it = renameMap.find(relName);
            if (it != renameMap.end()) {
                relName = it.value();
            }
            QString localPath = mediaDir + "/" + relName;
            value = QJsonValue(QUrl::fromLocalFile(localPath).toString());
        }
    } else if (value.isArray()) {
        QJsonArray arr = value.toArray();
        for (int i = 0; i < arr.size(); ++i) {
            QJsonValue child = arr[i];
            processJsonValueForLoad(child, mediaDir, renameMap);
            arr[i] = child;
        }
        value = arr;
    } else if (value.isObject()) {
        QJsonObject obj = value.toObject();
        for (auto it = obj.begin(); it != obj.end(); ++it) {
            QJsonValue child = it.value();
            processJsonValueForLoad(child, mediaDir, renameMap);
            obj[it.key()] = child;
        }
        value = obj;
    }
}

void UniDeskThemeManager::doLoadTheme(const QString &themeDir) {
    
    QString appDataDir = QCoreApplication::applicationDirPath() + "/data";
    QString appMediaDir = appDataDir + "/media";
    QString appPluginsDir = appDataDir + "/plugins";
    QString appSettingsFile = appDataDir + "/settings.json";
    QString appComponentsFile = appDataDir + "/components.json";

    QString themeMediaDir = themeDir + "/media";
    QString themePluginsDir = themeDir + "/plugins";
    QString themeSettingsFile = themeDir + "/settings.json";
    QString themeComponentsFile = themeDir + "/components.json";
    // 1. 部分清空 media 目录：逐个删除文件，删不掉的标记重启后删除
    QHash<QString, QString> mediaRenameMap;
    reportProgress(0.05, tr("正在清理 media 目录..."));
    {
        QStringList mediaMarkList;
        clearMediaDirPartially(appMediaDir, mediaMarkList);
        for (const QString &mediaPath : mediaMarkList) {
            markMediaForDeletion(mediaPath);
        }
    }
    // 2. 部分清空 plugins 目录（DLL 删除失败时只记录该 DLL 文件路径，不报错）
    reportProgress(0.10, tr("正在清理插件目录..."));
    QStringList markList;
    if (!clearPluginsDirPartially(appPluginsDir, markList)) {
        reportError(tr("无法清理 plugins 目录"));
        reportFinished(false, tr("加载失败"));
        return;
    }
    // 清理阶段删不掉的 DLL，记录到 pending_dll_ops.json 的 deletes 数组，重启后删除
    for (const QString &dll : markList) {
        markDllForDeletion(dll);
    }
    // 3. 复制 media：遇到同名冲突（包括与未删除的历史文件冲突）加数字后缀，记录改名映射
    reportProgress(0.20, tr("正在复制 media..."));
    if (QDir(themeMediaDir).exists()) {
        if (!copyMediaDirWithRename(themeMediaDir, appMediaDir, mediaRenameMap)) {
            reportError(tr("复制 media 失败"));
            reportFinished(false, tr("加载失败"));
            return;
        }
    }
    // 4. 复制 plugins：非 DLL 直接复制到 appPluginsDir；DLL 复制到临时目录 .pending_plugins_temp，
    //    重启后再从临时目录复制到 appPluginsDir（此时 DLL 未锁定）
    reportProgress(0.35, tr("正在复制插件..."));
    bool hasThemePlugins = QDir(themePluginsDir).exists();
    QString pendingPluginsTempDir = dataRootPath + "/.pending_plugins_temp";
    if (hasThemePlugins) {
        // 4a. 复制非 DLL 到 data/plugins（运行时可写）
        copyPathRecursive(themePluginsDir, appPluginsDir, true);

        // 4b. 清空临时目录，把主题 plugins 中所有 DLL 复制到临时目录（保持相对路径结构）
        clearDirectory(pendingPluginsTempDir);
        // 递归收集主题 plugins 中所有 DLL 路径，并同时复制到临时目录
        std::function<void(const QString&, const QString&)> collectDllPaths = [&](const QString &src, const QString &tmp) {
            QDir srcDir(src);
            if (!srcDir.exists()) return;
            QDir tmpDir(tmp);
            if (!tmpDir.exists()) tmpDir.mkpath(tmp);
            for (const QString &file : srcDir.entryList(QDir::Files)) {
                if (!file.endsWith(".dll", Qt::CaseInsensitive)) continue;
                QString srcFile = src + "/" + file;
                QString tmpFile = tmp + "/" + file;
                prepareOverwrite(tmpFile);
                QFile::copy(srcFile, tmpFile);
            }
            for (const QString &sub : srcDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot)) {
                collectDllPaths(src + "/" + sub, tmp + "/" + sub);
            }
        };
        collectDllPaths(themePluginsDir, pendingPluginsTempDir);

        // 4c. 收集临时目录中所有 DLL 路径，记录重启后要从临时复制到目标的任务
        std::function<void(const QString&, const QString&)> recordDllCopies = [&](const QString &tmp, const QString &dst) {
            QDir tmpDir(tmp);
            if (!tmpDir.exists()) return;
            for (const QString &file : tmpDir.entryList(QDir::Files)) {
                if (!file.endsWith(".dll", Qt::CaseInsensitive)) continue;
                markDllForCopy(tmp + "/" + file, dst + "/" + file);
            }
            for (const QString &sub : tmpDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot)) {
                recordDllCopies(tmp + "/" + sub, dst + "/" + sub);
            }
        };
        recordDllCopies(pendingPluginsTempDir, appPluginsDir);
    }

    // 5. 复制 components.json，转换 media 相对路径 → 绝对路径，并重新分配组件/页面 UUID
    reportProgress(0.55, tr("正在复制组件信息..."));
    if (QFile::exists(themeComponentsFile)) {
        prepareOverwrite(appComponentsFile);
        if (!QFile::copy(themeComponentsFile, appComponentsFile)) {
            reportError(tr("复制 components.json 失败"));
            reportFinished(false, tr("加载失败"));
            return;
        }
        // 5a. 转换 components.json 中的 media/ 相对路径为绝对路径
        QFile cf(appComponentsFile);
        if (cf.open(QIODevice::ReadOnly | QIODevice::Text)) {
            QJsonDocument doc = QJsonDocument::fromJson(cf.readAll());
            cf.close();
            QJsonValue rootVal = doc.object();
            processJsonValueForLoad(rootVal, appMediaDir, mediaRenameMap);
            prepareOverwrite(appComponentsFile);
            if (cf.open(QIODevice::WriteOnly | QIODevice::Text)) {
                cf.write(QJsonDocument(rootVal.toObject()).toJson(QJsonDocument::Indented));
                cf.close();
            }
        }
        reportProgress(0.60, tr("正在重新分配组件 UUID..."));
        if (!processComponentsReassignUuids(appComponentsFile)) {
            reportError(tr("重分配组件 UUID 失败"));
            reportFinished(false, tr("加载失败"));
            return;
        }
    }

    // 6. 合并外观设置，路径 media 相对 → 绝对
    reportProgress(0.70, tr("正在加载外观设置..."));
    if (QFile::exists(themeSettingsFile)) {
        QFile tf(themeSettingsFile);
        if (!tf.open(QIODevice::ReadOnly | QIODevice::Text)) {
            reportError(tr("无法读取主题设置文件"));
            reportFinished(false, tr("加载失败"));
            return;
        }
        QJsonObject themeSettings = QJsonDocument::fromJson(tf.readAll()).object();
        tf.close();

        QFile af(appSettingsFile);
        QJsonObject appSettings;
        if (af.exists() && af.open(QIODevice::ReadOnly | QIODevice::Text)) {
            appSettings = QJsonDocument::fromJson(af.readAll()).object();
            af.close();
        }

        for (auto it = themeSettings.begin(); it != themeSettings.end(); ++it) {
            QString key = it.key();
            if (!UniDeskSettings::isAppearanceProperty(key)) continue;
            QJsonValue val = it.value();
            processJsonValueForLoad(val, appMediaDir, mediaRenameMap);
            appSettings[key] = val;
        }

        prepareOverwrite(appSettingsFile);
        QFile wf(appSettingsFile);
        if (!wf.open(QIODevice::WriteOnly | QIODevice::Text)) {
            reportError(tr("无法写入设置文件"));
            reportFinished(false, tr("加载失败"));
            return;
        }
        QJsonDocument doc(appSettings);
        wf.write(doc.toJson(QJsonDocument::Indented));
        wf.close();
    }

    // 7. pending_dll_ops.json 已在前面 markDllForDeletion / markDllForCopy 调用中写入，无需额外处理

    // 7a. 清空 data/templetes，复制主题包中的 templetes 目录到 data/templetes
    reportProgress(0.85, tr("正在同步模版库..."));
    {
        QString appTempletesDir = dataRootPath + "/templetes";
        QString themeTempletesDir = themeDir + "/templetes";
        if (QDir(appTempletesDir).exists()) {
            QDir(appTempletesDir).removeRecursively();
        }
        QDir().mkpath(appTempletesDir);
        if (QDir(themeTempletesDir).exists()) {
            copyPathRecursive(themeTempletesDir, appTempletesDir, false);
        }
    }

    // 8. 完成，通知用户后自动重启
    reportProgress(0.95, tr("文件已写入，即将重启..."));
    reportFinished(true, tr("主题已写入，程序将自动重启"));

    reportProgress(1.0, QString());
    QMetaObject::invokeMethod(this, []() {
        restartApp();
    }, Qt::QueuedConnection);
}

void UniDeskThemeManager::restartApp() {
    // 启动新实例时附加 --restarting 参数，跳过防多开检查
    QStringList arguments = QCoreApplication::arguments().mid(1);
    arguments.append("--restarting");

    // 延迟 300ms 再退出，确保 finished 信号提示显示
    QTimer::singleShot(300, QCoreApplication::instance(), [arguments]() {
        QProcess::startDetached(QCoreApplication::applicationFilePath(),
                                arguments,
                                QCoreApplication::applicationDirPath());
        QCoreApplication::quit();
    });
}

bool UniDeskThemeManager::processComponentsReassignUuids(const QString &componentsFile) {
    QFile f(componentsFile);
    if (!f.open(QIODevice::ReadOnly | QIODevice::Text)) return false;
    QJsonObject root = QJsonDocument::fromJson(f.readAll()).object();
    f.close();

    // 1. 页面 pid 映射（保留 default 不变，initLayerNodes 等写死使用 default）
    QMap<QString, QString> pidMap;
    QJsonArray pages = root.value("pages").toArray();
    QJsonArray newPages;
    for (const QJsonValue &pv : pages) {
        QJsonObject po = pv.toObject();
        QString oldPid = po.value("pid").toString();
        if (oldPid.isEmpty() || oldPid == QStringLiteral("default")) {
            newPages.append(po);
            continue;
        }
        QString newPid = QUuid::createUuid().toString();
        pidMap.insert(oldPid, newPid);
        po["pid"] = newPid;
        newPages.append(po);
    }
    root["pages"] = newPages;

    // 2. currentPid 更新
    QString currentPid = root.value("currentPid").toString();
    if (pidMap.contains(currentPid)) {
        root["currentPid"] = pidMap.value(currentPid);
    }

    // 3. 组件 identification 映射（Wallpaper/Desktop/TopMost 是内置层写死的，不能换）
    static const QSet<QString> s_builtinIds{QStringLiteral("Wallpaper"), QStringLiteral("Desktop"), QStringLiteral("TopMost")};
    QMap<QString, QString> idMap;
    QJsonArray components = root.value("components").toArray();
    QJsonArray firstPass;
    for (const QJsonValue &cv : components) {
        QJsonObject co = cv.toObject();
        QString oldId = co.value("identification").toString();
        if (oldId.isEmpty() || s_builtinIds.contains(oldId)) {
            firstPass.append(cv);
            continue;
        }
        QString newId = QUuid::createUuid().toString();
        idMap.insert(oldId, newId);
        co["identification"] = newId;
        firstPass.append(co);
    }

    // 4. 第二遍：更新 pageid / parent 引用，并递归扫嵌套对象中的 id 引用
    QJsonArray newComponents;
    for (const QJsonValue &cv : firstPass) {
        QJsonObject co = cv.toObject();
        QString pageid = co.value("pageid").toString();
        if (!pageid.isEmpty() && pidMap.contains(pageid)) {
            co["pageid"] = pidMap.value(pageid);
        }
        QString parentId = co.value("parent").toString();
        if (!parentId.isEmpty() && idMap.contains(parentId)) {
            co["parent"] = idMap.value(parentId);
        }
        QJsonObject rewritten = co;
        std::function<void(QJsonValue&)> rewriteIds = [&](QJsonValue &v) {
            if (v.isString()) {
                QString s = v.toString();
                if (!s.isEmpty() && idMap.contains(s)) { v = QJsonValue(idMap.value(s)); }
                else if (!s.isEmpty() && pidMap.contains(s)) { v = QJsonValue(pidMap.value(s)); }
            } else if (v.isArray()) {
                QJsonArray arr = v.toArray();
                for (int i = 0; i < arr.size(); ++i) { QJsonValue item = arr[i]; rewriteIds(item); arr[i] = item; }
                v = arr;
            } else if (v.isObject()) {
                QJsonObject obj = v.toObject();
                for (auto it = obj.begin(); it != obj.end(); ++it) { QJsonValue item = it.value(); rewriteIds(item); obj[it.key()] = item; }
                v = obj;
            }
        };
        QJsonValue rv = rewritten;
        rewriteIds(rv);
        newComponents.append(rv.toObject());
    }
    root["components"] = newComponents;

    prepareOverwrite(componentsFile);
    QFile wf(componentsFile);
    if (!wf.open(QIODevice::WriteOnly | QIODevice::Text)) return false;
    wf.write(QJsonDocument(root).toJson(QJsonDocument::Indented));
    wf.close();
    return true;
}

void UniDeskThemeManager::markDllForDeletion(const QString &dllPath) {
    QJsonObject root;
    QJsonArray arr;
    QFile f(pendingDllOpsFile);
    if (f.exists() && f.open(QIODevice::ReadOnly | QIODevice::Text)) {
        root = QJsonDocument::fromJson(f.readAll()).object();
        f.close();
        arr = root.value("deletes").toArray();
    }
    QString pathSafe = dllPath;
    pathSafe.replace("\\", "/");
    bool exists = false;
    for (const QJsonValue &v : arr) {
        if (v.toString() == pathSafe) { exists = true; break; }
    }
    if (!exists) arr.append(pathSafe);
    root["deletes"] = arr;
    QFile::remove(pendingDllOpsFile);
    QDir().mkpath(QFileInfo(pendingDllOpsFile).path());
    QFile wf(pendingDllOpsFile);
    if (wf.open(QIODevice::WriteOnly | QIODevice::Text)) {
        wf.write(QJsonDocument(root).toJson(QJsonDocument::Indented));
        wf.close();
    }
}

void UniDeskThemeManager::markDllForCopy(const QString &srcDll, const QString &dstDll) {
    QJsonObject root;
    QJsonArray arr;
    QFile f(pendingDllOpsFile);
    if (f.exists() && f.open(QIODevice::ReadOnly | QIODevice::Text)) {
        root = QJsonDocument::fromJson(f.readAll()).object();
        f.close();
        arr = root.value("copies").toArray();
    }
    QString srcSafe = srcDll;
    srcSafe.replace("\\", "/");
    QString dstSafe = dstDll;
    dstSafe.replace("\\", "/");
    bool exists = false;
    for (const QJsonValue &v : arr) {
        QJsonObject o = v.toObject();
        if (o.value("src").toString() == srcSafe && o.value("dst").toString() == dstSafe) {
            exists = true; break;
        }
    }
    if (!exists) {
        QJsonObject item;
        item["src"] = srcSafe;
        item["dst"] = dstSafe;
        arr.append(item);
    }
    root["copies"] = arr;
    QFile::remove(pendingDllOpsFile);
    QDir().mkpath(QFileInfo(pendingDllOpsFile).path());
    QFile wf(pendingDllOpsFile);
    if (wf.open(QIODevice::WriteOnly | QIODevice::Text)) {
        wf.write(QJsonDocument(root).toJson(QJsonDocument::Indented));
        wf.close();
    }
}

void UniDeskThemeManager::cleanupPendingDeletesAtStartup() {
    if (!QFile::exists(pendingDllOpsFile)) return;

    QFile f(pendingDllOpsFile);
    if (!f.open(QIODevice::ReadOnly | QIODevice::Text)) return;
    QJsonObject root = QJsonDocument::fromJson(f.readAll()).object();
    f.close();

    // A. 删除所有标记的 DLL 文件（此时 DLL 未加载，可以删除）
    QJsonArray deletes = root.value("deletes").toArray();
    for (const QJsonValue &v : deletes) {
        QString dllPath = v.toString();
        if (dllPath.isEmpty()) continue;
        QFile sf(dllPath);
        sf.setPermissions(sf.permissions() | QFile::WriteOwner);
        if (sf.remove()) {
            // 尝试删除空的父插件目录
            QDir().rmdir(QFileInfo(dllPath).absolutePath());
        }
    }

    // B. 按记录的 copy 任务把临时目录中的 DLL 复制到目标位置
    QJsonArray copies = root.value("copies").toArray();
    for (const QJsonValue &v : copies) {
        QJsonObject item = v.toObject();
        QString src = item.value("src").toString();
        QString dst = item.value("dst").toString();
        if (src.isEmpty() || dst.isEmpty()) continue;
        if (!QFile::exists(src)) continue;
        QDir().mkpath(QFileInfo(dst).absolutePath());
        prepareOverwrite(dst);
        QFile::copy(src, dst);
    }

    // C. 清理临时目录和 pending 文件
    if (QDir(pendingPluginsTempDir).exists()) {
        QDir(pendingPluginsTempDir).removeRecursively();
    }
    QFile::remove(pendingDllOpsFile);
}

bool UniDeskThemeManager::clearMediaDirPartially(const QString &path, QStringList &markList) {
    QDir dir(path);
    if (!dir.exists()) return dir.mkpath(path);

    const auto entries = dir.entryList(QDir::Dirs | QDir::Files | QDir::NoDotAndDotDot);
    for (const QString &entry : entries) {
        QString entryPath = path + "/" + entry;
        if (QFileInfo(entryPath).isDir()) {
            clearMediaDirPartially(entryPath, markList);
            QDir(entryPath).rmdir(entryPath);
        } else {
            QFile f(entryPath);
            f.setPermissions(f.permissions() | QFile::WriteOwner);
            if (!f.remove()) {
                if (!markList.contains(entryPath)) {
                    markList.append(entryPath);
                }
            }
        }
    }
    return true;
}

bool UniDeskThemeManager::copyMediaDirWithRename(const QString &src, const QString &dst, QHash<QString, QString> &renameMap) {
    QDir srcDir(src);
    if (!srcDir.exists()) return false;

    QDir dstDir(dst);
    if (!dstDir.exists()) {
        if (!dstDir.mkpath(dst)) return false;
    }

    auto resolveUniqueName = [](const QString &dstDir, const QString &baseName, const QString &ext) {
        QString candidate = baseName + ext;
        int counter = 0;
        while (QFile::exists(dstDir + "/" + candidate)) {
            ++counter;
            candidate = baseName + "_" + QString::number(counter) + ext;
        }
        return candidate;
    };

    for (const QString &file : srcDir.entryList(QDir::Files)) {
        QString srcFile = src + "/" + file;
        QFileInfo info(file);
        QString baseName = info.completeBaseName();
        QString ext = info.suffix().isEmpty() ? QString() : ("." + info.suffix());

        QString finalName = resolveUniqueName(dst, baseName, ext);
        QString dstFile = dst + "/" + finalName;

        if (finalName != file) {
            renameMap.insert(file, finalName);
        }

        if (!QFile::copy(srcFile, dstFile)) {
            return false;
        }
    }

    for (const QString &sub : srcDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot)) {
        if (!copyMediaDirWithRename(src + "/" + sub, dst + "/" + sub, renameMap)) {
            return false;
        }
    }
    return true;
}

void UniDeskThemeManager::markMediaForDeletion(const QString &mediaPath) {
    QJsonObject root;
    QJsonArray arr;
    QFile f(pendingMediaOpsFile);
    if (f.exists() && f.open(QIODevice::ReadOnly | QIODevice::Text)) {
        root = QJsonDocument::fromJson(f.readAll()).object();
        f.close();
        arr = root.value("deletes").toArray();
    }
    QString pathSafe = mediaPath;
    pathSafe.replace("\\", "/");
    bool exists = false;
    for (const QJsonValue &v : arr) {
        if (v.toString() == pathSafe) { exists = true; break; }
    }
    if (!exists) arr.append(pathSafe);
    root["deletes"] = arr;
    QFile::remove(pendingMediaOpsFile);
    QDir().mkpath(QFileInfo(pendingMediaOpsFile).path());
    QFile wf(pendingMediaOpsFile);
    if (wf.open(QIODevice::WriteOnly | QIODevice::Text)) {
        wf.write(QJsonDocument(root).toJson(QJsonDocument::Indented));
        wf.close();
    }
}

void UniDeskThemeManager::cleanupPendingMediaDeletesAtStartup() {
    if (!QFile::exists(pendingMediaOpsFile)) return;

    QFile f(pendingMediaOpsFile);
    if (!f.open(QIODevice::ReadOnly | QIODevice::Text)) return;
    QJsonObject root = QJsonDocument::fromJson(f.readAll()).object();
    f.close();

    QJsonArray deletes = root.value("deletes").toArray();
    for (const QJsonValue &v : deletes) {
        QString mediaPath = v.toString();
        if (mediaPath.isEmpty()) continue;
        QFile sf(mediaPath);
        sf.setPermissions(sf.permissions() | QFile::WriteOwner);
        if (sf.remove()) {
            QDir().rmdir(QFileInfo(mediaPath).absolutePath());
        }
    }

    QFile::remove(pendingMediaOpsFile);
}



