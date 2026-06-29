#include "UniDeskSystemTray.h"

UniDeskSystemTray::UniDeskSystemTray(QObject *parent) : QObject(parent) {
    // 创建系统托盘图标
    m_trayIcon = new QSystemTrayIcon(this);
    
    // 创建菜单
    m_trayMenu = new QMenu();
    
    m_actionShow = new QAction(tr("显示"), this);
    m_actionHide = new QAction(tr("隐藏"), this);
    m_actionSettings = new QAction(tr("设置"), this);
    m_actionPageManager = new QAction(tr("页面管理器"), this);
    m_actionExit = new QAction(tr("退出"), this);
    
    // 添加菜单
    m_trayMenu->addAction(m_actionShow);
    m_trayMenu->addAction(m_actionHide);
    m_trayMenu->addSeparator();
    m_trayMenu->addAction(m_actionSettings);
    m_trayMenu->addAction(m_actionPageManager);
    m_trayMenu->addSeparator();
    m_trayMenu->addAction(m_actionExit);
    
    // 设置托盘菜单
    m_trayIcon->setContextMenu(m_trayMenu);
    
    // 连接信号槽
    connect(m_actionShow, &QAction::triggered, this, &UniDeskSystemTray::showWindow);
    connect(m_actionHide, &QAction::triggered, this, &UniDeskSystemTray::hideWindow);
    connect(m_actionSettings, &QAction::triggered, this, &UniDeskSystemTray::openSettings);
    connect(m_actionPageManager, &QAction::triggered, this, &UniDeskSystemTray::openPageManager);
    connect(m_actionExit, &QAction::triggered, this, &UniDeskSystemTray::exitApp);
    
    // 默认隐藏"隐藏"按钮（窗口初始可见）
    m_actionHide->setVisible(false);
    
    // 显示托盘图标
    m_trayIcon->show();
}

UniDeskSystemTray::~UniDeskSystemTray() {
    m_trayIcon->hide();
    delete m_trayIcon;
    delete m_trayMenu;
}

void UniDeskSystemTray::setVisible(bool visible) {
    if (visible) {
        m_trayIcon->show();
    } else {
        m_trayIcon->hide();
    }
}

void UniDeskSystemTray::setIcon(const QString& iconPath) {
    QIcon icon(iconPath);
    m_trayIcon->setIcon(icon);
}

void UniDeskSystemTray::setTooltip(const QString& tooltip) {
    m_trayIcon->setToolTip(tooltip);
}

void UniDeskSystemTray::setWindowVisible(bool visible) {
    // 根据窗口可见性切换菜单项
    m_actionShow->setVisible(!visible);
    m_actionHide->setVisible(visible);
}