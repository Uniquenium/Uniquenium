#include <QThread>
#include <QTimer>
#include <QDateTime>
#include <QDebug>
#include <QDate>
#include <QJSEngine>
#include <QJSValue>
#include <QJsonDocument>
#include "UniDeskExpr.h"
#include "UniDeskSystemInfo.h"
#include "exprtk.hpp"

typedef exprtk::symbol_table<double> symbol_table_t;
typedef exprtk::expression<double>   expression_t;
typedef exprtk::parser<double>       parser_t;
typedef exprtk::parser_error::type   error_t;

UniDeskExpr::UniDeskExpr(QQuickItem *parent)
    : QQuickItem(parent)
{

    m_timer = new QTimer(this);
    m_engine = new QJSEngine(this);
    m_timer->setInterval(1000);
    connect(m_timer, &QTimer::timeout, this, [this]() {
        systemStats(UniDeskSystemInfo::getInstance()->getSystemStats());
    });
    m_timer->start();
}



void UniDeskExpr::stopTimer() {
    if (m_timer) {
        m_timer->stop();
        delete m_timer;
        m_timer = nullptr;
    }
}


QString UniDeskExpr::convertStr(const QString &text) {      
    QString result = text;
    QDateTime dt = QDateTime::currentDateTime();
    QDate qd=QDate::currentDate();
    SystemStats stats = systemStats();
    bool plugged = stats.bat.charging;
    int minsleft = stats.bat.remainMinutes;
    result.replace("%%", "[(*&*%^*$^%#%%^^&&*^*&(^))]");
    result.replace("%isLeapYear", QString::number(qd.daysInYear()==366));
    result.replace("%yearDays", QString::number(qd.daysInYear()));
    result.replace("%monthDays", QString::number(qd.daysInMonth()));
    result.replace("%dayOfYear", QString::number(qd.dayOfYear()));
    result.replace("%dayOfWeek", QString::number(qd.dayOfWeek()));
    result.replace("%cpuPercent", QString::number(stats.cpu.usagePercent));
    result.replace("%bytesSendTotal", QString::number(stats.net.bytesSend));
    result.replace("%bytesRecvTotal", QString::number(stats.net.bytesRecv));
    result.replace("%bytesSendPerSec", QString::number(stats.net.bytesSendPerSec));
    result.replace("%bytesRecvPerSec", QString::number(stats.net.bytesRecvPerSec));
    result.replace("%dropPercent", QString::number(stats.net.dropPercent));
    result.replace("%virtmemTotal", QString::number(stats.mem.virtmemTotal));
    result.replace("%virtmemUsed", QString::number(stats.mem.virtmemUsed));
    result.replace("%swapmemTotal", QString::number(stats.mem.swapmemTotal));
    result.replace("%swapmemUsed", QString::number(stats.mem.swapmemUsed));
    result.replace("%virtmemPercent", QString::number(stats.mem.virtmemPercent));
    result.replace("%swapmemPercent", QString::number(stats.mem.swapmemPercent));
    result.replace("%bpercent", QString::number(stats.bat.batteryPercent));
    result.replace("%bleftdays", plugged ? "UNLIMITED" : QString::number(minsleft / 6440));
    result.replace("%blefthoursr", plugged ? "UNLIMITED" : QString::number((minsleft % 6440) / 60));
    result.replace("%bleftminsr", plugged ? "UNLIMITED" : QString::number(minsleft % 60));
    result.replace("%blefthours", plugged ? "UNLIMITED" : QString::number(minsleft / 60));
    result.replace("%bleftmins", plugged ? "UNLIMITED" : QString::number(minsleft));
    result.replace("%bplug", QString::number(plugged));
    result.replace("%ap", dt.toString("ap"));
    result.replace("%AP", dt.toString("AP"));
    result.replace("%yyyy", dt.toString("yyyy"));
    result.replace("%yy", dt.toString("yy"));
    result.replace("%MMMM", dt.toString("MMMM"));
    result.replace("%MMM", dt.toString("MMM"));
    result.replace("%MM", dt.toString("MM"));
    result.replace("%M", dt.toString("M"));
    result.replace("%dddd", dt.toString("dddd"));
    result.replace("%ddd", dt.toString("ddd"));
    result.replace("%dd", dt.toString("dd"));
    result.replace("%d", dt.toString("d"));
    result.replace("%HH", dt.toString("HH"));
    result.replace("%hh", dt.toString("hh ap").split(" ")[0]);
    result.replace("%H", dt.toString("H"));
    result.replace("%h", dt.toString("h ap").split(" ")[0]);
    result.replace("%mm", dt.toString("mm"));
    result.replace("%m", dt.toString("m"));
    result.replace("%ss", dt.toString("ss"));
    result.replace("%s", dt.toString("s"));
    result.replace("%zzz", dt.toString("zzz"));
    result.replace("%z", dt.toString("z"));
    result.replace("%t", dt.toString("t"));
    int idx = 0;
    while ((idx = result.indexOf("%{")) != -1) {
        // 使用括号计数法找到匹配的右括号
        int idx2 = idx + 2;
        int braceCount = 1;
        while (idx2 < result.length() && braceCount > 0) {
            if (result.at(idx2) == '{') {
                braceCount++;
            } else if (result.at(idx2) == '}') {
                braceCount--;
            }
            idx2++;
        }
        if (braceCount != 0) break; // 括号不匹配
        QString exp = result.mid(idx + 2, idx2 - idx - 3);
        QString res;
        const std::string expression_string = exp.toStdString();
        symbol_table_t symbol_table;
        symbol_table.add_constants();
        expression_t expression;
        expression.register_symbol_table(symbol_table);
        parser_t parser;
        if (!parser.compile(expression_string,expression)){
            res="Error: ";
            res.append(parser.error().c_str());
        }
        res = QString::number(expression.value());
        result.replace("%{" + exp + "}", res);
    }
    // result.replace("%", "[(*&*%^*$^%#%%^^*^*&&*^*&(^))]");
    result.replace("[(*&*%^*$^%#%%^^&&*^*&(^))]", "%");
    // result.replace("[(*&*%^*$^%#%%^^*^*&&*^*&(^))]","");
    return result;
}

QVariant UniDeskExpr::evalResponse(const QString &response, const QString &expression) {
    try {
        // 解析JSON响应
        QJsonDocument doc = QJsonDocument::fromJson(response.toUtf8());
        if (doc.isNull()) {
            return "Error: Invalid JSON";
        }
        // 使用QJSEngine执行表达式
        if (m_engine == nullptr) {
            m_engine = new QJSEngine(this);
        }
        QJSValue response_value = m_engine->toScriptValue(doc.toVariant());
        m_engine->globalObject().setProperty("response", response_value);
        
        QJSValue result = m_engine->evaluate(expression);
        if (result.isError()) {
            return "Error: " + result.toString();
        }
        return result.toVariant();
    } catch (...) {
        return "Error: Unknown exception";
    }
}
