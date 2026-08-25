#include "UniDeskSystemInfo.h"
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
#include <thread>
#include <chrono>

#ifdef Q_OS_WIN
// Target at least Windows 8 APIs - adjust if you need other target
#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0602
#endif

#include <windows.h>
#include <iphlpapi.h>
#include <dxgi.h>
#include <pdh.h>
#include <tchar.h>
#include <comdef.h>
#include <Wbemidl.h>
#include <QProcess>
#include <vector>
#include <set>

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

    HRESULT hr = CoInitializeEx(NULL, COINIT_APARTMENTTHREADED);
    bool comInitialized = SUCCEEDED(hr) || hr == RPC_E_CHANGED_MODE;
    if (comInitialized) {
        IWbemLocator* pLoc = nullptr;
        hr = CoCreateInstance(CLSID_WbemLocator, 0, CLSCTX_INPROC_SERVER,
                             IID_IWbemLocator, (LPVOID*)&pLoc);
        if (SUCCEEDED(hr) && pLoc) {
            IWbemServices* pSvc = nullptr;
            hr = pLoc->ConnectServer(_bstr_t(L"root\\WMI"), NULL, NULL, NULL,
                                      0, NULL, NULL, &pSvc);
            pLoc->Release();
            if (SUCCEEDED(hr) && pSvc) {
                CoSetProxyBlanket(pSvc, RPC_C_AUTHN_WINNT, RPC_C_AUTHZ_NONE, NULL,
                                  RPC_C_AUTHN_LEVEL_CALL, RPC_C_IMP_LEVEL_IMPERSONATE,
                                  NULL, EOAC_NONE);
                IEnumWbemClassObject* pEnum = nullptr;
                hr = pSvc->ExecQuery(_bstr_t(L"WQL"),
                    _bstr_t(L"SELECT CurrentTemperature FROM MSAcpi_ThermalZoneTemperature"),
                    WBEM_FLAG_FORWARD_ONLY | WBEM_FLAG_RETURN_IMMEDIATELY, NULL, &pEnum);
                if (SUCCEEDED(hr) && pEnum) {
                    IWbemClassObject* pObj = nullptr;
                    ULONG uReturn = 0;
                    while (pEnum->Next(WBEM_INFINITE, 1, &pObj, &uReturn) == S_OK && uReturn > 0) {
                        VARIANT vtProp;
                        if (pObj->Get(L"CurrentTemperature", 0, &vtProp, 0, 0) == S_OK) {
                            if (vtProp.vt == VT_I4) {
                                temp = (double)(vtProp.lVal - 2732) / 10.0;
                            }
                            VariantClear(&vtProp);
                        }
                        pObj->Release();
                        if (temp > 0) break;
                    }
                    pEnum->Release();
                }
                pSvc->Release();
            }
        }
        CoUninitialize();
    }

    if (temp > 0 && temp < 150) cachedTemp = temp;
    return temp;
}

static double getGPUTemperature_win(const QString& /*gpuName*/) {
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
        QString out = QString::fromUtf8(proc.readAllStandardOutput()).trimmed();
        if (!out.isEmpty()) {
            temp = out.toDouble();
        }
    }

    if (temp > 0 && temp < 150) cachedTemp = temp;
    return temp;
}

static inline unsigned long long filetime_to_ull(const FILETIME &ft) {
    ULARGE_INTEGER u;
    u.LowPart = ft.dwLowDateTime;
    u.HighPart = ft.dwHighDateTime;
    return u.QuadPart;
}

