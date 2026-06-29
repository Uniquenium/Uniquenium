#ifndef UNIDESKSYSTEMTRAY_H
#define UNIDESKSYSTEMTRAY_H

#include "stdafx.h"
#include "singleton.h"
#include <QSystemTrayIcon>
#include <QMenu>
#include <QIcon>
#include <QtQml/qqml.h>

class UniDeskSystemTray : public QObject {
    Q_OBJECT
    QML_NAMED_ELEMENT(UniDeskSystemTray)
    QML_SINGLETON

private:
    explicit UniDeskSystemTray(QObject *parent = nullptr);
    ~UniDeskSystemTray();

    QSystemTrayIcon* m_trayIcon;
    QMenu* m_trayMenu;
    QAction* m_actionShow;
    QAction* m_actionHide;
    QAction* m_actionSettings;
    QAction* m_actionPageManager;
    QAction* m_actionExit;

public:
    SINGLETON(UniDeskSystemTray)
    static auto create(QQmlEngine*, QJSEngine*) { return getInstance(); }

    Q_INVOKABLE void setVisible(bool visible);
    Q_INVOKABLE void setIcon(const QString& iconPath);
    Q_INVOKABLE void setTooltip(const QString& tooltip);
    Q_INVOKABLE void setWindowVisible(bool visible);

signals:
    void showWindow();
    void hideWindow();
    void openSettings();
    void openPageManager();
    void exitApp();
};

#endif // UNIDESKSYSTEMTRAY_H