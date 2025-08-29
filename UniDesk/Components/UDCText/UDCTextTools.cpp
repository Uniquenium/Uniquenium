#include "UDCTextTools.h"
#include <pybind11/embed.h>
#include <QThread>
#include <QTimer>
#include <QDateTime>
#include <QDebug>

namespace py = pybind11;

UDCTextTools::UDCTextTools(QQuickItem *parent)
    : QQuickItem(parent)
{
    // 初始化所有属性为0
    cpuPercent(0);
    bytesSend(0);
    bytesRecv(0);
    bytesSendPerSec(0);
    bytesRecvPerSec(0);
    dropPercent(0);
    virtmemTotal(0);
    virtmemUsed(0);
    swapmemTotal(0);
    swapmemUsed(0);
    virtmemPercent(0);
    swapmemPercent(0);
}

void UDCTextTools::startThread() {
    QThread* thread = QThread::create([this]() {
        py::scoped_interpreter guard{};
        py::object psutil = py::module_::import("psutil");
        py::object calendar = py::module_::import("calendar");
        py::object datetime_mod = py::module_::import("datetime");
        py::object time_mod = py::module_::import("time");
        qint64 prevSend = 0, prevRecv = 0;
        while (true) {
            try {
                cpuPercent(psutil.attr("cpu_percent")().cast<double>());
                prevSend = bytesSend();
                prevRecv = bytesRecv();
                py::object netio = psutil.attr("net_io_counters")();
                bytesSend(netio.attr("bytes_sent").cast<qint64>());
                bytesRecv(netio.attr("bytes_recv").cast<qint64>());
                bytesSendPerSec(bytesSend() - prevSend);
                bytesRecvPerSec(bytesRecv() - prevRecv);
                // dropPercent
                qint64 dropin = netio.attr("dropin").cast<qint64>();
                qint64 dropout = netio.attr("dropout").cast<qint64>();
                double drop = (dropin + dropout) / double(dropin + dropout + bytesRecv() + bytesSend());
                dropPercent(drop);
                // virtmem
                py::object virtmem = psutil.attr("virtual_memory")();
                virtmemTotal(virtmem.attr("total").cast<qint64>());
                virtmemUsed(virtmem.attr("used").cast<qint64>());
                virtmemPercent(virtmem.attr("percent").cast<double>());
                // swapmem
                py::object swapmem = psutil.attr("swap_memory")();
                swapmemTotal(swapmem.attr("total").cast<qint64>());
                swapmemUsed(swapmem.attr("used").cast<qint64>());
                swapmemPercent(swapmem.attr("percent").cast<double>());
            } catch (const std::exception& e) {
                qDebug() << "psutil error:" << e.what();
            }
            Q_EMIT cpuPercentChanged();
            Q_EMIT bytesSendChanged();
            Q_EMIT bytesRecvChanged();
            Q_EMIT bytesSendPerSecChanged();
            Q_EMIT bytesRecvPerSecChanged();
            Q_EMIT dropPercentChanged();
            Q_EMIT virtmemTotalChanged();
            Q_EMIT virtmemUsedChanged();
            Q_EMIT swapmemTotalChanged();
            Q_EMIT swapmemUsedChanged();
            Q_EMIT virtmemPercentChanged();
            Q_EMIT swapmemPercentChanged();
            QThread::sleep(1);
        }
    });
    thread->start();
}