CPUStats getCPUStats_win() {
    static FILETIME prevIdle = {0,0}, prevKernel = {0,0}, prevUser = {0,0};
    CPUStats stats{};
    FILETIME idleTime, kernelTime, userTime;
    if (!GetSystemTimes(&idleTime, &kernelTime, &userTime)) {
        return stats;
    }

    if (prevIdle.dwLowDateTime == 0 && prevIdle.dwHighDateTime == 0) {
        prevIdle = idleTime;
        prevKernel = kernelTime;
        prevUser = userTime;
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
        if (!GetSystemTimes(&idleTime, &kernelTime, &userTime))
            return stats;
    }

    unsigned long long idle = filetime_to_ull(idleTime);
    unsigned long long kernel = filetime_to_ull(kernelTime);
    unsigned long long user = filetime_to_ull(userTime);

    unsigned long long prevIdleULL = filetime_to_ull(prevIdle);
    unsigned long long prevKernelULL = filetime_to_ull(prevKernel);
    unsigned long long prevUserULL = filetime_to_ull(prevUser);

    unsigned long long sys = (kernel - prevKernelULL) + (user - prevUserULL);
    unsigned long long idleDiff = idle - prevIdleULL;

    prevIdle = idleTime;
    prevKernel = kernelTime;
    prevUser = userTime;

    if (sys)
        stats.usagePercent = sys > idleDiff ? (double)(sys - idleDiff) * 100.0 / (double)sys : 0.0;
    else
        stats.usagePercent = 0.0;

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
            wchar_t buf[512];
            DWORD bufSize = sizeof(buf);
            DWORD type = REG_SZ;
            if (RegQueryValueExW(hKey, L"ProcessorNameString", NULL, &type, (LPBYTE)buf, &bufSize) == ERROR_SUCCESS) {
                cachedCpuName = QString::fromWCharArray(buf);
            }
            RegCloseKey(hKey);
        }

        if (cachedCpuName.isEmpty()) {
            HRESULT hr = CoInitializeEx(NULL, COINIT_APARTMENTTHREADED);
            if (SUCCEEDED(hr) || hr == RPC_E_CHANGED_MODE) {
                IWbemLocator* pLoc = nullptr;
                if (SUCCEEDED(CoCreateInstance(CLSID_WbemLocator, 0, CLSCTX_INPROC_SERVER, IID_IWbemLocator, (LPVOID*)&pLoc))) {
                    IWbemServices* pSvc = nullptr;
                    if (SUCCEEDED(pLoc->ConnectServer(_bstr_t(L"root\\cimv2"), NULL, NULL, NULL, 0, NULL, NULL, &pSvc))) {
                        CoSetProxyBlanket(pSvc, RPC_C_AUTHN_WINNT, RPC_C_AUTHZ_NONE, NULL,
                                          RPC_C_AUTHN_LEVEL_CALL, RPC_C_IMP_LEVEL_IMPERSONATE,
                                          NULL, EOAC_NONE);
                        IEnumWbemClassObject* pEnum = nullptr;
                        if (SUCCEEDED(pSvc->ExecQuery(_bstr_t(L"WQL"),
                                _bstr_t(L"SELECT Name, MaxClockSpeed FROM Win32_Processor"),
                                WBEM_FLAG_FORWARD_ONLY | WBEM_FLAG_RETURN_IMMEDIATELY, NULL, &pEnum))) {
                            IWbemClassObject* pObj = nullptr;
                            ULONG uReturn = 0;
                            if (pEnum->Next(WBEM_INFINITE, 1, &pObj, &uReturn) == S_OK && uReturn > 0) {
                                VARIANT vt;
                                if (pObj->Get(L"Name", 0, &vt, 0, 0) == S_OK && vt.vt == VT_BSTR) {
                                    cachedCpuName = QString::fromWCharArray(vt.bstrVal);
                                    VariantClear(&vt);
                                }
                                if (pObj->Get(L"MaxClockSpeed", 0, &vt, 0, 0) == S_OK) {
                                    if (vt.vt == VT_I4) cachedCpuMaxClock = vt.lVal;
                                    VariantClear(&vt);
                                }
                                pObj->Release();
                            }
                            pEnum->Release();
                        }
                        pSvc->Release();
                    }
                    pLoc->Release();
                }
                CoUninitialize();
            }
        }
    }

    stats.name = cachedCpuName.isEmpty() ? QStringLiteral("Unknown CPU") : cachedCpuName;
    stats.maxClockMHz = cachedCpuMaxClock > 0 ? cachedCpuMaxClock : -1.0;

    SYSTEM_INFO si;
    GetSystemInfo(&si);
    stats.logicalCores = static_cast<int>(si.dwNumberOfProcessors);

    DWORD len = 0;
    BOOL res = GetLogicalProcessorInformation(nullptr, &len);
    if (!res && GetLastError() == ERROR_INSUFFICIENT_BUFFER && len > 0) {
        std::vector<uint8_t> buffer(len);
        PSYSTEM_LOGICAL_PROCESSOR_INFORMATION info = reinterpret_cast<PSYSTEM_LOGICAL_PROCESSOR_INFORMATION>(buffer.data());
        if (GetLogicalProcessorInformation(info, &len)) {
            DWORD count = len / sizeof(SYSTEM_LOGICAL_PROCESSOR_INFORMATION);
            int phys = 0;
            for (DWORD i = 0; i < count; ++i) {
                if (info[i].Relationship == RelationProcessorCore) ++phys;
            }
            if (phys > 0) stats.physicalCores = phys;
            else stats.physicalCores = stats.logicalCores;
        } else {
            stats.physicalCores = stats.logicalCores;
        }
    } else {
        stats.physicalCores = stats.logicalCores;
    }

    stats.temperature = getCPUTemperature_win();

    return stats;
}

