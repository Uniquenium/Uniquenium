#include <pybind11/embed.h>
#include "UniDeskTools.h"
#include "UniDeskSettings.h"
#include <QFontDatabase>
#include <QDesktopServices>
#include <QGuiApplication>
#include <QScreen>
#include <QUrl>
#include <QVariant>
#include <QList>
#include <QFont>
#include <QPalette>
#include <QProcess>
#include <QWindow>
#include <QFile>
#include <QQuickWindow>
#ifdef Q_OS_WIN
#include <windows.h>
#include <winreg.h>
#endif

namespace py = pybind11;

UniDeskTools::UniDeskTools(QQuickItem *parent)
    : QQuickItem(parent)
{
    QList<QString> paths = UniDeskSettings::getInstance()->customFontFamilyPaths();
    familyPaths(paths);
    QList<int> fontIds;
    for (const QString& path : paths) {
        if (QFile::exists(path)) {
            int id = QFontDatabase::addApplicationFont(path);
            if (id != -1)
                fontIds.append(id);
        }
    }
    appFonts(fontIds);
}

QColor UniDeskTools::switchColor(const QColor &normal, const QColor &hover, const QColor &press, const QColor &disable,
                                 bool hovered, bool pressed, bool disabled) {
    if (disabled) return disable;
    if (pressed) return press;
    if (hovered) return hover;
    return normal;
}

void UniDeskTools::systemCommand(const QString &command) {
    py::exec("os.system('" + command.toStdString() + "')");
}

QFont UniDeskTools::font(const QString &family, int size) {
    QFont f;
    f.setFamily(family.isEmpty() ? QStringLiteral("微软雅黑") : family);
    f.setPixelSize(size);
    return f;
}

bool UniDeskTools::isSystemColorLight() {
    QPalette pal = QGuiApplication::palette();
    return pal.color(QPalette::Window).lightness() > 128;
}

void UniDeskTools::web_browse(const QString &url) {
#ifdef Q_OS_WIN
    QProcess::startDetached("start " + url);
#else
    QDesktopServices::openUrl(QUrl(url));
#endif
}

void UniDeskTools::setTaskbarVisible(bool vis) {
#ifdef Q_OS_WIN
    HWND hwnd = FindWindowW(L"Shell_TrayWnd", NULL);
    ShowWindow(hwnd, vis ? SW_SHOW : SW_HIDE);
#endif
}

QUrl UniDeskTools::get_wallpaper() {
#ifdef Q_OS_WIN
    wchar_t path[MAX_PATH] = {0};
    HKEY hKey;
    if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Control Panel\\Desktop", 0, KEY_READ, &hKey) == ERROR_SUCCESS) {
        DWORD dwType = REG_SZ;
        DWORD dwSize = sizeof(path);
        RegQueryValueExW(hKey, L"Wallpaper", NULL, &dwType, (LPBYTE)path, &dwSize);
        RegCloseKey(hKey);
        return QUrl::fromLocalFile(QString::fromWCharArray(path));
    }
#endif
    return QUrl();
}

QRect UniDeskTools::desktopGeometry(QQuickWindow *window) {
    if (window && window->screen())
        return window->screen()->geometry();
    return QRect();
}

void UniDeskTools::set_wallpaper(const QUrl &path) {
#ifdef Q_OS_WIN
    QString filePath = path.toLocalFile();
    HKEY hKey;
    if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Control Panel\\Desktop", 0, KEY_SET_VALUE, &hKey) == ERROR_SUCCESS) {
        std::wstring ws = filePath.toStdWString();
        RegSetValueExW(hKey, L"Wallpaper", 0, REG_SZ, (const BYTE*)ws.c_str(), (ws.size()+1)*sizeof(wchar_t));
        RegCloseKey(hKey);
    }
    SystemParametersInfoW(0x0014, 0, (void*)filePath.utf16(), 0x01 | 0x02 | 0x04);
#endif
}

QUrl UniDeskTools::fromLocalFile(const QString &path) {
    return QUrl::fromLocalFile(path);
}

QVariant UniDeskTools::applicationFontFamilies() {
    QStringList families = QFontDatabase::families();
    QList<QString> customFamilies;
    for (int id : appFonts()) {
        QStringList fams = QFontDatabase::applicationFontFamilies(id);
        if (!fams.isEmpty())
            customFamilies << fams[0];
    }
    return QVariant(families + customFamilies);
}

int UniDeskTools::fontIndex(const QString &familyName) {
    QStringList allFamilies = applicationFontFamilies().toStringList();
    return allFamilies.indexOf(familyName);
}

void UniDeskTools::addFontFamily(const QString &path) {
    int id = QFontDatabase::addApplicationFont(path);
    if (id != -1) {
        QList<int> ids = appFonts();
        ids.append(id);
        appFonts(ids);

        QList<QString> paths = familyPaths();
        paths.append(path);
        familyPaths(paths);

        emit customFontsChanged();

        // 更新设置文件
        UniDeskSettings::getInstance()->customFontFamilyPaths(paths);
        UniDeskSettings::getInstance()->set("customFontFamilyPaths", QVariant::fromValue(paths));
    }
}

void UniDeskTools::removeFontFamily(const QString &idStr) {
    int id = idStr.toInt();
    int idx = appFonts().indexOf(id);
    if (idx != -1) {
        QFontDatabase::removeApplicationFont(id);

        QList<int> ids = appFonts();
        ids.removeAt(idx);
        appFonts(ids);

        QList<QString> paths = familyPaths();
        paths.removeAt(idx);
        familyPaths(paths);

        emit customFontsChanged();

        // 更新设置文件
        UniDeskSettings::getInstance()->customFontFamilyPaths(paths);
        UniDeskSettings::getInstance()->set("customFontFamilyPaths", QVariant::fromValue(paths));
    }
}

QVariant UniDeskTools::getCustomFonts() {
    QList<QVariant> result;
    for (int id : appFonts()) {
        QStringList fams = QFontDatabase::applicationFontFamilies(id);
        if (!fams.isEmpty())
            result << QVariant::fromValue(QList<QVariant>{id, fams[0]});
    }
    return QVariant(result);
}

bool UniDeskTools::isValidUrl(const QUrl &url) {
    return url.isValid();
}
