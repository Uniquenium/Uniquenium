#include "UniDeskTempleteMgr.h"
#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QUrl>
#include <QJsonDocument>
#include <QRegularExpression>
#include <QThreadPool>
#include <QUuid>
#include <QDateTime>
#include <functional>
#include <QSet>

static QString dataRootPath = QCoreApplication::applicationDirPath() + "/data";
static QString templetesRootPath = dataRootPath + "/templetes";

UniDeskTempleteMgr::UniDeskTempleteMgr(QQuickItem *parent)
    : QQuickItem(parent), _isWorking(false), m_watcher(nullptr) {
    QDir().mkpath(templetesRootPath);
    m_watcher = new QFileSystemWatcher(this);
    m_watcher->addPath(templetesRootPath);
    connect(m_watcher, &QFileSystemWatcher::directoryChanged, this, [this](const QString &){
        refreshTempleteList();
    });
    refreshTempleteList();
}

void UniDeskTempleteMgr::saveTemplete(const QJsonArray &components, const QString &name) {
    QString safeName = name.trimmed();
    if (safeName.isEmpty()) {
        Q_EMIT errorOccurred(tr("模版名称不能为空"));
        return;
    }
    static QRegularExpression invalidRe("[\\\\/:*?\"<>|]");
    if (invalidRe.match(safeName).hasMatch()) {
        Q_EMIT errorOccurred(tr("模版名称包含非法字符"));
        return;
    }
    if (components.isEmpty()) {
        Q_EMIT errorOccurred(tr("没有选中任何组件"));
        return;
    }

    QString templeteDir = templetesRootPath + "/" + safeName;
    if (!QDir().mkpath(templeteDir)) {
        Q_EMIT errorOccurred(tr("无法创建模版目录: %1").arg(templeteDir));
        return;
    }

    isWorking(true);
    QJsonArray componentsCopy = components;
    QString dirCopy = templeteDir;
    QThreadPool::globalInstance()->start([this, componentsCopy, safeName, dirCopy]() {
        doSaveTemplete(componentsCopy, safeName, dirCopy);
    });
}

void UniDeskTempleteMgr::doSaveTemplete(const QJsonArray &components, const QString &name, const QString &templeteDir) {
    m_usedMediaNames.clear();
    m_sourceToRelPath.clear();

    QString mediaDir = templeteDir + "/media";
    QDir().mkpath(mediaDir);

    QJsonArray processedComponents = components;
    {
        QJsonValue arrVal(processedComponents);
        processJsonValue(arrVal, mediaDir);
        processedComponents = arrVal.toArray();
    }

    QJsonObject dataObj;
    dataObj["name"] = name;
    dataObj["components"] = processedComponents;

    QString dataFile = templeteDir + "/data.json";
    if (!prepareOverwrite(dataFile)) {
        Q_EMIT errorOccurred(tr("无法写入文件: %1").arg(dataFile));
        Q_EMIT finished(false, tr("保存失败"), templeteDir, QStringLiteral("save"));
        return;
    }
    QFile f(dataFile);
    if (!f.open(QIODevice::WriteOnly | QIODevice::Text)) {
        Q_EMIT errorOccurred(tr("无法写入文件: %1").arg(dataFile));
        Q_EMIT finished(false, tr("保存失败"), templeteDir, QStringLiteral("save"));
        return;
    }
    QJsonDocument doc(dataObj);
    f.write(doc.toJson(QJsonDocument::Indented));
    f.close();
    Q_EMIT finished(true, tr("模版已保存至: %1").arg(templeteDir), templeteDir, QStringLiteral("save"));
}

void UniDeskTempleteMgr::processJsonValue(QJsonValue &value, const QString &mediaDir) {
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

QString UniDeskTempleteMgr::copyMediaFile(const QString &absPath, const QString &mediaDir) {
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
        ok = copyPathRecursive(absPath, destPath);
    } else {
        prepareOverwrite(destPath);
        ok = QFile::copy(absPath, destPath);
    }
    if (!ok) return QString();

    m_sourceToRelPath.insert(absPath, relPath);
    return relPath;
}

bool UniDeskTempleteMgr::copyPathRecursive(const QString &src, const QString &dst) {
    QDir srcDir(src);
    if (!srcDir.exists()) return false;
    QDir dstDir(dst);
    if (!dstDir.exists()) {
        if (!dstDir.mkpath(dst)) return false;
    }
    for (const QString &file : srcDir.entryList(QDir::Files)) {
        QString srcFile = src + "/" + file;
        QString dstFile = dst + "/" + file;
        if (QFile::exists(dstFile)) prepareOverwrite(dstFile);
        if (!QFile::copy(srcFile, dstFile)) return false;
    }
    for (const QString &dir : srcDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot)) {
        if (!copyPathRecursive(src + "/" + dir, dst + "/" + dir)) return false;
    }
    return true;
}

bool UniDeskTempleteMgr::prepareOverwrite(const QString &path) {
    if (!QFile::exists(path)) return true;
    QFile f(path);
    f.setPermissions(f.permissions() | QFile::WriteOwner);
    return f.remove();
}

