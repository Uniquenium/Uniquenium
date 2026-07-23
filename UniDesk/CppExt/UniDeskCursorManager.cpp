// e:\Uniquenium\Uniquenium\UniDesk\CppExt\UniDeskCursorManager.cpp

#include "UniDeskCursorManager.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QDir>
#include <QUrl>
#include <windows.h>
#include <tchar.h>
#include <shlwapi.h>
#include <QDebug>

#pragma comment(lib, "shlwapi.lib")

UniDeskCursorManager::UniDeskCursorManager(QQuickItem *parent)
    : QQuickItem(parent), hasSavedOriginalCursors(false)
{
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
    
    // Windows标准光标名称列表
    const wchar_t *cursorNames[] = {
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
    
    // 遍历JSON中的光标映射
    QStringList cursorNames = jsonObj.keys();
    bool success = true;
    
    for (const QString &name : cursorNames) {
        // 跳过元数据键（如name）
        if (name == "name") {
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
    
    // 刷新系统光标
    refreshSystemCursors();
    qDebug() << "System cursors restored:" << success;
    return success;
}