#include <QThread>
#include <QTimer>
#include <QDateTime>
#include <QDebug>
#include <QSysInfo>
#include <QScreen>
#include <QGuiApplication>
#include <QRegularExpression>
#include <QMutex>
#include <QtConcurrent>
#include <QThreadPool>
#include "UniDeskSystemInfo.h"

static SystemStats doQueryAllStats();

UniDeskSystemInfo::UniDeskSystemInfo() {
    cachedStats = doQueryAllStats();

    QTimer* timer = new QTimer(this);
    connect(timer, &QTimer::timeout, this, &UniDeskSystemInfo::updateStatsInBackground);
    timer->start(1000);
}

#ifdef Q_OS_WIN
#include <windows.h>
#include <iphlpapi.h>
#include <dxgi.h>
#include <pdh.h>
#include <tchar.h>
#include <comdef.h>
#include <Wbemidl.h>
#include <QProcess>

#pragma comment(lib, "iphlpapi.lib")
#pragma comment(lib, "dxgi.lib")
#pragma comment(lib, "pdh.lib")
#pragma comment(lib, "wbemuuid.lib")

static NetSnapshot last;

static double getCPUTemperature_win() {
    static QDateTime lastAttempt;
    static double cachedTemp = -1.0;

    if (!lastAttempt.isNull() && lastAttempt.msecsTo(QDateTime::currentDateTime()) < 3000) {
        return cachedTemp;
    }
    lastAttempt = QDateTime::currentDateTime();

    double temp = -1.0;

    HKEY hKey;
    LONG lRes = RegOpenKeyExW(HKEY_LOCAL_MACHINE,
        L"HARDWARE\\DESCRIPTION\\System\\BIOS", 0, KEY_READ, &hKey);
    if (lRes == ERROR_SUCCESS) {
        BYTE buf[16];
        DWORD bufSize = sizeof(buf);
        DWORD type = REG_BINARY;
        if (RegQueryValueExW(hKey, L"CPU_Temperature", NULL, &type, buf, &bufSize) == ERROR_SUCCESS) {
            if (bufSize >= 2) {
                temp = (double)(buf[0] | (buf[1] << 8));
                if (temp > 0 && temp < 150) {
                    RegCloseKey(hKey);
                    cachedTemp = temp;
                    return temp;
                }
            }
        }
        RegCloseKey(hKey);
    }

    HRESULT hr = CoInitializeEx(NULL, COINIT_APARTMENTTHREADED);
    bool comInitialized = SUCCEEDED(hr) || hr == RPC_E_CHANGED_MODE;

    if (comInitialized) {
        IWbemLocator* pLoc = nullptr;
        hr = CoCreateInstance(CLSID_WbemLocator, 0, CLSCTX_INPROC_SERVER,
                             IID_IWbemLocator, (LPVOID*)&pLoc);
        if (SUCCEEDED(hr)) {
            IWbemServices* pSvc = nullptr;
            hr = pLoc->ConnectServer(_bstr_t(L"root\\wmi"), NULL, NULL, NULL,
                                      0, NULL, NULL, &pSvc);
            pLoc->Release();
            if (SUCCEEDED(hr)) {
                CoSetProxyBlanket(pSvc, RPC_C_AUTHN_WINNT, RPC_C_AUTHZ_NONE, NULL,
                                  RPC_C_AUTHN_LEVEL_CALL, RPC_C_IMP_LEVEL_IMPERSONATE,
                                  NULL, EOAC_NONE);

                IEnumWbemClassObject* pEnum = nullptr;
                hr = pSvc->ExecQuery(_bstr_t(L"WQL"),
                    _bstr_t(L"SELECT * FROM MSAcpi_ThermalZoneTemperature"),
                    WBEM_FLAG_FORWARD_ONLY | WBEM_FLAG_RETURN_IMMEDIATELY, NULL, &pEnum);
                if (SUCCEEDED(hr) && pEnum) {
                    IWbemClassObject* pObj = nullptr;
                    ULONG uReturn = 0;
                    if (pEnum->Next(WBEM_INFINITE, 1, &pObj, &uReturn) == S_OK && uReturn > 0) {
                        VARIANT vtProp;
                        if (pObj->Get(L"CurrentTemperature", 0, &vtProp, 0, 0) == S_OK) {
                            if (vtProp.vt == VT_I4) {
                                temp = (double)(vtProp.lVal - 2732) / 10.0;
                            }
                            VariantClear(&vtProp);
                        }
                        pObj->Release();
                    }
                    pEnum->Release();
                }

                if (temp < 0) {
                    pEnum = nullptr;
                    hr = pSvc->ExecQuery(_bstr_t(L"WQL"),
                        _bstr_t(L"SELECT * FROM Win32_TemperatureProbe"),
                        WBEM_FLAG_FORWARD_ONLY | WBEM_FLAG_RETURN_IMMEDIATELY, NULL, &pEnum);
                    if (SUCCEEDED(hr) && pEnum) {
                        IWbemClassObject* pObj = nullptr;
                        ULONG uReturn = 0;
                        if (pEnum->Next(WBEM_INFINITE, 1, &pObj, &uReturn) == S_OK && uReturn > 0) {
                            VARIANT vtProp;
                            if (pObj->Get(L"CurrentReading", 0, &vtProp, 0, 0) == S_OK) {
                                if (vtProp.vt == VT_I4) {
                                    temp = (double)vtProp.lVal / 10.0;
                                }
                                VariantClear(&vtProp);
                            }
                            pObj->Release();
                        }
                        pEnum->Release();
                    }
                }

                pSvc->Release();
            }
        }
        CoUninitialize();
    }

    if (temp > 0 && temp < 150) {
        cachedTemp = temp;
    }
    return temp;
}

