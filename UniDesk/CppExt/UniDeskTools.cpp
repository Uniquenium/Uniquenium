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
#include <QDir>
#include <QProcess>
#include <QWindow>
#include <QFile>
#include <QQuickWindow>
#include <QCursor>
#include <QFileInfo>
#ifdef Q_OS_WIN
#include <windows.h>
#include <winreg.h>
#endif

// 设置或取消开机自启
// name: 注册表值名（通常是程序名）
// path: 可执行文件完整路径（会自动加引号）
// enable: true => 设置自启； false => 删除自启
// allUsers: false => HKCU (当前用户)， true => HKLM (所有用户；需要管理员权限)
static bool SetAutoStart(const std::wstring& name, const std::wstring& path, bool enable, bool allUsers = false)
{
    HKEY root = allUsers ? HKEY_LOCAL_MACHINE : HKEY_CURRENT_USER;
    const wchar_t* subkey = L"Software\\Microsoft\\Windows\\CurrentVersion\\Run";
    HKEY hKey = NULL;
    LONG rc = RegCreateKeyExW(root, subkey, 0, NULL, 0, KEY_WRITE, NULL, &hKey, NULL);
    if (rc != ERROR_SUCCESS) {
        return false;
    }

    if (!enable) {
        // 删除值（如果存在）
        rc = RegDeleteValueW(hKey, name.c_str());
        RegCloseKey(hKey);
        return rc == ERROR_SUCCESS || rc == ERROR_FILE_NOT_FOUND;
    }

    // 写入值：通常将路径用引号包起来以支持带空格的路径
    std::wstring value = L"\"" + path + L"\"";
    rc = RegSetValueExW(hKey, name.c_str(), 0, REG_SZ,
                        reinterpret_cast<const BYTE*>(value.c_str()),
                        static_cast<DWORD>((value.size() + 1) * sizeof(wchar_t)));
    RegCloseKey(hKey);
    return rc == ERROR_SUCCESS;
}

// 从 registry 中的值里提取出实际的可执行路径（去掉引号和后续命令行参数）
// 如果值以引号开始，取第一对引号内的内容；否则取到第一个空格为止（或整个字符串）
static std::wstring ExtractExePathFromRunValue(const std::wstring& runValue)
{
    if (runValue.empty()) return L"";
    if (runValue.front() == L'\"') {
        // 找第二个引号
        size_t pos = runValue.find(L'\"', 1);
        if (pos != std::wstring::npos) {
            return runValue.substr(1, pos - 1);
        } else {
            // 没有闭合引号，去掉首引号返回剩下的
            return runValue.substr(1);
        }
    } else {
        // 取第一个空格之前的部分
        size_t pos = runValue.find(L' ');
        if (pos != std::wstring::npos) {
            return runValue.substr(0, pos);
        } else {
            return runValue;
        }
    }
}

// 忽略大小写比较两个路径（简单比较）
// 注意：不做规范化（比如短路径、大小写、符号链接、环境变量等），只是做不区分大小写的直接字符串比较。
static bool PathEqualInsensitive(const std::wstring& a, const std::wstring& b)
{
    if (a.size() != b.size()) {
        // 长度不同仍可能相同（例如存在不同表示法），但这里只做简单比较；先快速判断长度不同则比较小写后的内容
    }
    // 使用 _wcsicmp（Windows）进行不区分大小写比较
#if defined(_MSC_VER)
    return _wcsicmp(a.c_str(), b.c_str()) == 0;
#else
    // 在 MinGW/GCC 下也可以使用 wcsicmp / wcscasecmp; 尝试 wcscasecmp
    return _wcsicmp(a.c_str(), b.c_str()) == 0;
#endif
}

