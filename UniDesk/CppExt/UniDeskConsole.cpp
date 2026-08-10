#include "UniDeskConsole.h"
#include <iostream>
#include <sstream>
#include <QTimer>
#include <QQuickItem>
#include <QMessageLogContext>
#include <QtLogging>
#include <QDateTime>

std::ostringstream* UniDeskConsole::s_qtOutput = nullptr;

void UniDeskConsole::qtMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg) {
    if (!s_qtOutput) return;
    QString prefix;
    switch (type) {
    case QtDebugMsg:    prefix = QStringLiteral("[Debug] "); break;
    case QtInfoMsg:     prefix = QStringLiteral("[Info] "); break;
    case QtWarningMsg:  prefix = QStringLiteral("[Warning] "); break;
    case QtCriticalMsg: prefix = QStringLiteral("[Critical] "); break;
    case QtFatalMsg:    prefix = QStringLiteral("[Fatal] "); break;
    default:            prefix = QStringLiteral("[Log] "); break;
    }
    QString ts = QDateTime::currentDateTime().toString(QStringLiteral("hh:mm:ss.zzz "));
    *s_qtOutput << (ts + prefix + msg).toStdString() << "\n";
    if (type == QtFatalMsg) {
        std::abort();
    }
}

UniDeskConsole::UniDeskConsole(QQuickItem *parent) : QQuickItem(parent) {
    
    
    m_timer = new QTimer(this);
    m_timer->setInterval(10);
    connect(m_timer, &QTimer::timeout, this, [this]() {
        if(consoleOutput)consoleContent(QString::fromStdString(consoleOutput->str()));
    });
    m_timer->start();
    
}
UniDeskConsole::~UniDeskConsole() {
    m_timer->stop();
    delete m_timer;
    if(consoleOutput)delete consoleOutput;
    s_qtOutput = nullptr;
}
void UniDeskConsole::setConsoleOutput(std::ostringstream* output) {
    consoleOutput = output;
    s_qtOutput = output;
    qInstallMessageHandler(&UniDeskConsole::qtMessageHandler);
}

