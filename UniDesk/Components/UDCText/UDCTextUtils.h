#ifndef UDCTEXTUTILS_H
#define UDCTEXTUTILS_H

#include <QQuickItem>
#include <QtQml/qqml.h>
#include <QDateTime>
#include "singleton.h"
#include <cstdint>

struct CPUStats {
    double usagePercent; // CPU占用百分比
};

struct NetSnapshot {
    uint64_t bytesRecv, bytesSend;
    uint64_t packetsRecv, packetsSend;
    uint64_t dropRecv, dropSend;
};

struct NetworkStats {
    uint64_t bytesRecv;
    uint64_t bytesSend;
    uint64_t bytesRecvPerSec;
    uint64_t bytesSendPerSec;
    double dropPercent;
};

struct MemoryStats {
    uint64_t virtmemTotal;       // 总物理内存（字节）
    uint64_t virtmemUsed;        // 已用物理内存（字节）
    double virtmemPercent;       // 物理内存使用率
    uint64_t swapmemTotal;       // 总交换内存（字节）
    uint64_t swapmemUsed;        // 已用交换内存（字节）
    double swapmemPercent;       // 交换内存使用率
};

struct BatteryStats {
    int batteryPercent;         // 剩余电量百分比
    bool charging;              // 是否插入充电线
    int remainMinutes;          // 剩余时间（分钟），-1表示未知
};

struct SystemStats {
    CPUStats cpu;
    NetworkStats net;
    MemoryStats mem;
    BatteryStats bat;
};

class UDCTextUtils: public QObject{
    Q_OBJECT
    QML_NAMED_ELEMENT(LingmoColor)
    QML_SINGLETON
private:
    explicit UDCTextUtils();
public:
    SINGLETON(UDCTextUtils)
    static auto create(QQmlEngine*, QJSEngine*) { return getInstance(); }
    SystemStats getSystemStats();
};

#endif // UDCTEXTUTILS_H
