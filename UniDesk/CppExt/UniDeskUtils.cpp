#include "UniDeskUtils.h"

#include <QClipboard>
#include <QColor>
#include <QCryptographicHash>
#include <QCursor>
#include <QDBusInterface>
#include <QDBusReply>
#include <QDateTime>
#include <QDir>
#include <QFileInfo>
#include <QGuiApplication>
#include <QOpenGLContext>
#include <QProcess>
#include <QQuickWindow>
#include <QScreen>
#include <QSettings>
#include <QTextDocument>
#include <QUuid>

#ifdef Q_OS_WIN
#pragma comment(lib, "user32.lib")

#include <windows.h>
#include <windowsx.h>

#endif

hash_t hash_(char const* str)
{
    hash_t ret { basis };

    while (*str) {
        ret ^= *str;
        ret *= prime;
        str++;
    }

    return ret;
}

UniDeskUtils::UniDeskUtils(QObject* parent)
    : QObject { parent }
{
}

void UniDeskUtils::clipText(const QString& text)
{
    QGuiApplication::clipboard()->setText(text);
}

QString UniDeskUtils::uuid()
{
    return QUuid::createUuid().toString().remove('-').remove('{').remove('}');
}

QString UniDeskUtils::readFile(const QString& fileName)
{
    QString content;
    QFile file(fileName);
    if (file.open(QIODevice::ReadOnly)) {
        QTextStream stream(&file);
        content = stream.readAll();
    }
    return content;
}

bool UniDeskUtils::isMacos()
{
#if defined(Q_OS_MACOS)
    return true;
#else
    return false;
#endif
}

bool UniDeskUtils::isLinux()
{
#if defined(Q_OS_LINUX)
    return true;
#else
    return false;
#endif
}

bool UniDeskUtils::isWin()
{
#if defined(Q_OS_WIN)
    return true;
#else
    return false;
#endif
}

int UniDeskUtils::qtMajor()
{
    const QString qtVersion = QString::fromLatin1(qVersion());
    const QStringList versionParts = qtVersion.split('.');
    return versionParts[0].toInt();
}

int UniDeskUtils::qtMinor()
{
    const QString qtVersion = QString::fromLatin1(qVersion());
    const QStringList versionParts = qtVersion.split('.');
    return versionParts[1].toInt();
}

void UniDeskUtils::setQuitOnLastWindowClosed(bool val)
{
    QGuiApplication::setQuitOnLastWindowClosed(val);
}

void UniDeskUtils::setOverrideCursor(Qt::CursorShape shape)
{
    QGuiApplication::setOverrideCursor(QCursor(shape));
}

void UniDeskUtils::restoreOverrideCursor()
{
    QGuiApplication::restoreOverrideCursor();
}

void UniDeskUtils::deleteLater(QObject* p)
{
    if (p) {
        p->deleteLater();
    }
}

QString UniDeskUtils::toLocalPath(const QUrl& url) { return url.toLocalFile(); }

QString UniDeskUtils::getFileNameByUrl(const QUrl& url)
{
    return QFileInfo(url.toLocalFile()).fileName();
}

QString UniDeskUtils::html2PlantText(const QString& html)
{
    QTextDocument textDocument;
    textDocument.setHtml(html);
    return textDocument.toPlainText();
}

QRect UniDeskUtils::getVirtualGeometry()
{
    return QGuiApplication::primaryScreen()->virtualGeometry();
}

QString UniDeskUtils::getApplicationDirPath()
{
    return QGuiApplication::applicationDirPath();
}

QUrl UniDeskUtils::getUrlByFilePath(const QString& path)
{
    return QUrl::fromLocalFile(path);
}

QColor UniDeskUtils::withOpacity(const QColor& color, qreal opacity)
{
    int alpha = qRound(opacity * 255) & 0xff;
    return QColor::fromRgba((alpha << 24) | (color.rgba() & 0xffffff));
}

QString UniDeskUtils::md5(const QString& text)
{
    return QCryptographicHash::hash(text.toUtf8(), QCryptographicHash::Md5)
        .toHex();
}

