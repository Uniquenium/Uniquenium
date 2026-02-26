#include <QThread>
#include <QTimer>
#include <QDateTime>
#include <QDebug>
#include "UDCTextUtils.h"

UDCTextUtils::UDCTextUtils() {}

#ifdef Q_OS_WIN
#include <windows.h>
#include <iphlpapi.h>
#pragma comment(lib, "iphlpapi.lib")

static NetSnapshot last;

CPUStats getCPUStats_win() {
    static FILETIME prevIdleTime, prevKernelTime, prevUserTime;
    CPUStats stats{};
    FILETIME idleTime, kernelTime, userTime;
    GetSystemTimes(&idleTime, &kernelTime, &userTime);

    if (prevIdleTime.dwLowDateTime == 0 && prevIdleTime.dwHighDateTime == 0) {
        prevIdleTime = idleTime;
        prevKernelTime = kernelTime;
        prevUserTime = userTime;
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
        return getCPUStats_win();
    }

    ULARGE_INTEGER idle, kernel, user;
    idle.LowPart = idleTime.dwLowDateTime;
    idle.HighPart = idleTime.dwHighDateTime;

    kernel.LowPart = kernelTime.dwLowDateTime;
    kernel.HighPart = kernelTime.dwHighDateTime;

    user.LowPart = userTime.dwLowDateTime;
    user.HighPart = userTime.dwHighDateTime;

    ULARGE_INTEGER prevIdle, prevKernel, prevUser;
    prevIdle.LowPart = prevIdleTime.dwLowDateTime;
    prevIdle.HighPart = prevIdleTime.dwHighDateTime;

    prevKernel.LowPart = prevKernelTime.dwLowDateTime;
    prevKernel.HighPart = prevKernelTime.dwHighDateTime;

    prevUser.LowPart = prevUserTime.dwLowDateTime;
    prevUser.HighPart = prevUserTime.dwHighDateTime;

    ULONGLONG sys = (kernel.QuadPart - prevKernel.QuadPart) + (user.QuadPart - prevUser.QuadPart);
    ULONGLONG idleDiff = idle.QuadPart - prevIdle.QuadPart;

    prevIdleTime = idleTime;
    prevKernelTime = kernelTime;
    prevUserTime = userTime;

    stats.usagePercent = sys ? (double)(sys - idleDiff) * 100.0 / sys : 0.0;
    return stats;
}

NetSnapshot getWinNetSnapshot(DWORD index = 0) {
    DWORD dwSize = 0;
    GetIfTable(nullptr, &dwSize, FALSE);
    PMIB_IFTABLE pIfTable = (PMIB_IFTABLE)malloc(dwSize);
    NetSnapshot snap{};
    if (GetIfTable(pIfTable, &dwSize, FALSE) == NO_ERROR && index < pIfTable->dwNumEntries) {
        auto& row = pIfTable->table[index];
        snap.bytesRecv = row.dwInOctets;
        snap.bytesSend = row.dwOutOctets;
        snap.packetsRecv = row.dwInUcastPkts + row.dwInNUcastPkts;
        snap.packetsSend = row.dwOutUcastPkts + row.dwOutNUcastPkts;
        snap.dropRecv = row.dwInDiscards;
        snap.dropSend = row.dwOutDiscards;
    }
    free(pIfTable);
    return snap;
}

NetworkStats getNetworkStats_win() {
    NetSnapshot now = getWinNetSnapshot();
    NetworkStats ns{};
    ns.bytesRecv = now.bytesRecv;
    ns.bytesSend = now.bytesSend;
    ns.bytesRecvPerSec = now.bytesRecv - last.bytesRecv;
    ns.bytesSendPerSec = now.bytesSend - last.bytesSend;

    uint64_t deltaPacketsRecv = now.packetsRecv - last.packetsRecv;
    uint64_t deltaPacketsSend = now.packetsSend - last.packetsSend;
    uint64_t deltaDropRecv = now.dropRecv - last.dropRecv;
    uint64_t deltaDropSend = now.dropSend - last.dropSend;

    uint64_t totalPackets = deltaPacketsRecv + deltaPacketsSend;
    uint64_t totalDrops = deltaDropRecv + deltaDropSend;
    ns.dropPercent = totalPackets ? (double)totalDrops / totalPackets * 100 : 0;

    last = now;
    return ns;
}

MemoryStats getMemoryStats_win() {
    MEMORYSTATUSEX memstat;
    memstat.dwLength = sizeof(memstat);
    MemoryStats stats = {};
    GlobalMemoryStatusEx(&memstat);
    stats.virtmemTotal = memstat.ullTotalPhys;
    stats.virtmemUsed = memstat.ullTotalPhys - memstat.ullAvailPhys;
    stats.virtmemPercent = memstat.dwMemoryLoad;
    stats.swapmemTotal = memstat.ullTotalPageFile;
    stats.swapmemUsed = memstat.ullTotalPageFile - memstat.ullAvailPageFile;
    stats.swapmemPercent = stats.swapmemTotal ?
                               (double)stats.swapmemUsed / stats.swapmemTotal * 100 : 0.0;
    return stats;
}

BatteryStats getBatteryStats_win() {
    SYSTEM_POWER_STATUS sps;
    BatteryStats stats = {};
    if (GetSystemPowerStatus(&sps)) {
        stats.batteryPercent = sps.BatteryLifePercent;
        stats.charging = (sps.ACLineStatus == 1);
        if (sps.BatteryLifeTime != -1 && sps.BatteryLifeTime != 255)
            stats.remainMinutes = sps.BatteryLifeTime / 60;
        else
            stats.remainMinutes = -1;
    }
    return stats;
}

