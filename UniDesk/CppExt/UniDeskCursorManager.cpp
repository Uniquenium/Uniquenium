// e:\Uniquenium\Uniquenium\UniDesk\CppExt\UniDeskCursorManager.cpp

#include "UniDeskCursorManager.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QDir>
#include <QUrl>
#include <QCoreApplication>
#include <QDebug>
#include <QTimer>
#ifdef Q_OS_WIN
#include <tchar.h>
#include <shlwapi.h>
#include <windows.h>
#include <winuser.h>
#pragma comment(lib, "shlwapi.lib")
#endif



const wchar_t* cursorNames[] = {
    L"Arrow",
    L"IBeam",
    L"Wait",
    L"Crosshair",
    L"Hand",
    L"Help",
    L"SizeAll",
    L"SizeNESW",
    L"SizeNS",
    L"SizeNWSE",
    L"SizeWE",
    L"UpArrow",
    L"AppStarting",
    L"Pin",
    L"No",
    L"Arrow_",
    L"IBeam_",
    L"Wait_",
    L"Crosshair_",
    L"Hand_",
    L"Help_",
    L"SizeAll_",
    L"SizeNESW_",
    L"SizeNS_",
    L"SizeNWSE_",
    L"SizeWE_",
    L"UpArrow_",
    L"AppStarting_",
    L"Pin_",
    L"No_"
};






UniDeskCursorManager::UniDeskCursorManager(QQuickItem *parent)
    : QQuickItem(parent), hasSavedOriginalCursors(false)
{
    m_timer = new QTimer(this);
    m_timer->setInterval(50);
    connect(m_timer, &QTimer::timeout, this, [this]() {
        cursorStdState(getStdState());
    });
    m_timer->start();
    
}

UniDeskCursorManager::~UniDeskCursorManager() {
    m_timer->stop();
    delete m_timer;
}

bool UniDeskCursorManager::readCursorStyleInfo(const QString &dirPath, QJsonObject &outJson) {
    QString jsonPath = dirPath + "/cursor-style-info.json";
    QFile file(jsonPath);
    if (!file.exists()) {
        qWarning() << "cursor-style-info.json not found in:" << dirPath;
        return false;
    }
    
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Failed to open cursor-style-info.json:" << jsonPath;
        return false;
    }
    
    QByteArray data = file.readAll();
    file.close();
    
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(data, &error);
    if (error.error != QJsonParseError::NoError) {
        qWarning() << "Failed to parse cursor-style-info.json:" << error.errorString();
        return false;
    }
    
    if (!doc.isObject()) {
        qWarning() << "cursor-style-info.json is not a valid JSON object";
        return false;
    }
    
    outJson = doc.object();
    return true;
}

bool UniDeskCursorManager::getOriginalCursorPaths() {
#ifdef Q_OS_WIN
    if (hasSavedOriginalCursors) {
        return true;
    }
    
    HKEY hKey;
    LONG result = RegOpenKeyExW(HKEY_CURRENT_USER,
                                L"Control Panel\\Cursors",
                                0,
                                KEY_READ,
                                &hKey);
    if (result != ERROR_SUCCESS) {
        qWarning() << "Failed to open registry key: Control Panel\\Cursors";
        return false;
    }
    
    wchar_t schemeBuffer[MAX_PATH] = {0};
    DWORD schemeBufferSize = MAX_PATH;
    result = RegQueryValueExW(hKey,
                              L"Scheme Source",
                              nullptr,
                              nullptr,
                              reinterpret_cast<LPBYTE>(schemeBuffer),
                              &schemeBufferSize);
    if (result == ERROR_SUCCESS) {
        originalCursors[L"Scheme Source"] = schemeBuffer;
    }
    
    for (size_t i = 0; i < sizeof(cursorNames) / sizeof(cursorNames[0]); ++i) {
        wchar_t buffer[MAX_PATH] = {0};
        DWORD bufferSize = MAX_PATH;
        
        result = RegQueryValueExW(hKey,
                                  cursorNames[i],
                                  nullptr,
                                  nullptr,
                                  reinterpret_cast<LPBYTE>(buffer),
                                  &bufferSize);
        
        if (result == ERROR_SUCCESS) {
            originalCursors[cursorNames[i]] = buffer;
        }
    }
    
    RegCloseKey(hKey);
    hasSavedOriginalCursors = true;
    return true;
#else
    return false;
#endif
}

