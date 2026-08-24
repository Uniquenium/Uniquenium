#include <QAbstractNativeEventFilter>
#include <QObject>
#include <QQmlProperty>
#include <QQuickItem>
#include <QQuickWindow>
#include <QMouseEvent>
#include <QCursor>
#include <QGuiApplication>
#include <QDateTime>
#include <QScreen>
#include <QTimer>
#include "UniDeskRoot.h"

using CursorShapeType = Qt::CursorShape;

#ifdef Q_OS_WIN
#include <windows.h>
#include <dwmapi.h>
#endif
#ifdef Q_OS_LINUX
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#endif

UniDeskRoot::UniDeskRoot(QQuickWindow *parent)
    : QQuickWindow { parent }
{
    setFlag(Qt::FramelessWindowHint, true);
#ifdef Q_OS_WIN
    setFlag(Qt::WindowStaysOnBottomHint, true);
#endif
    setFlag(Qt::Tool, true);
    margins(4);
    edges(Qt::Edges());
    mouseClickThrough(true);

    // Connect property change signal to update window style
    connect(this, &UniDeskRoot::mouseClickThroughChanged,
            this, &UniDeskRoot::onMouseClickThroughChanged);
    m_mouseTimer=new QTimer(this);
    m_mouseTimer->setInterval(16);
    connect(m_mouseTimer, &QTimer::timeout, this, &UniDeskRoot::checkMousePosition);
    m_mouseTimer->start();
    m_cursor=new QCursor();
}

UniDeskRoot::~UniDeskRoot() {
    if (QGuiApplication::instance()) {
        QGuiApplication::instance()->removeNativeEventFilter(this);
        QGuiApplication::instance()->removeEventFilter(this);
    }
    if(m_mouseTimer) {
        m_mouseTimer->stop();
        delete m_mouseTimer;
        m_mouseTimer=nullptr;
    }
    if(m_cursor) {
        delete m_cursor;
        m_cursor=nullptr;
    }
}

void UniDeskRoot::showEvent(QShowEvent *event) {
    QQuickWindow::showEvent(event);
    
    updateClickThrough();
    
    // Install native event filter
    if (QGuiApplication::instance()) {
        QGuiApplication::instance()->installNativeEventFilter(this);
        QGuiApplication::instance()->installEventFilter(this);
    }
}


//don't delete this function
bool UniDeskRoot::nativeEventFilter(const QByteArray& eventType, void* message,
                                     QT_NATIVE_EVENT_RESULT_TYPE* result) { 
    return false;
}

void UniDeskRoot::onMouseClickThroughChanged() {
    updateClickThrough();
}

void UniDeskRoot::updateClickThrough() {
#ifdef Q_OS_WIN
    HWND hwnd = (HWND)winId();
    if (hwnd) {
        LONG style = GetWindowLong(hwnd, GWL_EXSTYLE);
        if (mouseClickThrough()) {
            SetWindowLong(hwnd, GWL_EXSTYLE, style | WS_EX_TRANSPARENT);
        } else {
            SetWindowLong(hwnd, GWL_EXSTYLE, style & ~WS_EX_TRANSPARENT);
        }
    }
#endif
#ifdef Q_OS_LINUX
    QString platform = QGuiApplication::platformName();
    if (platform == "xcb" || platform == "X11") {
        Display *display = XOpenDisplay(nullptr);
        if (display) {
            ::Window window = static_cast< ::Window>(winId());
            if (mouseClickThrough()) {
                XSetWindowAttributes attrs;
                attrs.event_mask = ExposureMask | KeyPressMask | KeyReleaseMask | FocusChangeMask;
                attrs.override_redirect = True;
                XChangeWindowAttributes(display, window, CWEventMask | CWOverrideRedirect, &attrs);
            } else {
                XSetWindowAttributes attrs;
                attrs.event_mask = ExposureMask | KeyPressMask | KeyReleaseMask | FocusChangeMask | ButtonPressMask | ButtonReleaseMask | ButtonMotionMask | PointerMotionMask | EnterWindowMask | LeaveWindowMask;
                attrs.override_redirect = False;
                XChangeWindowAttributes(display, window, CWEventMask | CWOverrideRedirect, &attrs);
            }
            XFlush(display);
            XCloseDisplay(display);
        }
    } else if (platform == "wayland") {
        if (mouseClickThrough()) {
            setFlag(Qt::WindowTransparentForInput, true);
        } else {
            setFlag(Qt::WindowTransparentForInput, false);
        }
    }
#endif
}

bool UniDeskRoot::eventFilter(QObject *obj, QEvent *event) {

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

void UniDeskRoot::checkMousePosition() {
    QPoint globalPos = QCursor::pos();
    if (globalPos != m_lastMousePos) {
        m_lastMousePos = globalPos;
        emit mouseMoved(globalPos);
    }
}

void UniDeskRoot::setCursorShape(int shape) {
    m_cursor->setShape((CursorShapeType)shape);
}