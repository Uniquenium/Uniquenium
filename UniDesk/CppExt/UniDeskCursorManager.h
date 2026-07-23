// e:\Uniquenium\Uniquenium\UniDesk\CppExt\UniDeskCursorManager.h

#ifndef UNIDESKCURSORMANAGER_H
#define UNIDESKCURSORMANAGER_H

#include "stdafx.h"
#include "singleton.h"
#include <QQuickItem>
#include <QString>
#include <QJsonObject>
#include <QtQml/qqml.h>
#include <map>
#include <string>

class UniDeskCursorManager : public QQuickItem {
    Q_OBJECT
    QML_NAMED_ELEMENT(UniDeskCursorManager)
    QML_SINGLETON
private:
    explicit UniDeskCursorManager(QQuickItem *parent = nullptr);
    
    // 保存原始光标路径，用于恢复
    std::map<std::wstring, std::wstring> originalCursors;
    
    // 检查是否已经保存过原始光标设置
    bool hasSavedOriginalCursors;
    
    // 读取cursor-style-info.json文件
    bool readCursorStyleInfo(const QString &dirPath, QJsonObject &outJson);
    
    // 获取Windows注册表中的光标路径
    bool getOriginalCursorPaths();
    
    // 设置单个光标
    bool setCursor(const std::wstring &cursorName, const std::wstring &cursorPath);
    
    // 刷新系统光标
    void refreshSystemCursors();
    
public:
    SINGLETON(UniDeskCursorManager)
    static auto create(QQmlEngine*, QJSEngine*) { return getInstance(); }
    
    /**
     * @brief 根据指定目录中的cursor-style-info.json文件加载自定义鼠标样式
     * @param dirPath 包含cursor-style-info.json和光标文件(.cur/.ani)的目录路径
     * @return 是否成功加载
     */
    Q_INVOKABLE bool loadCustomByPath(const QString &dirPath);
    
    /**
     * @brief 还原系统默认鼠标样式
     * @return 是否成功还原
     */
    Q_INVOKABLE bool restoreSystem();
};

#endif // UNIDESKCURSORMANAGER_H