// e:\Uniquenium\Uniquenium\UniDesk\CppExt\UniDeskCursorManager.cpp

#include "UniDeskCursorManager.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QDir>
#include <QUrl>
#include <tchar.h>
#include <QCoreApplication>
#include <shlwapi.h>
#include <QDebug>
#include <QTimer>
#ifdef Q_OS_WIN
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
    
    // 保存Scheme Source（光标主题来源）
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
            // 保存所有值，包括空值（空值表示使用系统默认）
            originalCursors[cursorNames[i]] = buffer;
        }
    }
    
    RegCloseKey(hKey);
    hasSavedOriginalCursors = true;
    return true;
}

bool UniDeskCursorManager::setCursor(const std::wstring &cursorName, const std::wstring &cursorPath) {
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
}

void UniDeskCursorManager::refreshSystemCursors() {
    // 使用SystemParametersInfo刷新系统光标
    SystemParametersInfoW(SPI_SETCURSORS, 0, nullptr, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
    
    // 额外的刷新：发送WM_SETTINGCHANGE消息给所有顶层窗口
    SendMessageTimeoutW(HWND_BROADCAST, WM_SETTINGCHANGE, 0, 
                        reinterpret_cast<LPARAM>(L"intl"), 
                        SMTO_ABORTIFHUNG, 5000, nullptr);
    
    // 再次发送WM_SETTINGCHANGE消息，确保系统收到
    SendMessageTimeoutW(HWND_BROADCAST, WM_SETTINGCHANGE, 0, 
                        reinterpret_cast<LPARAM>(L"Control Panel\\Cursors"), 
                        SMTO_ABORTIFHUNG, 5000, nullptr);
}

bool UniDeskCursorManager::loadCustomByPath(const QString &dirPath) {
    // 处理QML URL路径格式（file:/ 或 file://）
    QString path = dirPath;
    if (path.startsWith("file:///")) {
        path = path.mid(8); // 移除 "file:///"
    } else if (path.startsWith("file:/")) {
        path = path.mid(6); // 移除 "file:/"
    }
    bool success = true;
    // 确保路径以斜杠结尾
    QString normalizedDir = QDir(path).absolutePath();
    
    // 首先保存原始光标设置（如果还没保存）
    if (!getOriginalCursorPaths()) {
        return false;
    }
    
    // 读取cursor-style-info.json
    QJsonObject jsonObj;
    if (!readCursorStyleInfo(normalizedDir, jsonObj)) {
        return false;
    }
    if (jsonObj["type"].toString() == "Native") {
        isQmlCursor(false);
        // 遍历JSON中的光标映射
        QStringList cursorNamesJson = jsonObj.keys();
        
        for (const QString &name : cursorNamesJson) {
            // 跳过元数据键（如name）
            if (name == "name") {
                continue;
            }
            
            // 跳过type键
            if (name == "type") {
                continue;
            }
            
            QString fileName = jsonObj[name].toString();
            if (fileName.isEmpty()) {
                continue;
            }
            
            // 构建完整的光标文件路径
            QString fullPath = normalizedDir + "/" + fileName;
            
            // 检查文件是否存在
            if (!QFile::exists(fullPath)) {
                qWarning() << "Cursor file not found:" << fullPath;
                success = false;
                continue;
            }
            
            // 将QString转换为std::wstring
            std::wstring wName = name.toStdWString();
            std::wstring wPath = fullPath.toStdWString();
            
            // 设置光标
            if (!setCursor(wName, wPath)) {
                success = false;
            }
        }
        
        // 刷新系统光标
        refreshSystemCursors();
    } else if (jsonObj["type"].toString() == "Qml") {
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
        for(size_t i = 0; i < sizeof(cursorNames) / sizeof(cursorNames[0]); i++){
            QString blankCursorPath = QCoreApplication::applicationDirPath() + "/cursors/blank-cursor.cur" ;
            if(!setCursor(cursorNames[i], blankCursorPath.toStdWString())){
                success = false;
            }
        }
        // 刷新系统光标
        refreshSystemCursors();
        return success;
    }
    else{
        qWarning() << "Unknown cursor type:" << jsonObj["type"].toString();
        success = false;
    }
    
    return success;
}

bool UniDeskCursorManager::restoreSystem() {
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
    // 刷新系统光标
    refreshSystemCursors();
    qDebug() << "System cursors restored:" << success;
    return success;
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