// 查询是否已设置指定的开机自启（按 name 查找并比较路径是否与给定 path 匹配）
// 返回 true 表示注册表里存在该 name 且路径与 path 匹配（按简单不区分大小写比较）。
static bool IsAutoStartEnabled(const std::wstring& name, const std::wstring& path, bool allUsers = false)
{
    HKEY root = allUsers ? HKEY_LOCAL_MACHINE : HKEY_CURRENT_USER;
    const wchar_t* subkey = L"Software\\Microsoft\\Windows\\CurrentVersion\\Run";
    HKEY hKey = NULL;
    LONG rc = RegOpenKeyExW(root, subkey, 0, KEY_READ, &hKey);
    if (rc != ERROR_SUCCESS) {
        return false;
    }

    DWORD type = 0;
    DWORD dataSize = 0;
    // 先查大小
    rc = RegQueryValueExW(hKey, name.c_str(), NULL, &type, NULL, &dataSize);
    if (rc != ERROR_SUCCESS || (type != REG_SZ && type != REG_EXPAND_SZ)) {
        RegCloseKey(hKey);
        return false;
    }

    std::wstring buf;
    buf.resize(dataSize / sizeof(wchar_t));
    rc = RegQueryValueExW(hKey, name.c_str(), NULL, &type,
                          reinterpret_cast<LPBYTE>(&buf[0]), &dataSize);
    RegCloseKey(hKey);
    if (rc != ERROR_SUCCESS) return false;

    // 确保以 null 结尾
    if (!buf.empty() && buf.back() == L'\0') {
        buf.pop_back();
    }

    std::wstring storedExe = ExtractExePathFromRunValue(buf);
    if (storedExe.empty()) return false;

    return PathEqualInsensitive(storedExe, path);
}


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
#ifdef Q_OS_WIN
    QProcess::startDetached("cmd.exe", QStringList() << "/c" << command);
#else
    QProcess::startDetached("sh", QStringList() << "-c" << command);
#endif
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
    QDesktopServices::openUrl(QUrl(url));
}

void UniDeskTools::setTaskbarVisible(bool vis) {
#ifdef Q_OS_WIN
    HWND hwnd = FindWindowW(L"Shell_TrayWnd", NULL);
    ShowWindow(hwnd, vis ? SW_SHOW : SW_HIDE);
#endif
}

QUrl UniDeskTools::get_system_wallpaper() {
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

void UniDeskTools::set_system_wallpaper(const QUrl &path) {
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

QPoint UniDeskTools::getCursorPosition() {
    return QCursor::pos();
}

bool UniDeskTools::localFileExists(const QUrl &url) {
    QFileInfo fileInfo(url.toLocalFile());
    return url.scheme() == "file" && fileInfo.exists();
}

QString UniDeskTools::getModuleVersionMajor() {
    return MODULE_VERSION_MAJOR;
}
QString UniDeskTools::getModuleVersionMinor() {
    return MODULE_VERSION_MINOR;
}
QString UniDeskTools::getModuleVersionPatch() {
    return MODULE_VERSION_PATCH;
}
void UniDeskTools::openFileOrDir(const QString &path) {
    QDesktopServices::openUrl(QUrl::fromLocalFile(path));
}
void UniDeskTools::showFileInExplorer(const QString &path) {
#ifdef Q_OS_WIN
    const QString explorer = "explorer";
    QStringList param;
    if(!QFileInfo(path).isDir())
        param<<QLatin1String("/select,");
    param<<QDir::toNativeSeparators(path);
    QProcess::startDetached(explorer,param);
#endif
}
QString UniDeskTools::createUuid() {
    return QUuid::createUuid().toString();
}
bool UniDeskTools::isAppAutoStartEnabled() {
    QString path = QGuiApplication::applicationFilePath();
    return IsAutoStartEnabled(L"UniDesk.Uniquenium", path.toStdWString());
}
void UniDeskTools::setAppAutoStart(bool enabled) {
    QString path = QGuiApplication::applicationFilePath();
    SetAutoStart(L"UniDesk.Uniquenium", path.toStdWString(), enabled);
}
