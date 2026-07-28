#ifndef UNIDESKCURSORMANAGER_H
#define UNIDESKCURSORMANAGER_H

#include "stdafx.h"
#include "singleton.h"
#include "UniDeskDefines.h"
#include <QQuickItem>
#include <QString>
#include <QJsonObject>
#include <QtQml/qqml.h>
#include <map>
#include <QTimer>
#include <string>



class UniDeskCursorManager : public QQuickItem {
    Q_OBJECT
    QML_NAMED_ELEMENT(UniDeskCursorManager)
    Q_PROPERTY_AUTO_P(bool,isQmlCursor)
    Q_PROPERTY_AUTO_P(QString,qmlCursorPath)
    Q_PROPERTY_AUTO_P(int,cursorStdState)
    QML_SINGLETON
private:
    explicit UniDeskCursorManager(QQuickItem *parent = nullptr);
    ~UniDeskCursorManager();
    
    QTimer *m_timer = nullptr;
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
    

    // 隐藏系统鼠标（设置空白光标）
    void hideSystemCursor();
    // 显示系统鼠标（恢复原始光标）
    void showSystemCursor();

    
public:
    SINGLETON(UniDeskCursorManager)
    static auto create(QQmlEngine*, QJSEngine*) { return getInstance(); }
    
    Q_INVOKABLE bool loadCustomByPath(const QString &dirPath);
    
    Q_INVOKABLE bool restoreSystem();
    
    // 获取当前系统光标标准状态
    Q_INVOKABLE int getStdState();

};


#endif // UNIDESKCURSORMANAGER_H