NetworkStats getNetworkStats_win() {
    NetworkStats ns{};
    static uint64_t lastRecv = 0, lastSend = 0;
    static uint64_t lastPacketsRecv = 0, lastPacketsSend = 0;
    static uint64_t lastDropRecv = 0, lastDropSend = 0;

    // Use legacy GetIfTable which is widely available across SDKs
    DWORD dwSize = 0;
    if (GetIfTable(nullptr, &dwSize, FALSE) == ERROR_INSUFFICIENT_BUFFER) {
        PMIB_IFTABLE pIfTable = (PMIB_IFTABLE)malloc(dwSize);
        if (pIfTable && GetIfTable(pIfTable, &dwSize, FALSE) == NO_ERROR) {
            uint64_t bytesIn = 0, bytesOut = 0, pktsIn = 0, pktsOut = 0, dropsIn = 0, dropsOut = 0;
            for (DWORD i = 0; i < pIfTable->dwNumEntries; ++i) {
                MIB_IFROW &row = pIfTable->table[i];
                // skip loopback
                if (row.dwType == MIB_IF_TYPE_LOOPBACK) continue;
                bytesIn += row.dwInOctets;
                bytesOut += row.dwOutOctets;
                pktsIn += (uint64_t)row.dwInUcastPkts + (uint64_t)row.dwInNUcastPkts;
                pktsOut += (uint64_t)row.dwOutUcastPkts + (uint64_t)row.dwOutNUcastPkts;
                dropsIn += row.dwInDiscards;
                dropsOut += row.dwOutDiscards;
            }
            ns.bytesRecv = bytesIn;
            ns.bytesSend = bytesOut;
            ns.bytesRecvPerSec = bytesIn - lastRecv;
            ns.bytesSendPerSec = bytesOut - lastSend;
            uint64_t deltaPackets = (pktsIn - lastPacketsRecv) + (pktsOut - lastPacketsSend);
            uint64_t deltaDrops   = (dropsIn - lastDropRecv) + (dropsOut - lastDropSend);
            ns.dropPercent = deltaPackets ? (double)deltaDrops / (double)deltaPackets * 100.0 : 0.0;

            lastRecv = bytesIn;
            lastSend = bytesOut;
            lastPacketsRecv = pktsIn;
            lastPacketsSend = pktsOut;
            lastDropRecv = dropsIn;
            lastDropSend = dropsOut;
        }
        if (pIfTable) free(pIfTable);
    }
    return ns;
}

MemoryStats getMemoryStats_win() {
    MEMORYSTATUSEX memstat;
    memstat.dwLength = sizeof(memstat);
    MemoryStats stats = {};
    if (GlobalMemoryStatusEx(&memstat)) {
        stats.virtmemTotal = memstat.ullTotalPhys;
        stats.virtmemUsed = memstat.ullTotalPhys - memstat.ullAvailPhys;
        stats.virtmemPercent = (double)memstat.dwMemoryLoad;
        stats.swapmemTotal = memstat.ullTotalPageFile;
        stats.swapmemUsed = memstat.ullTotalPageFile - memstat.ullAvailPageFile;
        stats.swapmemPercent = stats.swapmemTotal ? (double)stats.swapmemUsed / stats.swapmemTotal * 100.0 : 0.0;
    }
    return stats;
}

