#ifndef UDCSYSTEMINFO_H
#define UDCSYSTEMINFO_H

#include <QQuickItem>
#include <QtQml/qqml.h>
#include <QDateTime>
#include <QString>
#include <QMutex>
#include "singleton.h"
#include <cstdint>

struct CPUStats {
    double usagePercent;
    QString name;
    int physicalCores;
    int logicalCores;
    double maxClockMHz;
    double temperature;
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
    uint64_t virtmemTotal;
    uint64_t virtmemUsed;
    double virtmemPercent;
    uint64_t swapmemTotal;
    uint64_t swapmemUsed;
    double swapmemPercent;
};

struct BatteryStats {
    int batteryPercent;
    bool charging;
    int remainMinutes;
};

struct GPUStats {
    QString name;
    double usagePercent;
    double temperature;
    uint64_t vramTotal;
    uint64_t vramUsed;
};

struct DiskStats {
    uint64_t totalSpace;
    uint64_t freeSpace;
    double usagePercent;
};

struct SystemInfo {
    quint64 uptimeSeconds;
    QString hostname;
    QString osName;
    int screenWidth;
    int screenHeight;
};

struct SystemStats {
    CPUStats cpu;
    NetworkStats net;
    MemoryStats mem;
    BatteryStats bat;
    GPUStats gpu;
    DiskStats disk;
    SystemInfo sysInfo;
};

class UniDeskSystemInfo: public QObject{
    Q_OBJECT
    QML_NAMED_ELEMENT(UniDeskSystemInfo)
    QML_SINGLETON
private:
    explicit UniDeskSystemInfo();
    SystemStats cachedStats;
    QMutex statsMutex;
    void updateStatsInBackground();
public:
    SINGLETON(UniDeskSystemInfo)
    static auto create(QQmlEngine*, QJSEngine*) { return getInstance(); }
    SystemStats getSystemStats();
};

#endif // UNIDEKSYSTEMINFO_H