static double getGPUTemperature_win(const QString& gpuName) {
    static QDateTime lastAttempt;
    static double cachedTemp = -1.0;

    if (!lastAttempt.isNull() && lastAttempt.msecsTo(QDateTime::currentDateTime()) < 3000) {
        return cachedTemp;
    }
    lastAttempt = QDateTime::currentDateTime();

    double temp = -1.0;

    QProcess proc;
    proc.start("nvidia-smi", {"--query-gpu=temperature.gpu", "--format=csv,noheader,nounits"});
    if (proc.waitForFinished(2000) && proc.exitCode() == 0) {
        QString output = QString::fromUtf8(proc.readAllStandardOutput()).trimmed();
        if (!output.isEmpty()) {
            temp = output.toDouble();
            if (temp > 0 && temp < 150) {
                cachedTemp = temp;
                return temp;
            }
        }
    }

    if (gpuName.contains("NVIDIA", Qt::CaseInsensitive)) {
        proc.close();
        proc.start("nvidia-smi", {"-t", "--gpu-index=0"});
        if (proc.waitForFinished(3000) && proc.exitCode() == 0) {
            QString output = QString::fromUtf8(proc.readAllStandardOutput());
            QRegularExpression re(R"(\d+\s*C)");
            QRegularExpressionMatch match = re.match(output);
            if (match.hasMatch()) {
                QString tempStr = match.captured(0);
                tempStr.chop(1);
                temp = tempStr.toDouble();
            }
        }
    }

    if (temp > 0 && temp < 150) {
        cachedTemp = temp;
    }
    return temp;
}

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

    static QString cachedCpuName;
    static double cachedCpuMaxClock = -1;
    static bool cpuStaticCached = false;

    if (!cpuStaticCached) {
        cpuStaticCached = true;

        HKEY hKey;
        LONG lRes = RegOpenKeyExW(HKEY_LOCAL_MACHINE,
            L"HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\0",
            0, KEY_READ, &hKey);

        if (lRes == ERROR_SUCCESS) {
            TCHAR buf[256];
            DWORD bufSize = sizeof(buf);
            DWORD type = REG_SZ;
            if (RegQueryValueExW(hKey, L"ProcessorNameString", NULL, &type, (LPBYTE)buf, &bufSize) == ERROR_SUCCESS) {
                cachedCpuName = QString::fromWCharArray(buf);
            }
            DWORD maxMhz = 0;
            bufSize = sizeof(maxMhz);
            type = REG_DWORD;
            if (RegQueryValueExW(hKey, L"MaxClockSpeed", NULL, &type, (LPBYTE)&maxMhz, &bufSize) == ERROR_SUCCESS) {
                cachedCpuMaxClock = maxMhz;
            }
            RegCloseKey(hKey);
        }

        if (cachedCpuMaxClock <= 0) {
            HRESULT hr = CoInitializeEx(NULL, COINIT_APARTMENTTHREADED);
            if (SUCCEEDED(hr) || hr == RPC_E_CHANGED_MODE) {
                IWbemLocator* pLoc = nullptr;
                hr = CoCreateInstance(CLSID_WbemLocator, 0, CLSCTX_INPROC_SERVER,
                                       IID_IWbemLocator, (LPVOID*)&pLoc);
                if (SUCCEEDED(hr)) {
                    IWbemServices* pCpuSvc = nullptr;
                    hr = pLoc->ConnectServer(_bstr_t(L"root\\cimv2"), NULL, NULL, NULL,
                                              0, NULL, NULL, &pCpuSvc);
                    pLoc->Release();
                    if (SUCCEEDED(hr)) {
                        CoSetProxyBlanket(pCpuSvc, RPC_C_AUTHN_WINNT, RPC_C_AUTHZ_NONE, NULL,
                                           RPC_C_AUTHN_LEVEL_CALL, RPC_C_IMP_LEVEL_IMPERSONATE,
                                           NULL, EOAC_NONE);
                        IEnumWbemClassObject* pEnum = nullptr;
                        hr = pCpuSvc->ExecQuery(_bstr_t(L"WQL"),
                            _bstr_t(L"SELECT MaxClockSpeed, Name FROM Win32_Processor"),
                            WBEM_FLAG_FORWARD_ONLY | WBEM_FLAG_RETURN_IMMEDIATELY, NULL, &pEnum);
                        if (SUCCEEDED(hr) && pEnum) {
                            IWbemClassObject* pObj = nullptr;
                            ULONG uReturn = 0;
                            if (pEnum->Next(WBEM_INFINITE, 1, &pObj, &uReturn) == S_OK && uReturn > 0) {
                                VARIANT vtProp;
                                if (pObj->Get(L"MaxClockSpeed", 0, &vtProp, 0, 0) == S_OK) {
                                    if (vtProp.vt == VT_UI4) cachedCpuMaxClock = vtProp.ulVal;
                                    else if (vtProp.vt == VT_I4) cachedCpuMaxClock = vtProp.lVal;
                                    VariantClear(&vtProp);
                                }
                                if (cachedCpuName.isEmpty() && pObj->Get(L"Name", 0, &vtProp, 0, 0) == S_OK) {
                                    cachedCpuName = QString::fromWCharArray(vtProp.bstrVal);
                                    VariantClear(&vtProp);
                                }
                                pObj->Release();
                            }
                            pEnum->Release();
                        }
                        pCpuSvc->Release();
                    }
                }
                CoUninitialize();
            }
        }
    }

    stats.name = cachedCpuName;
    stats.maxClockMHz = cachedCpuMaxClock;

    SYSTEM_INFO sysInfo;
    GetSystemInfo(&sysInfo);
    stats.logicalCores = sysInfo.dwNumberOfProcessors;
    stats.physicalCores = sysInfo.dwNumberOfProcessors / 2;

    if (stats.name.isEmpty())
        stats.name = QStringLiteral("Unknown CPU");

    stats.temperature = getCPUTemperature_win();

    return stats;
}