BatteryStats getBatteryStats_win() {
    BatteryStats stats{};
    SYSTEM_POWER_STATUS sps;
    if (GetSystemPowerStatus(&sps)) {
        if (sps.BatteryFlag == 128) {
            stats.batteryPercent = -1;
            stats.charging = false;
            stats.remainMinutes = -1;
        } else {
            if (sps.BatteryLifePercent == 255) stats.batteryPercent = -1;
            else stats.batteryPercent = (int)sps.BatteryLifePercent;
            stats.charging = (sps.ACLineStatus == 1);
            if (sps.BatteryLifeTime != (DWORD)-1 && sps.BatteryLifeTime != 255) {
                stats.remainMinutes = static_cast<int>(sps.BatteryLifeTime / 60);
            } else {
                stats.remainMinutes = -1;
            }
        }
    } else {
        stats.batteryPercent = -1;
        stats.charging = false;
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
        if (SUCCEEDED(CreateDXGIFactory1(__uuidof(IDXGIFactory1), (void**)&pFactory))) {
            IDXGIAdapter1* pAdapter = nullptr;
            for (UINT i = 0; pFactory->EnumAdapters1(i, &pAdapter) != DXGI_ERROR_NOT_FOUND; ++i) {
                DXGI_ADAPTER_DESC1 desc;
                pAdapter->GetDesc1(&desc);
                if (!(desc.Flags & DXGI_ADAPTER_FLAG_SOFTWARE)) {
                    cachedGpuName = QString::fromWCharArray(desc.Description);
                    cachedVramTotal = desc.DedicatedVideoMemory;
                    pAdapter->Release();
                    break;
                }
                pAdapter->Release();
            }
            pFactory->Release();
        }
    }

    stats.name = cachedGpuName.isEmpty() ? QStringLiteral("Unknown GPU") : cachedGpuName;
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
                    bool ok1=false, ok2=false, ok3=false;
                    qulonglong usedMB = parts[0].trimmed().toULongLong(&ok1);
                    qulonglong totalMB = parts[1].trimmed().toULongLong(&ok2);
                    double util = parts[2].trimmed().toDouble(&ok3);
                    if (ok1 && ok2 && ok3) {
                        stats.vramUsed = usedMB * 1024ULL * 1024ULL;
                        if (stats.vramTotal == 0) stats.vramTotal = totalMB * 1024ULL * 1024ULL;
                        stats.usagePercent = qBound(0.0, util, 100.0);
                        nvidiaAvailable = true;
                    }
                }
            }
        } else {
            nvidiaAvailable = false;
        }
    }

    if (stats.usagePercent < 0) {
        static PDH_HQUERY hQuery = nullptr;
        static PDH_HCOUNTER hCounter = nullptr;
        static bool pdhInitAttempted = false;
        if (!pdhInitAttempted) {
            pdhInitAttempted = true;
            if (PdhOpenQuery(NULL, 0, &hQuery) == ERROR_SUCCESS) {
                const wchar_t* counterPath = L"\\GPU Engine(*)\\Utilization Percentage";
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
    WCHAR winDir[MAX_PATH];
    if (GetWindowsDirectoryW(winDir, MAX_PATH)) {
        WCHAR rootPath[4] = L"C:\\";
        if (winDir[0] && winDir[1] == L':') {
            rootPath[0] = winDir[0];
            rootPath[1] = L':';
            rootPath[2] = L'\\';
            rootPath[3] = L'\0';
        }
        ULARGE_INTEGER freeBytesAvailable, totalNumberOfBytes, totalNumberOfFreeBytes;
        if (GetDiskFreeSpaceExW(rootPath, &freeBytesAvailable, &totalNumberOfBytes, &totalNumberOfFreeBytes)) {
            stats.totalSpace = static_cast<uint64_t>(totalNumberOfBytes.QuadPart);
            stats.freeSpace = static_cast<uint64_t>(totalNumberOfFreeBytes.QuadPart);
            if (stats.totalSpace > 0)
                stats.usagePercent = (double)(stats.totalSpace - stats.freeSpace) * 100.0 / (double)stats.totalSpace;
        }
    }
    return stats;
}

SystemInfo getSystemInfo_win() {
    SystemInfo info{};
    info.uptimeSeconds = static_cast<quint64>(GetTickCount64() / 1000ULL);
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
#include <set>

static NetSnapshot last;

static double getCPUTemperature_linux() {
    static time_t lastAttempt = 0;
    static double cachedTemp = -1.0;
    time_t now = time(nullptr);
    if (lastAttempt > 0 && now - lastAttempt < 3) return cachedTemp;
    lastAttempt = now;

    double temp = -1.0;
    const char* candidates[] = {
        "/sys/class/thermal/thermal_zone0/temp",
        "/sys/class/hwmon/hwmon0/temp1_input",
        "/sys/devices/platform/coretemp.0/hwmon/hwmon0/temp1_input",
        nullptr
    };
    for (const char** p = candidates; *p; ++p) {
        std::ifstream f(*p);
        if (f.is_open()) {
            double v;
            if (f >> v) {
                if (v > 1000) temp = v / 1000.0;
                else temp = v;
                f.close();
                break;
            }
            f.close();
        }
    }

    if (temp < 0) {
        QProcess proc;
        proc.start("nvidia-smi", {"--query-gpu=temperature.gpu", "--format=csv,noheader,nounits"});
        if (proc.waitForFinished(1500) && proc.exitCode() == 0) {
            QString out = QString::fromUtf8(proc.readAllStandardOutput()).trimmed();
            if (!out.isEmpty()) temp = out.toDouble();
        }
    }

    if (temp > 0 && temp < 150) cachedTemp = temp;
    return temp;
}

static double getGPUTemperature_linux() {
    double t = -1.0;
    QProcess proc;
    proc.start("nvidia-smi", {"--query-gpu=temperature.gpu", "--format=csv,noheader,nounits"});
    if (proc.waitForFinished(1500) && proc.exitCode() == 0) {
        QString out = QString::fromUtf8(proc.readAllStandardOutput()).trimmed();
        if (!out.isEmpty()) t = out.toDouble();
    }
    if (t > 0 && t < 150) return t;

    const char* paths[] = {
        "/sys/class/drm/card0/device/hwmon/hwmon0/temp1_input",
        "/sys/class/hwmon/hwmon0/temp1_input",
        nullptr
    };
    for (const char** p = paths; *p; ++p) {
        std::ifstream f(*p);
        if (f.is_open()) {
            double v;
            if (f >> v) {
                if (v > 1000) t = v / 1000.0;
                else t = v;
                f.close();
                break;
            }
            f.close();
        }
    }
    return (t > 0 && t < 150) ? t : -1.0;
}

CPUStats getCPUStats_linux() {
    static uint64_t lastIdle = 0, lastTotal = 0;
    CPUStats stats{};

    std::ifstream statf("/proc/stat");
    if (!statf.is_open()) return stats;
    std::string line;
    if (!std::getline(statf, line)) return stats;
    std::istringstream ss(line);
    std::string cpuLabel;
    uint64_t user=0, nice=0, system=0, idle=0, iowait=0, irq=0, softirq=0, steal=0, guest=0, guest_nice=0;
    ss >> cpuLabel >> user >> nice >> system >> idle >> iowait >> irq >> softirq >> steal >> guest >> guest_nice;

    uint64_t idleTime = idle + iowait;
    uint64_t totalTime = user + nice + system + idle + iowait + irq + softirq + steal;

    if (lastTotal == 0) {
        lastIdle = idleTime;
        lastTotal = totalTime;
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
        return getCPUStats_linux();
    }

    uint64_t totald = totalTime - lastTotal;
    uint64_t idled = idleTime - lastIdle;
    if (totald) stats.usagePercent = (double)(totald - idled) * 100.0 / (double)totald;
    else stats.usagePercent = 0.0;

    lastIdle = idleTime;
    lastTotal = totalTime;

    std::ifstream cpuinfo("/proc/cpuinfo");
    std::string cline;
    int logical = 0;
    std::string cpuName;
    std::set<std::pair<int,int>> corePairs;
    while (std::getline(cpuinfo, cline)) {
        if (cline.find("processor") == 0) ++logical;
        else if (cline.find("model name") == 0 && cpuName.empty()) {
            auto pos = cline.find(':');
            if (pos != std::string::npos) cpuName = cline.substr(pos+1);
        } else if (cline.find("physical id") != std::string::npos) {
            int phys = -1, core = -1;
            try {
                auto pos = cline.find(':');
                if (pos != std::string::npos) phys = std::stoi(cline.substr(pos+1));
            } catch(...) {}
            std::streampos cur = cpuinfo.tellg();
            for (int i=0;i<6 && std::getline(cpuinfo, cline);++i) {
                if (cline.find("core id") != std::string::npos) {
                    try {
                        auto pos = cline.find(':');
                        if (pos != std::string::npos) core = std::stoi(cline.substr(pos+1));
                    } catch(...) {}
                    break;
                }
            }
            cpuinfo.clear();
            cpuinfo.seekg(cur);
            if (phys >= 0 && core >= 0) corePairs.insert({phys, core});
        }
    }
    stats.logicalCores = logical > 0 ? logical : sysconf(_SC_NPROCESSORS_ONLN);

    if (!corePairs.empty()) {
        stats.physicalCores = static_cast<int>(corePairs.size());
    } else {
        std::ifstream cpuinfo2("/proc/cpuinfo");
        std::string s;
        int reportedCoresPerPhysical = -1;
        while (std::getline(cpuinfo2, s)) {
            if (s.find("cpu cores") == 0) {
                auto pos = s.find(':');
                if (pos != std::string::npos) {
                    try { reportedCoresPerPhysical = std::stoi(s.substr(pos+1)); } catch(...) {}
                    break;
                }
            }
        }
        if (reportedCoresPerPhysical > 0 && stats.logicalCores > 0)
            stats.physicalCores = std::max(1, stats.logicalCores / reportedCoresPerPhysical);
        else
            stats.physicalCores = stats.logicalCores;
    }

    if (!cpuName.empty()) {
        while (!cpuName.empty() && isspace(cpuName.front())) cpuName.erase(cpuName.begin());
        while (!cpuName.empty() && isspace(cpuName.back())) cpuName.pop_back();
        stats.name = QString::fromStdString(cpuName);
    } else {
        stats.name = QStringLiteral("Unknown CPU");
    }

    std::ifstream cpuinfo3("/proc/cpuinfo");
    double maxmhz = -1.0;
    while (std::getline(cpuinfo3, cline)) {
        if (cline.find("cpu MHz") == 0) {
            auto pos = cline.find(':');
            if (pos != std::string::npos) {
                try {
                    double mhz = std::stod(cline.substr(pos+1));
                    if (mhz > maxmhz) maxmhz = mhz;
                } catch(...) {}
            }
        }
    }
    stats.maxClockMHz = maxmhz;

    stats.temperature = getCPUTemperature_linux();
    return stats;
}

static std::string getDefaultIface_linux() {
    std::ifstream route("/proc/net/route");
    std::string line;
    while (std::getline(route, line)) {
        std::istringstream iss(line);
        std::string iface, dest;
        if (!(iss >> iface >> dest)) continue;
        if (dest == "00000000") return iface;
    }
    std::ifstream devf("/proc/net/dev");
    while (std::getline(devf, line)) {
        auto pos = line.find(':');
        if (pos == std::string::npos) continue;
        std::string iface = line.substr(0, pos);
        while (!iface.empty() && isspace(iface.front())) iface.erase(iface.begin());
        while (!iface.empty() && isspace(iface.back())) iface.pop_back();
        if (iface != "lo") return iface;
    }
    return std::string("eth0");
}

NetSnapshot getNetSnapshot_linux(const std::string& iface) {
    NetSnapshot snap{};
    std::ifstream f("/proc/net/dev");
    std::string line;
    while (std::getline(f, line)) {
        auto pos = line.find(':');
        if (pos == std::string::npos) continue;
        std::string name = line.substr(0, pos);
        while (!name.empty() && isspace(name.front())) name.erase(name.begin());
        while (!name.empty() && isspace(name.back())) name.pop_back();
        if (name != iface) continue;
        std::string rest = line.substr(pos+1);
        std::istringstream iss(rest);
        uint64_t fields[16] = {0};
        for (int i = 0; i < 16; ++i) iss >> fields[i];
        snap.bytesRecv = fields[0];
        snap.packetsRecv = fields[1];
        snap.dropRecv = fields[3];
        snap.bytesSend = fields[8];
        snap.packetsSend = fields[9];
        snap.dropSend = fields[11];
        break;
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
    ns.dropPercent = totalPackets ? (double)totalDrops / (double)totalPackets * 100.0 : 0.0;
    last = now;
    return ns;
}

MemoryStats getMemoryStats_linux() {
    MemoryStats stats{};
    std::ifstream f("/proc/meminfo");
    std::string key;
    uint64_t value;
    std::string unit;
    uint64_t total=0, available=0, swapTotal=0, swapFree=0;
    while (f >> key >> value >> unit) {
        if (key == "MemTotal:") total = value;
        else if (key == "MemAvailable:") available = value;
        else if (key == "SwapTotal:") swapTotal = value;
        else if (key == "SwapFree:") swapFree = value;
    }
    stats.virtmemTotal = total * 1024ULL;
    stats.virtmemUsed = (total > available) ? (total - available) * 1024ULL : 0;
    stats.virtmemPercent = total ? (double)(total - available) * 100.0 / (double)total : 0.0;
    stats.swapmemTotal = swapTotal * 1024ULL;
    stats.swapmemUsed = (swapTotal > swapFree) ? (swapTotal - swapFree) * 1024ULL : 0;
    stats.swapmemPercent = swapTotal ? (double)(swapTotal - swapFree) * 100.0 / (double)swapTotal : 0.0;
    return stats;
}

BatteryStats getBatteryStats_linux() {
    BatteryStats stats{};
    QDir d("/sys/class/power_supply");
    if (!d.exists()) {
        stats.batteryPercent = -1;
        stats.charging = false;
        stats.remainMinutes = -1;
        return stats;
    }
    QStringList entries = d.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
    QString batDir;
    for (const QString &e : entries) {
        QString type = readSysfsFile("/sys/class/power_supply/" + e + "/type");
        if (type.toLower() == "battery") {
            batDir = "/sys/class/power_supply/" + e;
            break;
        }
    }
    if (batDir.isEmpty()) {
        stats.batteryPercent = -1;
        stats.charging = false;
        stats.remainMinutes = -1;
        return stats;
    }
    QString cap = readSysfsFile(batDir + "/capacity");
    if (!cap.isEmpty()) stats.batteryPercent = cap.toInt();
    QString status = readSysfsFile(batDir + "/status");
    stats.charging = (status.toLower() == "charging");
    QString energy_now = readSysfsFile(batDir + "/energy_now");
    QString power_now = readSysfsFile(batDir + "/power_now");
    if (energy_now.isEmpty()) energy_now = readSysfsFile(batDir + "/charge_now");
    if (power_now.isEmpty()) power_now = readSysfsFile(batDir + "/current_now");
    bool ok1=false, ok2=false;
    int e_now = energy_now.toInt(&ok1);
    int p_now = power_now.toInt(&ok2);
    if (ok1 && ok2 && p_now > 0 && status.toLower() == "discharging") {
        double hours = (double)e_now / (double)p_now;
        stats.remainMinutes = static_cast<int>(hours * 60.0);
    } else {
        stats.remainMinutes = -1;
    }
    return stats;
}

static QString readSysfsFile(const QString& path) {
    std::ifstream f(path.toStdString());
    if (!f.is_open()) return {};
    std::string line;
    std::getline(f, line);
    return QString::fromStdString(line).trimmed();
}

GPUStats getGPUStats_linux() {
    GPUStats stats{};
    stats.usagePercent = -1.0;
    stats.temperature = -1.0;

    QDir drm("/sys/class/drm");
    QStringList cards = drm.entryList(QStringList() << "card*", QDir::Dirs);
    QString gpuPath;
    for (const QString &card : cards) {
        if (card.contains("-")) continue;
        QString candidate = "/sys/class/drm/" + card + "/device";
        QString vendor = readSysfsFile(candidate + "/vendor");
        if (vendor == "0x10de") { gpuPath = candidate; break; }
        if (gpuPath.isEmpty() && !vendor.isEmpty()) gpuPath = candidate;
    }
    if (gpuPath.isEmpty() && !cards.isEmpty())
        gpuPath = "/sys/class/drm/" + cards.first() + "/device";

    if (!gpuPath.isEmpty()) {
        QString uevent = readSysfsFile(gpuPath + "/uevent");
        if (!uevent.isEmpty()) {
            if (uevent.contains("nvidia", Qt::CaseInsensitive)) stats.name = "NVIDIA GPU";
            else if (uevent.contains("amdgpu", Qt::CaseInsensitive)) stats.name = "AMD GPU";
            else if (uevent.contains("i915", Qt::CaseInsensitive)) stats.name = "Intel GPU";
            else stats.name = "GPU";
        }
        QString gpuBusy = readSysfsFile(gpuPath + "/gpu_busy_percentage");
        if (!gpuBusy.isEmpty()) stats.usagePercent = gpuBusy.toDouble();
        QString memTotal = readSysfsFile(gpuPath + "/mem_info_vram_total");
        if (!memTotal.isEmpty()) stats.vramTotal = memTotal.toULongLong();
        QString memUsed = readSysfsFile(gpuPath + "/mem_info_vram_used");
        if (!memUsed.isEmpty()) stats.vramUsed = memUsed.toULongLong();
    }

    static QDateTime lastNvidiaAttempt;
    static bool nvidiaAvailable = false;
    bool canTryNvidia = nvidiaAvailable || lastNvidiaAttempt.isNull() ||
                        lastNvidiaAttempt.msecsTo(QDateTime::currentDateTime()) > 30000;
    if (canTryNvidia) {
        lastNvidiaAttempt = QDateTime::currentDateTime();
        QProcess proc;
        proc.start("nvidia-smi", {"--query-gpu=utilization.gpu,memory.total,memory.used", "--format=csv,noheader,nounits"});
        if (proc.waitForFinished(1500) && proc.exitCode() == 0) {
            nvidiaAvailable = true;
            QString out = QString::fromUtf8(proc.readAllStandardOutput()).trimmed();
            if (!out.isEmpty()) {
                QStringList f = out.split(", ");
                if (f.size() >= 3) {
                    stats.usagePercent = f[0].toDouble();
                    stats.vramTotal = static_cast<uint64_t>(f[1].toDouble() * 1024 * 1024);
                    stats.vramUsed = static_cast<uint64_t>(f[2].toDouble() * 1024 * 1024);
                    if (stats.name.isEmpty()) stats.name = "NVIDIA GPU";
                }
            }
        } else {
            nvidiaAvailable = false;
        }
    }

    if (stats.name.isEmpty()) stats.name = "Unknown GPU";
    stats.temperature = getGPUTemperature_linux();
    return stats;
}

DiskStats getDiskStats_linux() {
    DiskStats stats{};
    struct statvfs vfs;
    if (statvfs("/", &vfs) == 0) {
        stats.totalSpace = static_cast<uint64_t>(vfs.f_frsize) * static_cast<uint64_t>(vfs.f_blocks);
        stats.freeSpace = static_cast<uint64_t>(vfs.f_frsize) * static_cast<uint64_t>(vfs.f_bavail);
        if (stats.totalSpace > 0)
            stats.usagePercent = (double)(stats.totalSpace - stats.freeSpace) * 100.0 / (double)stats.totalSpace;
    }
    return stats;
}

SystemInfo getSystemInfo_linux() {
    SystemInfo info{};
    std::ifstream uptimeFile("/proc/uptime");
    if (uptimeFile.is_open()) {
        double up = 0;
        uptimeFile >> up;
        info.uptimeSeconds = static_cast<quint64>(up);
    } else {
        info.uptimeSeconds = 0;
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

#endif // platform branches

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
    s.net = getNetworkStats_linux(getDefaultIface_linux());
    s.mem = getMemoryStats_linux();
    s.bat = getBatteryStats_linux();
    s.gpu = getGPUStats_linux();
    s.disk = getDiskStats_linux();
    s.sysInfo = getSystemInfo_linux();
#endif
    return s;
}

UniDeskSystemInfo::UniDeskSystemInfo() {
    cachedStats = doQueryAllStats();
    QTimer* timer = new QTimer(this);
    connect(timer, &QTimer::timeout, this, &UniDeskSystemInfo::updateStatsInBackground);
    timer->start(1000);
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