QString UDCTextTools::convertStr(const QString &text) {
    py::scoped_interpreter guard{};
    py::object psutil = py::module_::import("psutil");
    py::object calendar = py::module_::import("calendar");
    py::object datetime_mod = py::module_::import("datetime");
    py::object time_mod = py::module_::import("time");
    QString result = text;
    QDateTime dt = QDateTime::currentDateTime();
    py::object dt2 = datetime_mod.attr("datetime").attr("now")();
    py::object sensorbattery = psutil.attr("sensors_battery")();

    result.replace("%%", "[(*&*%^*$^%#%%^^&&*^*&(^))]");
    result.replace("%isLeapYear", QString::number(calendar.attr("isleap")(dt.toString("yyyy").toInt()).cast<bool>()));
    result.replace("%yearDays", QString::number(calendar.attr("isleap")(dt.toString("yyyy").toInt()).cast<bool>() ? 366 : 365));
    result.replace("%monthDays", QString::number(calendar.attr("monthrange")(dt.toString("yyyy").toInt(), dt.toString("M").toInt()).attr("__getitem__")(1).cast<int>()));
    result.replace("%cpuPercent", QString::number(cpuPercent()));
    result.replace("%bytesSendTotal", QString::number(bytesSend()));
    result.replace("%bytesRecvTotal", QString::number(bytesRecv()));
    result.replace("%bytesSendPerSec", QString::number(bytesSendPerSec()));
    result.replace("%bytesRecvPerSec", QString::number(bytesRecvPerSec()));
    result.replace("%dropPercent", QString::number(dropPercent()));
    result.replace("%virtmemTotal", QString::number(virtmemTotal()));
    result.replace("%virtmemUsed", QString::number(virtmemUsed()));
    result.replace("%swapmemTotal", QString::number(swapmemTotal()));
    result.replace("%swapmemUsed", QString::number(swapmemUsed()));
    result.replace("%virtmemPercent", QString::number(virtmemPercent()));
    result.replace("%swapmemPercent", QString::number(swapmemPercent()));
    result.replace("%dayOfYear", QString::number(dt2.attr("timetuple")().attr("tm_yday").cast<int>()));
    result.replace("%bpercent", QString::number(sensorbattery.attr("percent").cast<double>()));
    bool plugged = sensorbattery.attr("power_plugged").cast<bool>();
    int secsleft = sensorbattery.attr("secsleft").cast<int>();
    result.replace("%bleftdays", plugged ? "UNLIMITED" : QString::number(secsleft / 86400));
    result.replace("%blefthoursr", plugged ? "UNLIMITED" : QString::number((secsleft % 86400) / 6400));
    result.replace("%bleftminsr", plugged ? "UNLIMITED" : QString::number((secsleft % 3600) / 60));
    result.replace("%bleftsecsr", plugged ? "UNLIMITED" : QString::number(secsleft % 60));
    result.replace("%blefthours", plugged ? "UNLIMITED" : QString::number(secsleft / 3600));
    result.replace("%bleftmins", plugged ? "UNLIMITED" : QString::number(secsleft / 60));
    result.replace("%bleftsecs", plugged ? "UNLIMITED" : QString::number(secsleft));
    result.replace("%bplug", QString::number(plugged));
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
    result.replace("%hh", dt.toString("hh"));
    result.replace("%h", dt.toString("h"));
    result.replace("%H", QString::fromStdString(dt2.attr("strftime")("%I").cast<std::string>()));
    result.replace("%mm", dt.toString("mm"));
    result.replace("%m", dt.toString("m"));
    result.replace("%ss", dt.toString("ss"));
    result.replace("%s", dt.toString("s"));
    result.replace("%zzzzzz", QString::fromStdString(dt2.attr("strftime")("%f").cast<std::string>()));
    result.replace("%zzz", dt.toString("zzz"));
    result.replace("%z", dt.toString("z"));
    result.replace("%U", QString::fromStdString(dt2.attr("strftime")("%U").cast<std::string>()));
    result.replace("%W", QString::fromStdString(dt2.attr("strftime")("%W").cast<std::string>()));
    result.replace("%j", QString::number(dt2.attr("strftime")("%j").cast<int>()));
    result.replace("%J", QString::fromStdString(dt2.attr("strftime")("%j").cast<std::string>()));
    result.replace("%p", dt.toString("ap"));
    result.replace("%P", dt.toString("AP"));
    result.replace("%t", dt.toString("t"));

    // %{exp} 表达式支持
    int idx = 0;
    while ((idx = result.indexOf("%{")) != -1) {
        int idx2 = result.indexOf("}", idx);
        if (idx2 == -1) break;
        QString exp = result.mid(idx + 2, idx2 - idx - 2);
        QString res;
        try {
            py::object eval_result = py::eval(exp.toStdString());
            res = QString::fromStdString(py::str(eval_result).cast<std::string>());
        } catch (const std::exception& e) {
            res = QString("ERROR: ") + e.what();
        }
        result.replace("%{" + exp + "}", res);
    }

    result.replace("[(*&*%^*$^%#%%^^&&*^*&(^))]", "%");
    return result;
}

// Getter实现
double UDCTextTools::cpuPercent() const { return m_cpuPercent; }
qint64 UDCTextTools::bytesSend() const { return m_bytesSend; }
qint64 UDCTextTools::bytesRecv() const { return m_bytesRecv; }
qint64 UDCTextTools::bytesSendPerSec() const { return m_bytesSendPerSec; }
qint64 UDCTextTools::bytesRecvPerSec() const { return m_bytesRecvPerSec; }
double UDCTextTools::dropPercent() const { return m_dropPercent; }
qint64 UDCTextTools::virtmemTotal() const { return m_virtmemTotal; }
qint64 UDCTextTools::virtmemUsed() const { return m_virtmemUsed; }
qint64 UDCTextTools::swapmemTotal() const { return m_swapmemTotal; }
qint64 UDCTextTools::swapmemUsed() const { return m_swapmemUsed; }
double UDCTextTools::virtmemPercent() const { return m_virtmemPercent; }
double UDCTextTools::swapmemPercent() const { return m_swapmemPercent; }