QString UniDeskUtils::toBase64(const QString& text)
{
    return text.toUtf8().toBase64();
}

QString UniDeskUtils::fromBase64(const QString& text)
{
    return QByteArray::fromBase64(text.toUtf8());
}

bool UniDeskUtils::removeDir(const QString& dirPath)
{
    QDir qDir(dirPath);
    return qDir.removeRecursively();
}

bool UniDeskUtils::removeFile(const QString& filePath)
{
    QFile file(filePath);
    return file.remove();
}

QString UniDeskUtils::sha256(const QString& text)
{
    return QCryptographicHash::hash(text.toUtf8(), QCryptographicHash::Sha256)
        .toHex();
}

void UniDeskUtils::showFileInFolder(const QString& path)
{
#if defined(Q_OS_WIN)
    QProcess::startDetached("explorer.exe",
        { "/select,", QDir::toNativeSeparators(path) });
#endif
#if defined(Q_OS_LINUX)
    QFileInfo fileInfo(path);
    auto process = "xdg-open";
    auto arguments = { fileInfo.absoluteDir().absolutePath() };
    QProcess::startDetached(process, arguments);
#endif
#if defined(Q_OS_MACOS)
    QProcess::execute(
        "/usr/bin/osascript",
        { "-e",
            "tell application \"Finder\" to reveal POSIX file \"" + path + "\"" });
    QProcess::execute("/usr/bin/osascript",
        { "-e", "tell application \"Finder\" to activate" });
#endif
}

bool UniDeskUtils::isSoftware()
{
    return QQuickWindow::sceneGraphBackend() == "software";
}

QPoint UniDeskUtils::cursorPos() { return QCursor::pos(); }

qint64 UniDeskUtils::currentTimestamp()
{
    return QDateTime::currentMSecsSinceEpoch();
}

QIcon UniDeskUtils::windowIcon() { return QGuiApplication::windowIcon(); }

int UniDeskUtils::cursorScreenIndex()
{
    int screenIndex = 0;
    int screenCount = QGuiApplication::screens().count();
    if (screenCount > 1) {
        QPoint pos = QCursor::pos();
        for (int i = 0; i <= screenCount - 1; ++i) {
            if (QGuiApplication::screens().at(i)->geometry().contains(pos)) {
                screenIndex = i;
                break;
            }
        }
    }
    return screenIndex;
}

int UniDeskUtils::windowBuildNumber()
{
#if defined(Q_OS_WIN)
    QSettings regKey {
        QString::fromUtf8(
            R"(HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion)"),
        QSettings::NativeFormat
    };
    if (regKey.contains(QString::fromUtf8("CurrentBuildNumber"))) {
        auto buildNumber = regKey.value(QString::fromUtf8("CurrentBuildNumber")).toInt();
        return buildNumber;
    }
#endif
    return -1;
}

bool UniDeskUtils::isWindows11OrGreater()
{
    static QVariant var;
    if (var.isNull()) {
#if defined(Q_OS_WIN)
        auto buildNumber = windowBuildNumber();
        if (buildNumber >= 22000) {
            var = QVariant::fromValue(true);
            return true;
        }
#endif
        var = QVariant::fromValue(false);
        return false;
    } else {
        return var.toBool();
    }
}

bool UniDeskUtils::isWindows10OrGreater()
{
    static QVariant var;
    if (var.isNull()) {
#if defined(Q_OS_WIN)
        auto buildNumber = windowBuildNumber();
        if (buildNumber >= 10240) {
            var = QVariant::fromValue(true);
            return true;
        }
#endif
        var = QVariant::fromValue(false);
        return false;
    } else {
        return var.toBool();
    }
}

QRect UniDeskUtils::desktopAvailableGeometry(QQuickWindow* window)
{
    return window->screen()->availableGeometry();
}