NetworkStats getNetworkStats_win() {
    DWORD dwSize = 0;
    GetIfTable(nullptr, &dwSize, FALSE);
    PMIB_IFTABLE pIfTable = (PMIB_IFTABLE)malloc(dwSize);
    static uint64_t lastRecv = 0, lastSend = 0;
    static uint64_t lastPacketsRecv = 0, lastPacketsSend = 0;
    static uint64_t lastDropRecv = 0, lastDropSend = 0;
    NetworkStats ns{};
    uint64_t packetsRecv = 0, packetsSend = 0, dropRecv = 0, dropSend = 0;

    if (GetIfTable(pIfTable, &dwSize, FALSE) == NO_ERROR) {
        for (DWORD i = 0; i < pIfTable->dwNumEntries; ++i) {
            auto& row = pIfTable->table[i];
            if (row.dwType == MIB_IF_TYPE_LOOPBACK )
                continue;
            ns.bytesRecv += row.dwInOctets;
            ns.bytesSend += row.dwOutOctets;
            packetsRecv += row.dwInUcastPkts + row.dwInNUcastPkts;
            packetsSend += row.dwOutUcastPkts + row.dwOutNUcastPkts;
            dropRecv += row.dwInDiscards;
            dropSend += row.dwOutDiscards;
        }
    }
    free(pIfTable);

    ns.bytesRecvPerSec = ns.bytesRecv - lastRecv;
    ns.bytesSendPerSec = ns.bytesSend - lastSend;

    uint64_t deltaPackets = (packetsRecv - lastPacketsRecv) + (packetsSend - lastPacketsSend);
    uint64_t deltaDrops   = (dropRecv - lastDropRecv) + (dropSend - lastDropSend);

    ns.dropPercent = deltaPackets ? (double)deltaDrops / deltaPackets * 100.0 : 0.0;

    lastRecv = ns.bytesRecv;
    lastSend = ns.bytesSend;
    lastPacketsRecv = packetsRecv;
    lastPacketsSend = packetsSend;
    lastDropRecv = dropRecv;
    lastDropSend = dropSend;

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

GPUStats getGPUStats_win() {
    GPUStats stats{};
    stats.usagePercent = -1.0;
    stats.temperature = -1.0;

    static QString cachedGpuName;
    static uint64_t cachedVramTotal = 0;
    static bool gpuStaticCached = false;

    if (!gpuStaticCached) {
        gpuStaticCached = true;

        IDXGIFactory1* pFactory = nullptr;
        HRESULT hr = CreateDXGIFactory1(__uuidof(IDXGIFactory1), (void**)&pFactory);
        if (SUCCEEDED(hr)) {
            IDXGIAdapter1* pAdapter = nullptr;
            for (UINT i = 0; pFactory->EnumAdapters1(i, &pAdapter) != DXGI_ERROR_NOT_FOUND; ++i) {
                DXGI_ADAPTER_DESC1 desc;
                pAdapter->GetDesc1(&desc);
                if (!(desc.Flags & DXGI_ADAPTER_FLAG_SOFTWARE)) {
                    cachedGpuName = QString::fromWCharArray(desc.Description);
                    cachedVramTotal = desc.DedicatedVideoMemory;
                    break;
                }
                pAdapter->Release();
                pAdapter = nullptr;
            }
            pFactory->Release();
        }
    }

    stats.name = cachedGpuName;
    stats.vramTotal = cachedVramTotal;

    static QDateTime lastNvidiaAttempt;
    static bool nvidiaAvailable = false;
    bool canTryNvidia = nvidiaAvailable || lastNvidiaAttempt.isNull() ||
                         lastNvidiaAttempt.msecsTo(QDateTime::currentDateTime()) > 60000;

    if (canTryNvidia) {
        lastNvidiaAttempt = QDateTime::currentDateTime();

        QProcess proc;
        proc.start("nvidia-smi", {"--query-gpu=memory.used,memory.total,utilization.gpu", "--format=csv,noheader,nounits"});
        if (proc.waitForFinished(2000) && proc.exitCode() == 0) {
            QString output = QString::fromUtf8(proc.readAllStandardOutput()).trimmed();
            if (!output.isEmpty()) {
                QStringList parts = output.split(",");
                if (parts.size() >= 3) {
                    bool ok1 = false, ok2 = false, ok3 = false;
                    qulonglong usedMB = parts[0].trimmed().toULongLong(&ok1);
                    qulonglong totalMB = parts[1].trimmed().toULongLong(&ok2);
                    double utilization = parts[2].trimmed().toDouble(&ok3);

                    if (ok1 && ok2 && ok3) {
                        stats.vramUsed = usedMB * 1024 * 1024;
                        if (stats.vramTotal == 0)
                            stats.vramTotal = totalMB * 1024 * 1024;
                        stats.usagePercent = qBound(0.0, utilization, 100.0);
                        nvidiaAvailable = true;
                    }
                }
            }
        } else {
            nvidiaAvailable = false;
        }
    }

    if (stats.usagePercent < 0 || stats.vramUsed == 0) {
        static PDH_HQUERY hQuery = nullptr;
        static PDH_HCOUNTER hCounter = nullptr;
        static bool pdhInitAttempted = false;

        if (!pdhInitAttempted) {
            pdhInitAttempted = true;
            if (PdhOpenQuery(NULL, 0, &hQuery) == ERROR_SUCCESS) {
                const wchar_t* counterPath = L"\\GPU Engine(*)\\Utilized GPU Bandwidth";
                if (PdhAddCounterW(hQuery, counterPath, 0, &hCounter) != ERROR_SUCCESS) {
                    hCounter = nullptr;
                }
            }
        }

        if (hQuery && hCounter) {
            PdhCollectQueryData(hQuery);
            PDH_FMT_COUNTERVALUE val;
            if (PdhGetFormattedCounterValue(hCounter, PDH_FMT_DOUBLE, NULL, &val) == ERROR_SUCCESS) {
                double v = val.doubleValue;
                stats.usagePercent = qBound(0.0, v, 100.0);
            }
        }
    }

    stats.temperature = getGPUTemperature_win(stats.name);

    return stats;
}

DiskStats getDiskStats_win() {
    DiskStats stats{};
    ULARGE_INTEGER freeBytes, totalBytes;
    if (GetDiskFreeSpaceExW(L"C:\\", NULL, &totalBytes, &freeBytes)) {
        stats.totalSpace = totalBytes.QuadPart;
        stats.freeSpace = freeBytes.QuadPart;
        if (stats.totalSpace > 0)
            stats.usagePercent = (double)(stats.totalSpace - stats.freeSpace) / stats.totalSpace * 100.0;
    }
    return stats;
}

SystemInfo getSystemInfo_win() {
    SystemInfo info{};
    info.uptimeSeconds = GetTickCount64() / 1000;

    wchar_t hostname[MAX_COMPUTERNAME_LENGTH + 1];
    DWORD size = sizeof(hostname) / sizeof(wchar_t);
    if (GetComputerNameW(hostname, &size))
        info.hostname = QString::fromWCharArray(hostname);

    info.osName = QSysInfo::prettyProductName();

    QScreen* screen = QGuiApplication::primaryScreen();
    if (screen) {
        info.screenWidth = screen->geometry().width();
        info.screenHeight = screen->geometry().height();
    }

    return info;
}

#elif defined(Q_OS_LINUX)
#include <fstream>
#include <string>
#include <sstream>
#include <thread>
#include <chrono>
#include <regex>
#include <cstring>
#include <ctime>
#include <unistd.h>
#include <sys/statvfs.h>
#include <pwd.h>
#include <QDir>
#include <QProcess>

static NetSnapshot last;

static double getCPUTemperature_linux() {
    static time_t lastAttempt = 0;
    static double cachedTemp = -1.0;

    time_t now = time(nullptr);
    if (lastAttempt > 0 && now - lastAttempt < 3) {
        return cachedTemp;
    }
    lastAttempt = now;

    double temp = -1.0;

    std::ifstream file("/sys/class/thermal/thermal_zone0/temp");
    if (file.is_open()) {
        double millidegrees;
        if (file >> millidegrees) {
            temp = millidegrees / 1000.0;
        }
        file.close();
    }

    if (temp < 0) {
        file.open("/sys/class/hwmon/hwmon0/temp1_input");
        if (file.is_open()) {
            double millidegrees;
            if (file >> millidegrees) {
                temp = millidegrees / 1000.0;
            }
            file.close();
        }
    }

    if (temp > 0 && temp < 150) {
        cachedTemp = temp;
    }
    return temp;
}

static double getGPUTemperature_linux() {
    static time_t lastAttempt = 0;
    static double cachedTemp = -1.0;

    time_t now = time(nullptr);
    if (lastAttempt > 0 && now - lastAttempt < 3) {
        return cachedTemp;
    }
    lastAttempt = now;

    double temp = -1.0;

    std::ifstream file("/sys/class/drm/card0/device/hwmon/hwmon0/temp1_input");
    if (file.is_open()) {
        double millidegrees;
        if (file >> millidegrees) {
            temp = millidegrees / 1000.0;
        }
        file.close();
    }

    if (temp < 0) {
        QProcess proc;
        proc.start("nvidia-smi", {"--query-gpu=temperature.gpu", "--format=csv,noheader,nounits"});
        if (proc.waitForFinished(2000) && proc.exitCode() == 0) {
            QString output = QString::fromUtf8(proc.readAllStandardOutput()).trimmed();
            temp = output.toDouble();
        }
    }

    if (temp > 0 && temp < 150) {
        cachedTemp = temp;
    }
    return temp;
}

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

    std::ifstream cpuinfo("/proc/cpuinfo");
    std::string cline;
    int processorCount = 0;
    while (std::getline(cpuinfo, cline)) {
        if (cline.find("model name") != std::string::npos) {
            size_t pos = cline.find(':');
            if (pos != std::string::npos) {
                stats.name = QString::fromStdString(cline.substr(pos + 2)).trimmed();
            }
        } else if (cline.find("processor") != std::string::npos && cline.find("processor\t") == 0) {
            processorCount++;
        } else if (cline.find("cpu MHz") != std::string::npos) {
            size_t pos = cline.find(':');
            if (pos != std::string::npos) {
                double mhz = QString::fromStdString(cline.substr(pos + 2)).trimmed().toDouble();
                if (mhz > stats.maxClockMHz)
                    stats.maxClockMHz = mhz;
            }
        }
    }
    stats.logicalCores = processorCount;
    stats.physicalCores = processorCount;

    if (stats.name.isEmpty())
        stats.name = "Unknown CPU";

    stats.temperature = getCPUTemperature_linux();

    return stats;
}

