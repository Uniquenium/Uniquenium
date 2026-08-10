
#ifndef UNIDESKCONSOLE_H
#define UNIDESKCONSOLE_H

#include "stdafx.h"
#include "singleton.h"
#include <QQuickItem>
#include <QTimer>
#include <QJsonObject>
#include <QQmlEngine>
#include <QJSEngine>
#include <QTimer>
#include <sstream>



class UniDeskConsole : public QQuickItem {
    Q_OBJECT
    Q_PROPERTY_AUTO_P(QString,consoleContent)
    QML_NAMED_ELEMENT(UniDeskConsole)
    QML_SINGLETON
private:
    explicit UniDeskConsole(QQuickItem *parent = nullptr);
    ~UniDeskConsole();
    QTimer *m_timer = nullptr;
    std::ostringstream* consoleOutput = nullptr;
    static std::ostringstream* s_qtOutput;
    static void qtMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg);
    
public:
    SINGLETON(UniDeskConsole)
    static auto create(QQmlEngine*, QJSEngine*) { return getInstance(); }
    Q_INVOKABLE void setConsoleOutput(std::ostringstream* output) ;
};

#endif // UNIDESKCONSOLE_H