bool UniDeskCursorManager::setCursor(const std::wstring &cursorName, const std::wstring &cursorPath) {
#ifdef Q_OS_WIN
    HKEY hKey;
    LONG result = RegOpenKeyExW(HKEY_CURRENT_USER,
                                L"Control Panel\\Cursors",
                                0,
                                KEY_WRITE,
                                &hKey);
    if (result != ERROR_SUCCESS) {
        qWarning() << "Failed to open registry key for writing";
        return false;
    }
    
    result = RegSetValueExW(hKey,
                            cursorName.c_str(),
                            0,
                            REG_SZ,
                            reinterpret_cast<const BYTE*>(cursorPath.c_str()),
                            (cursorPath.size() + 1) * sizeof(wchar_t));
    
    RegCloseKey(hKey);
    
    if (result != ERROR_SUCCESS) {
        qWarning() << "Failed to set cursor:" << QString::fromStdWString(cursorName);
        return false;
    }
    
    return true;
#else
    Q_UNUSED(cursorName);
    Q_UNUSED(cursorPath);
    return false;
#endif
}

void UniDeskCursorManager::refreshSystemCursors() {
#ifdef Q_OS_WIN
    SystemParametersInfoW(SPI_SETCURSORS, 0, nullptr, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
    
    SendMessageTimeoutW(HWND_BROADCAST, WM_SETTINGCHANGE, 0, 
                        reinterpret_cast<LPARAM>(L"intl"), 
                        SMTO_ABORTIFHUNG, 5000, nullptr);
    
    SendMessageTimeoutW(HWND_BROADCAST, WM_SETTINGCHANGE, 0, 
                        reinterpret_cast<LPARAM>(L"Control Panel\\Cursors"), 
                        SMTO_ABORTIFHUNG, 5000, nullptr);
#endif
}

bool UniDeskCursorManager::loadCustomByPath(const QString &dirPath) {
    QString path = dirPath;
    if (path.startsWith("file:///")) {
        path = path.mid(8);
    } else if (path.startsWith("file:/")) {
        path = path.mid(6);
    }
    bool success = true;
    QString normalizedDir = QDir(path).absolutePath();
    
#ifdef Q_OS_WIN
    if (!getOriginalCursorPaths()) {
        return false;
    }
#endif
    
    QJsonObject jsonObj;
    if (!readCursorStyleInfo(normalizedDir, jsonObj)) {
        return false;
    }
    
    QString cursorType = jsonObj["type"].toString();
    
#ifdef Q_OS_WIN
    if (cursorType == "Native") {
        isQmlCursor(false);
        QStringList cursorNamesJson = jsonObj.keys();
        for (const QString &name : cursorNamesJson) {
            if (name == "name" || name == "type") {
                continue;
            }
            QString fileName = jsonObj[name].toString();
            if (fileName.isEmpty()) {
                continue;
            }
            QString fullPath = normalizedDir + "/" + fileName;
            if (!QFile::exists(fullPath)) {
                qWarning() << "Cursor file not found:" << fullPath;
                success = false;
                continue;
            }
            std::wstring wName = name.toStdWString();
            std::wstring wPath = fullPath.toStdWString();
            if (!setCursor(wName, wPath)) {
                success = false;
            }
        }
        refreshSystemCursors();
    } else
#endif
    if (cursorType == "Qml") {
        if (jsonObj["qmlFilePath"].toString().isEmpty()) {
            qWarning() << "qmlFilePath is empty";
            return false;
        }
        QString qmlFilePath = dirPath + "/" + jsonObj["qmlFilePath"].toString();
        if (!QFile::exists(normalizedDir + "/" + jsonObj["qmlFilePath"].toString())) {
            qWarning() << "qmlFilePath not found:" << normalizedDir + "/" + jsonObj["qmlFilePath"].toString();
            return false;
        }
        qmlCursorPath(qmlFilePath);
        isQmlCursor(true);
        success = true;
#ifdef Q_OS_WIN
        for(size_t i = 0; i < sizeof(cursorNames) / sizeof(cursorNames[0]); i++){
            QString blankCursorPath = QCoreApplication::applicationDirPath() + "/cursors/blank-cursor.cur";
            if(!setCursor(cursorNames[i], blankCursorPath.toStdWString())){
                success = false;
            }
        }
        refreshSystemCursors();
#endif
        return success;
    }
    else {
        qWarning() << "Unknown cursor type:" << cursorType;
        success = false;
    }
    
    return success;
}

bool UniDeskCursorManager::restoreSystem() {
#ifdef Q_OS_WIN
    if (!hasSavedOriginalCursors || originalCursors.empty()) {
        qWarning() << "No original cursor settings saved";
        return false;
    }
    
    bool success = true;
    
    for (const auto &pair : originalCursors) {
        if (!setCursor(pair.first, pair.second)) {
            success = false;
        }
    }
    isQmlCursor(false);
    refreshSystemCursors();
    qDebug() << "System cursors restored:" << success;
    return success;
#else
    isQmlCursor(false);
    return true;
#endif
}

// 获取当前系统光标标准状态
int UniDeskCursorManager::getStdState() {
#ifdef Q_OS_WIN
    // 定义系统标准光标 ID 与枚举值的映射
    struct CursorMapping {
        LPCTSTR ocrId;
        UniDeskCursorStdState::CursorStdState state;
    };
    
    const CursorMapping standard[] = {
        {IDC_ARROW,       UniDeskCursorStdState::Arrow},
        {IDC_IBEAM,        UniDeskCursorStdState::IBeam},
        {IDC_WAIT,         UniDeskCursorStdState::Wait},
        {IDC_CROSS,        UniDeskCursorStdState::Crosshair},
        {IDC_UPARROW,      UniDeskCursorStdState::UpArrow},
        {IDC_SIZENS,       UniDeskCursorStdState::SizeNS},
        {IDC_SIZEWE,       UniDeskCursorStdState::SizeWE},
        {IDC_SIZENWSE,     UniDeskCursorStdState::SizeNWSE},
        {IDC_SIZENESW,     UniDeskCursorStdState::SizeNESW},
        {IDC_SIZEALL,      UniDeskCursorStdState::SizeAll},
        {IDC_NO,           UniDeskCursorStdState::No},
        {IDC_HAND,         UniDeskCursorStdState::Hand},
        {IDC_HELP,         UniDeskCursorStdState::Help},
        {IDC_PIN,          UniDeskCursorStdState::Pin},
        {IDC_APPSTARTING,  UniDeskCursorStdState::AppStarting},
    };
    
    CURSORINFO ci = { sizeof(ci) };
    if (!GetCursorInfo(&ci)) {
        
        return static_cast<int>(UniDeskCursorStdState::Arrow);
    }

    HCURSOR cur = ci.hCursor;
    if (cur == NULL) {
        // qDebug() << "当前没有游标句柄 (cur == NULL)\n";
        return static_cast<int>(UniDeskCursorStdState::Arrow);
    }

    bool matched = false;
    for (const auto& e : standard) {
        HCURSOR stdc = LoadCursor(NULL, e.ocrId);
        if (stdc != NULL && stdc == cur) {
            return static_cast<int>(e.state);
            matched = true;
            break;
        }
    }
    return static_cast<int>(UniDeskCursorStdState::Arrow);
#else
    return static_cast<int>(UniDeskCursorStdState::Arrow);
#endif
}