QString UniDeskUtils::getWallpaperFilePath()
{
#if defined(Q_OS_WIN)
    wchar_t path[MAX_PATH] = {};
    if (::SystemParametersInfoW(SPI_GETDESKWALLPAPER, MAX_PATH, path, FALSE) == FALSE) {
        return {};
    }
    return QString::fromWCharArray(path);
#elif defined(Q_OS_LINUX)
    auto type = QSysInfo::productType();

    switch (hash_(type.toStdString().c_str())) {
    case hash_compile_time("uos"): {
        QDBusInterface interface("com.deepin.wm",
            "/com/deepin/wm",
            "com.deepin.wm",
            QDBusConnection::sessionBus());

        if (!interface.isValid()) {
            qWarning() << QDBusConnection::sessionBus().lastError().message();
            return QString();
        }

        // Call the method and get the reply
        QDBusReply<QString> reply = interface.call("GetCurrentWorkspaceBackgroundForMonitor",
            QString("string:'%1'").arg(currentTimestamp()));

        if (!reply.isValid()) {
            // Handle the error
            qWarning() << reply.error().message();
            return QString();
        }

        QString result = reply.value().trimmed();

        int startIndex = result.indexOf("file:///");
        if (startIndex != -1) {
            auto path = result.mid(startIndex + 7, result.length() - startIndex - 8);
            return path;
        }
        break;
    }
    case hash_compile_time("lingmo"): {
        QDBusInterface interface("com.lingmo.Settings",
            "/Theme",
            "org.freedesktop.DBus.Properties",
            QDBusConnection::sessionBus());

        if (!interface.isValid()) {
            qWarning() << QDBusConnection::sessionBus().lastError().message();
            return QString();
        }

        // 使用 org.freedesktop.DBus.Properties.Get 方法来获取属性
        QDBusReply<QVariant> reply = interface.call("Get",
            "com.lingmo.Theme", // 接口名
            "wallpaper");

        if (!reply.isValid()) {
            qWarning() << "Error getting property:" << reply.error().message();
            return QString();
        }

        QString result = reply.value().toString();

        return result;
        break;
    }
    }

    QString desktop_name = qgetenv("XDG_CURRENT_DESKTOP");

    switch (hash_(desktop_name.toStdString().c_str())) {
    case hash_compile_time("KDE"): {
        QDBusInterface plasmaShellInterface("org.kde.plasmashell", "/PlasmaShell", "org.kde.PlasmaShell");
        // 检查接口是否有效
        if (!plasmaShellInterface.isValid()) {
            qDebug() << "Failed to create D-Bus interface.";
            return {};
        }
        // 调用D-Bus方法获取属性
        QDBusReply<QVariantMap> reply = plasmaShellInterface.call("wallpaper", static_cast<uint32_t>(0));
        // 检查调用是否成功
        if (!reply.isValid()) {
            qDebug() << "Failed to call D-Bus method:" << reply.error().message();
            return {};
        }
        // 获取属性值
        QVariantMap properties = reply.value();
        QString imagePath = properties["Image"].toString();
        return imagePath;
    }
    }

#elif defined(Q_OS_MACOS)
    QProcess process;
    QStringList args;
    args << "-e";
    args
        << R"(tell application "Finder" to get POSIX path of (desktop picture as alias))";
    process.start("osascript", args);
    process.waitForFinished();
    QByteArray result = process.readAllStandardOutput().trimmed();
    if (result.isEmpty()) {
        return "/System/Library/CoreServices/DefaultDesktop.heic";
    }
    return result;
#else
    return {};
#endif
    return {};
}

QColor UniDeskUtils::imageMainColor(const QImage& image, double bright)
{
    int step = 20;
    int t = 0;
    int r = 0, g = 0, b = 0;
    for (int i = 0; i < image.width(); i += step) {
        for (int j = 0; j < image.height(); j += step) {
            if (image.valid(i, j)) {
                t++;
                QColor c = image.pixel(i, j);
                r += c.red();
                b += c.blue();
                g += c.green();
            }
        }
    }
    return QColor(int(bright * r / t) > 255 ? 255 : int(bright * r / t),
        int(bright * g / t) > 255 ? 255 : int(bright * g / t),
        int(bright * b / t) > 255 ? 255 : int(bright * b / t));
}