QString UniDeskTempleteMgr::extractAbsolutePath(const QString &str) {
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

void UniDeskTempleteMgr::refreshTempleteList() {
    QVariantList list;
    QDir dir(templetesRootPath);
    if (dir.exists()) {
        const auto entries = dir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
        for (const QString &sub : entries) {
            QString dataFile = templetesRootPath + "/" + sub + "/data.json";
            QFile f(dataFile);
            if (f.open(QIODevice::ReadOnly | QIODevice::Text)) {
                QJsonObject obj = QJsonDocument::fromJson(f.readAll()).object();
                f.close();
                QVariantMap item;
                item["name"] = obj.value("name").toString();
                item["dir"] = templetesRootPath + "/" + sub;
                item["presetWindow"] = obj.value("presetWindow").toString();
                list.append(item);
            }
        }
    }
    m_templeteList = list;
    Q_EMIT templeteListChanged();
}

void UniDeskTempleteMgr::loadTemplete(const QString &dir, const QVariantMap &presets) {
    QString safeDir = dir;
    safeDir.replace("\\", "/");
    if (!QFile::exists(safeDir + "/data.json")) {
        Q_EMIT errorOccurred(tr("模版不存在: %1").arg(safeDir));
        return;
    }
    isWorking(true);
    doLoadTemplete(safeDir, presets);
    isWorking(false);
}

void UniDeskTempleteMgr::doLoadTemplete(const QString &dir, const QVariantMap &presets) {
    m_usedMediaNames.clear();
    m_sourceToRelPath.clear();

    QString appMediaDir = dataRootPath + "/media";
    QString templeteMediaDir = dir + "/media";

    QHash<QString, QString> renameMap;
    if (QDir(templeteMediaDir).exists()) {
        copyMediaDirWithRename(templeteMediaDir, appMediaDir, renameMap);
    }

    QFile f(dir + "/data.json");
    if (!f.open(QIODevice::ReadOnly | QIODevice::Text)) {
        Q_EMIT errorOccurred(tr("无法读取模版数据"));
        Q_EMIT finished(false, tr("加载失败"), dir, QStringLiteral("load"));
        isWorking(false);
        return;
    }
    QJsonObject dataObj = QJsonDocument::fromJson(f.readAll()).object();
    f.close();

    QJsonArray components = dataObj.value("components").toArray();
    QJsonValue compsVal(components);
    processJsonValueForLoad(compsVal, appMediaDir, renameMap);
    components = compsVal.toArray();

    reassignUuidsInline(components);

    for (int i = 0; i < components.size(); ++i) {
        QJsonValue v = components[i];
        convertStrInJsonValue(v, presets);
        components[i] = v;
    }

    dataObj["components"] = components;

    QVariantList compsVariant;
    for (const QJsonValue &v : components) {
        compsVariant.append(v.toVariant());
    }
    Q_EMIT templeteLoaded(compsVariant, presets);
}

QString UniDeskTempleteMgr::applyPresetsToString(const QString &str, const QVariantMap &presets) {
    if (presets.isEmpty()) return str;
    QString result = str;
    for (auto it = presets.constBegin(); it != presets.constEnd(); ++it) {
        QString token = QStringLiteral("%{") + it.key() + QStringLiteral("}");
        result.replace(token, it.value().toString());
    }
    return result;
}

void UniDeskTempleteMgr::convertStrInJsonValue(QJsonValue &value, const QVariantMap &presets) {
    if (value.isString()) {
        QString str = value.toString();
        if (!str.isEmpty() && str.contains(QStringLiteral("%{")) && !presets.isEmpty()) {
            QString converted = applyPresetsToString(str, presets);
            value = QJsonValue(converted);
        }
    } else if (value.isArray()) {
        QJsonArray arr = value.toArray();
        for (int i = 0; i < arr.size(); ++i) {
            QJsonValue child = arr[i];
            convertStrInJsonValue(child, presets);
            arr[i] = child;
        }
        value = arr;
    } else if (value.isObject()) {
        QJsonObject obj = value.toObject();
        for (auto it = obj.begin(); it != obj.end(); ++it) {
            QJsonValue child = it.value();
            convertStrInJsonValue(child, presets);
            obj[it.key()] = child;
        }
        value = obj;
    }
}

void UniDeskTempleteMgr::processJsonValueForLoad(QJsonValue &value, const QString &mediaDir, const QHash<QString, QString> &renameMap) {
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

bool UniDeskTempleteMgr::copyMediaDirWithRename(const QString &src, const QString &dst, QHash<QString, QString> &renameMap) {
    QDir srcDir(src);
    if (!srcDir.exists()) return false;
    QDir dstDir(dst);
    if (!dstDir.exists()) {
        if (!dstDir.mkpath(dst)) return false;
    }
    auto resolveUniqueName = [](const QString &dirPath, const QString &baseName, const QString &ext) {
        QString candidate = baseName + ext;
        int counter = 0;
        while (QFile::exists(dirPath + "/" + candidate)) {
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
        prepareOverwrite(dstFile);
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

bool UniDeskTempleteMgr::reassignUuidsInline(QJsonArray &components) {
    static const QSet<QString> s_builtinIds{QStringLiteral("Wallpaper"), QStringLiteral("Desktop"), QStringLiteral("TopMost")};
    QMap<QString, QString> idMap;
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
    QJsonArray newComponents;
    for (const QJsonValue &cv : firstPass) {
        QJsonObject co = cv.toObject();
        QString parentId = co.value("parent").toString();
        if (!parentId.isEmpty() && idMap.contains(parentId)) {
            co["parent"] = idMap.value(parentId);
        }
        std::function<void(QJsonValue&)> rewriteIds = [&](QJsonValue &v) {
            if (v.isString()) {
                QString s = v.toString();
                if (!s.isEmpty() && idMap.contains(s)) { v = QJsonValue(idMap.value(s)); }
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
        QJsonValue rv = co;
        rewriteIds(rv);
        newComponents.append(rv.toObject());
    }
    components = newComponents;
    return true;
}