#elif Q_OS_LINUX
#include <fstream>
#include <string>
#include <sstream>
#include <thread>
#include <chrono>

static NetSnapshot last;

CPUStats getCPUStats_linux() {
    static uint64_t lastIdle=0, lastTotal=0;
    CPUStats stats{};
    std::ifstream file("/proc/stat");
    std::string line;
    if (!std::getline(file, line))
        return stats;
    std::istringstream ss(line);
    std::string cpu;
    uint64_t user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice;
    ss >> cpu >> user >> nice >> system >> idle >> iowait >> irq >> softirq >> steal >> guest >> guest_nice;

    uint64_t idleTime = idle + iowait;
    uint64_t totalTime = user + nice + system + idle + iowait + irq + softirq + steal;

    if(lastTotal == 0) {
        lastIdle = idleTime;
        lastTotal = totalTime;
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
        return getCPUStats_linux();
    }

    uint64_t totald = totalTime - lastTotal;
    uint64_t idled = idleTime - lastIdle;
    if(totald)
        stats.usagePercent = (double)(totald - idled) * 100.0 / totald;
    else
        stats.usagePercent = 0.0;

    lastIdle = idleTime;
    lastTotal = totalTime;
    return stats;
}

NetSnapshot getNetSnapshot_linux(const std::string& iface) {
    std::ifstream file("/proc/net/dev");
    std::string line;
    NetSnapshot snap{};
    while(std::getline(file, line)) {
        if(line.find(iface) != std::string::npos) {
            std::istringstream iss(line.substr(line.find(":")+1));
            iss >> snap.bytesRecv
                >> snap.packetsRecv
                >> snap.dropRecv;
            for(int i=0;i<5;i++) iss >> std::ws;  // 跳到发送部分
            iss >> snap.bytesSend
                >> snap.packetsSend
                >> snap.dropSend;
            break;
        }
    }
    return snap;
}

NetworkStats getNetworkStats_linux(const std::string& iface) {
    NetSnapshot now = getNetSnapshot_linux(iface);
    NetworkStats ns{};
    ns.bytesRecv = now.bytesRecv;
    ns.bytesSend = now.bytesSend;
    ns.bytesRecvPerSec = now.bytesRecv - last.bytesRecv;
    ns.bytesSendPerSec = now.bytesSend - last.bytesSend;

    uint64_t deltaPacketsRecv = now.packetsRecv - last.packetsRecv;
    uint64_t deltaPacketsSend = now.packetsSend - last.packetsSend;
    uint64_t deltaDropRecv = now.dropRecv - last.dropRecv;
    uint64_t deltaDropSend = now.dropSend - last.dropSend;

    uint64_t totalPackets = deltaPacketsRecv + deltaPacketsSend;
    uint64_t totalDrops = deltaDropRecv + deltaDropSend;
    ns.dropPercent = totalPackets ? (double)totalDrops / totalPackets * 100 : 0;

    last = now;
    return ns;
}

MemoryStats getMemoryStats_linux() {
    MemoryStats stats = {};
    std::ifstream file("/proc/meminfo");
    std::string key;
    uint64_t value;
    std::string unit;
    uint64_t total=0, available=0, swapTotal=0, swapFree=0;
    while(file >> key >> value >> unit) {
        if(key == "MemTotal:") total = value;
        else if(key == "MemAvailable:") available = value;
        else if(key == "SwapTotal:") swapTotal = value;
        else if(key == "SwapFree:") swapFree = value;
    }
    stats.virtmemTotal = total*1024;
    stats.virtmemUsed = (total - available)*1024;
    stats.virtmemPercent = total ? (double)(total-available)/total*100 : 0;
    stats.swapmemTotal = swapTotal*1024;
    stats.swapmemUsed = (swapTotal - swapFree)*1024;
    stats.swapmemPercent = swapTotal ? (double)(swapTotal-swapFree)/swapTotal*100 : 0;
    return stats;
}

BatteryStats getBatteryStats_linux() {
    BatteryStats stats = {};
    std::ifstream capFile("/sys/class/power_supply/BAT0/capacity");
    if(capFile.is_open()) {
        capFile >> stats.batteryPercent;
        capFile.close();
    }
    std::ifstream statusFile("/sys/class/power_supply/BAT0/status");
    std::string stat;
    if(statusFile.is_open()) {
        statusFile >> stat;
        statusFile.close();
        stats.charging = (stat == "Charging");
    }
    std::ifstream energyFile("/sys/class/power_supply/BAT0/energy_now");
    std::ifstream powerFile("/sys/class/power_supply/BAT0/power_now");
    int energy_now = 0, power_now = 0;
    if(energyFile.is_open()) energyFile >> energy_now;
    if(powerFile.is_open()) powerFile >> power_now;
    if(power_now > 0 && stat == "Discharging")
        stats.remainMinutes = energy_now / power_now * 60;
    else
        stats.remainMinutes = -1;
    return stats;
}

#endif

SystemStats UDCTextUtils::getSystemStats() {
    SystemStats s;
#ifdef Q_OS_WIN
    s.cpu = getCPUStats_win();
    s.net = getNetworkStats_win();
    s.mem = getMemoryStats_win();
    s.bat = getBatteryStats_win();
#elif defined(Q_OS_LINUX)
    s.cpu = getCPUStats_linux();
    s.net = getNetworkStats_linux("eth0");
    s.mem = getMemoryStats_linux();
    s.bat = getBatteryStats_linux();
#endif
    return s;
}
