#include "UniDeskCustomWallpaper.h"

#ifdef Q_OS_WIN
#include <windows.h>
#include <dwmapi.h>
#pragma comment(lib, "dwmapi.lib")
#endif

#ifdef Q_OS_WIN
namespace {

void sendMessageTimeout(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    SendMessageTimeoutW(hwnd, msg, wParam, lParam, SMTO_ABORTIFHUNG, 1000, nullptr);
}

HWND createWorkerW(HWND parentHwnd) {
    // 注册WorkerW类的窗口样式
    WNDCLASSW wc = {};
    wc.hInstance = (HINSTANCE)GetModuleHandleW(nullptr);
    wc.lpszClassName = L"WorkerW";
    wc.style = CS_VREDRAW | CS_HREDRAW;
    wc.lpfnWndProc = (WNDPROC)DefWindowProcW;
    RegisterClassW(&wc);

    // 获取父窗口的客户区大小
    RECT rect;
    GetClientRect(parentHwnd, &rect);
    int width = rect.right - rect.left;
    int height = rect.bottom - rect.top;

    // 创建WorkerW窗口
    HWND hwnd = CreateWindowExW(
        WS_EX_LAYERED | WS_EX_TOOLWINDOW,
        L"WorkerW",
        L"",
        WS_CHILD | WS_VISIBLE | WS_CLIPSIBLINGS,
        0, 0, width, height,
        parentHwnd,
        nullptr,
        wc.hInstance,
        nullptr
    );

    return hwnd;
}
}
#endif

UniDeskCustomWallpaper::UniDeskCustomWallpaper(QQuickWindow *parent)
    : QQuickWindow { parent }
{
    setFlag(Qt::FramelessWindowHint, true);
    setFlag(Qt::WindowStaysOnBottomHint, true);
    setFlag(Qt::Tool, true);
    // 设置窗口背景为透明
    setColor(Qt::transparent);
    attachedToWallpaper(false);
    wallpaperMode(0);
    wallpaperImageUrl(QString());
    wallpaperImageUrls(QStringList());
    wallpaperVideoUrl(QString());
    wallpaperVolume(0);
    wallpaperApiUrl(QString());
    wallpaperApiExpression(QString());
}

UniDeskCustomWallpaper::~UniDeskCustomWallpaper() {
}


//don't delete this function
bool UniDeskCustomWallpaper::nativeEventFilter(const QByteArray& eventType, void* message,
                                     QT_NATIVE_EVENT_RESULT_TYPE* result) { 
    return false;
}

void UniDeskCustomWallpaper::attachToWallpaper() {
#ifdef Q_OS_WIN
    HWND hwnd = (HWND)winId();
    if (!hwnd) return;

    // 查找Progman窗口
    HWND progman = FindWindowW(L"Progman", nullptr);
    if (!progman) {
        attachedToWallpaper(false);
        return;
    }

    // 尝试使用旧版的方法让桌面窗口分裂
    sendMessageTimeout(progman, 0x052C, 0, 0);
    sendMessageTimeout(progman, 0x052C, 0xD, 0);
    sendMessageTimeout(progman, 0x052C, 0xD, 1);

    HWND topWorkerW = nullptr;
    HWND shellDefView = nullptr;
    HWND firstWorkerWs = nullptr;
    HWND oldTargetWorkerW = nullptr;

    // 遍历WorkerW窗口，找到SHELLDLL_DefView
    while (true) {
        topWorkerW = FindWindowExW(nullptr, topWorkerW, L"WorkerW", nullptr);
        if (topWorkerW == firstWorkerWs) {
            break;
        }
        if (firstWorkerWs == nullptr) {
            firstWorkerWs = topWorkerW;
        }
        if (!topWorkerW) {
            continue;
        }

        shellDefView = FindWindowExW(topWorkerW, nullptr, L"SHELLDLL_DefView", nullptr);
        if (!shellDefView) {
            continue;
        }

        // 找到桌面图标层级的窗口
        oldTargetWorkerW = FindWindowExW(nullptr, topWorkerW, L"WorkerW", nullptr);
        break;
    }

    if (!oldTargetWorkerW) {
        // 新版Windows的方法：在Progman下查找或创建WorkerW
        HWND newWorkerW = FindWindowExW(progman, nullptr, L"WorkerW", nullptr);
        if (!newWorkerW) {
            // 如果没有WorkerW，则创建一个
            newWorkerW = createWorkerW(progman);
        }
        if (newWorkerW) {
            SetParent(hwnd, newWorkerW);
            
            attachedToWallpaper(true);
        } else {
            attachedToWallpaper(false);
        }
    } else {
        // 旧版Windows的方法：直接附加到分裂后的WorkerW下
        SetParent(hwnd, oldTargetWorkerW);
        // 确保窗口在壁纸层
        SetWindowPos(hwnd, shellDefView, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
        attachedToWallpaper(true);
    }
#endif
}

bool UniDeskCustomWallpaper::eventFilter(QObject *obj, QEvent *event) {
    if (event->type() == QEvent::MouseMove) {
        QMouseEvent *mouseEvent = static_cast<QMouseEvent*>(event);
        if (mouseEvent) {
            emit mouseMoved(mouseEvent->position().toPoint());
        }
    } else if (event->type() == QEvent::MouseButtonPress) {
        QMouseEvent *mouseEvent = static_cast<QMouseEvent*>(event);
        if (mouseEvent) {
            isMousePressed(true);
            emit mousePressed(mouseEvent->button(), mouseEvent->position().toPoint());
        }
    } else if (event->type() == QEvent::MouseButtonRelease) {
        QMouseEvent *mouseEvent = static_cast<QMouseEvent*>(event);
        if (mouseEvent) {
            isMousePressed(false);
            emit mouseReleased(mouseEvent->button(), mouseEvent->position().toPoint());
        }
    }
    return QObject::eventFilter(obj, event);
}

void UniDeskCustomWallpaper::showEvent(QShowEvent *event) {
    QQuickWindow::showEvent(event);
    attachToWallpaper();
    // Install native event filter
    if (QGuiApplication::instance()) {
        QGuiApplication::instance()->installNativeEventFilter(this);
        QGuiApplication::instance()->installEventFilter(this);
    }
}