std::string getDefaultIface() {
    std::ifstream file("/proc/net/dev");
    std::string line;
    std::regex ifaceRegex(R"(([\w\d]+):)");
    while (std::getline(file, line)) {
        std::smatch m;
        if (std::regex_search(line, m, ifaceRegex)) {
            std::string iface = m[1];
            if (iface != "lo")
                return iface;
        }
    }
    return "eth0";
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
                >> std::ws
                >> snap.dropRecv
                >> std::ws >> std::ws >> std::ws >> std::ws
                >> snap.bytesSend
                >> snap.packetsSend
                >> std::ws
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

static QString readSysfsFile(const QString& path) {
    std::ifstream file(path.toStdString());
    if (!file.is_open()) return {};
    std::string content;
    std::getline(file, content);
    return QString::fromStdString(content).trimmed();
}

GPUStats getGPUStats_linux() {
    GPUStats stats{};
    stats.usagePercent = -1.0;
    stats.temperature = -1.0;

    QString gpuPath;
    QDir drmDir("/sys/class/drm");
    QStringList filters;
    filters << "card*";
    QStringList cards = drmDir.entryList(filters, QDir::Dirs);

    for (const QString& card : cards) {
        if (card.contains("-")) continue;
        QString fullPath = "/sys/class/drm/" + card + "/device";
        QString vendorId = readSysfsFile(fullPath + "/vendor");
        if (vendorId == "0x10de") {
            gpuPath = fullPath;
            break;
        } else if (!vendorId.isEmpty()) {
            gpuPath = fullPath;
        }
    }

    if (gpuPath.isEmpty() && !cards.isEmpty()) {
        gpuPath = "/sys/class/drm/" + cards.first() + "/device";
    }

    if (!gpuPath.isEmpty()) {
        QString name = readSysfsFile(gpuPath + "/uevent");
        if (!name.isEmpty()) {
            QStringList lines = name.split('\n');
            for (const QString& line : lines) {
                if (line.startsWith("MODULE=")) {
                    QString mod = line.mid(7);
                    if (mod == "nvidia") stats.name = "NVIDIA GPU";
                    else if (mod == "amdgpu") stats.name = "AMD GPU";
                    else if (mod == "i915") stats.name = "Intel GPU";
                    else stats.name = mod + " GPU";
                    break;
                }
            }
            if (stats.name.isEmpty()) {
                QString readme = readSysfsFile(gpuPath + "/README");
                if (!readme.isEmpty()) stats.name = readme;
                else stats.name = "Unknown GPU";
            }
        }

        QString busid = readSysfsFile(gpuPath + "/busid");
        if (stats.name.isEmpty())
            stats.name = "GPU " + busid;

        QString gpuBusy = readSysfsFile(gpuPath + "/gpu_busy_percentage");
        if (!gpuBusy.isEmpty())
            stats.usagePercent = gpuBusy.toDouble();

        QString memTotal = readSysfsFile(gpuPath + "/mem_info_vram_total");
        if (!memTotal.isEmpty())
            stats.vramTotal = memTotal.toULongLong();

        QString memUsed = readSysfsFile(gpuPath + "/mem_info_vram_used");
        if (!memUsed.isEmpty())
            stats.vramUsed = memUsed.toULongLong();
    }

    if (stats.usagePercent < 0 || stats.vramTotal == 0) {
        static QDateTime lastNvidiaAttempt;
        static bool nvidiaAvailable = false;
        bool canTryNvidia = nvidiaAvailable || lastNvidiaAttempt.isNull() ||
                            lastNvidiaAttempt.msecsTo(QDateTime::currentDateTime()) > 30000;

        if (canTryNvidia) {
            lastNvidiaAttempt = QDateTime::currentDateTime();
            QProcess proc;
            proc.start("nvidia-smi", {"--query-gpu=utilization.gpu,memory.total,memory.used",
                                      "--format=csv,noheader,nounits"});
            if (proc.waitForFinished(1500) && proc.exitCode() == 0) {
                nvidiaAvailable = true;
                QString output = QString::fromUtf8(proc.readAllStandardOutput()).trimmed();
                if (!output.isEmpty()) {
                    QStringList fields = output.split(", ");
                    if (fields.size() >= 3) {
                        stats.usagePercent = fields[0].toDouble();
                        stats.vramTotal = static_cast<uint64_t>(fields[1].toDouble() * 1024 * 1024);
                        stats.vramUsed = static_cast<uint64_t>(fields[2].toDouble() * 1024 * 1024);
                    }
                    if (stats.name.isEmpty())
                        stats.name = "NVIDIA GPU";
                }
            } else {
                nvidiaAvailable = false;
            }
        }
    }

    if (stats.name.isEmpty())
        stats.name = "Unknown GPU";

    stats.temperature = getGPUTemperature_linux();

    return stats;
}

DiskStats getDiskStats_linux() {
    DiskStats stats{};
    struct statvfs vfs;
    if (statvfs("/", &vfs) == 0) {
        stats.totalSpace = vfs.f_frsize * vfs.f_blocks;
        stats.freeSpace = vfs.f_frsize * vfs.f_bavail;
        if (stats.totalSpace > 0)
            stats.usagePercent = (double)(stats.totalSpace - stats.freeSpace) / stats.totalSpace * 100.0;
    }
    return stats;
}

SystemInfo getSystemInfo_linux() {
    SystemInfo info{};

    std::ifstream uptimeFile("/proc/uptime");
    if (uptimeFile.is_open()) {
        double uptime = 0;
        uptimeFile >> uptime;
        info.uptimeSeconds = static_cast<quint64>(uptime);
    }

    char hostname[256];
    if (gethostname(hostname, sizeof(hostname)) == 0)
        info.hostname = QString::fromLocal8Bit(hostname);

    info.osName = QSysInfo::prettyProductName();

    QScreen* screen = QGuiApplication::primaryScreen();
    if (screen) {
        info.screenWidth = screen->geometry().width();
        info.screenHeight = screen->geometry().height();
    }

    return info;
}

#endif

static SystemStats doQueryAllStats() {
    SystemStats s;
#ifdef Q_OS_WIN
    s.cpu = getCPUStats_win();
    s.net = getNetworkStats_win();
    s.mem = getMemoryStats_win();
    s.bat = getBatteryStats_win();
    s.gpu = getGPUStats_win();
    s.disk = getDiskStats_win();
    s.sysInfo = getSystemInfo_win();
#elif defined(Q_OS_LINUX)
    s.cpu = getCPUStats_linux();
    s.net = getNetworkStats_linux(getDefaultIface());
    s.mem = getMemoryStats_linux();
    s.bat = getBatteryStats_linux();
    s.gpu = getGPUStats_linux();
    s.disk = getDiskStats_linux();
    s.sysInfo = getSystemInfo_linux();
#endif
    return s;
}

void UniDeskSystemInfo::updateStatsInBackground() {
    QThreadPool::globalInstance()->start([this]() {
        SystemStats s = doQueryAllStats();
        QMutexLocker locker(&statsMutex);
        cachedStats = s;
    });
}

SystemStats UniDeskSystemInfo::getSystemStats() {
    QMutexLocker locker(&statsMutex);
    return cachedStats;
}