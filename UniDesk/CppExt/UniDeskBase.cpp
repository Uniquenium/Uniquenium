#include <QAbstractNativeEventFilter>
#include <QObject>
#include <QQmlProperty>
#include <QQuickItem>
#include <QQuickWindow>
#include <QMouseEvent>
#include <QCursor>
#include "UniDeskBase.h"

UniDeskBase::UniDeskBase(QQuickWindow *parent)
    : QQuickWindow { parent }
{
    setFlag(Qt::FramelessWindowHint, true);
    setFlag(Qt::WindowStaysOnBottomHint, true);
    setFlag(Qt::Tool, true);
    margins(4);
    edges(Qt::Edges());
}

UniDeskBase::~UniDeskBase() = default;

void UniDeskBase::focusOutEvent(QFocusEvent *event){
    emit focusOut();
    QQuickWindow::focusOutEvent(event);
}

void UniDeskBase::mouseMoveEvent(QMouseEvent *event){
    if (visibility() != QWindow::Maximized && visibility() != QWindow::FullScreen && !property("fixSize").toBool()) {
        QPoint p = event->pos();
        edges(Qt::Edges());
        if (p.x() < margins()) edges(edges() | Qt::LeftEdge);
        if (p.x() > (width() - margins())) edges(edges() | Qt::RightEdge);
        if (p.y() < margins()) edges(edges() | Qt::TopEdge);
        if (p.y() > (height() - margins())) edges(edges() | Qt::BottomEdge);
        UniDeskBase::updateCursor();
    }
    QQuickWindow::mouseMoveEvent(event);
}

void UniDeskBase::mousePressEvent(QMouseEvent *event) {
    if (event->button() == Qt::LeftButton) {
        if (edges() != Qt::Edges() && property("canResize").toBool()) {
            startSystemResize(edges());
        } else if (property("canMove").toBool()) {
            startSystemMove();
        }
    }
    QQuickWindow::mousePressEvent(event);
}

void UniDeskBase::mouseReleaseEvent(QMouseEvent *event){
    edges(Qt::Edges());
    if (event->button() == Qt::RightButton) {
        emit rightClicked();
    }
    QQuickWindow::mouseReleaseEvent(event);
}

void UniDeskBase::updateCursor() {
    if (edges() == Qt::Edges()) {
        setCursor(Qt::ArrowCursor);
    } else if (edges() == Qt::LeftEdge || edges() == Qt::RightEdge) {
        setCursor(Qt::SizeHorCursor);
    } else if (edges() == Qt::TopEdge || edges() == Qt::BottomEdge) {
        setCursor(Qt::SizeVerCursor);
    } else if (edges() == (Qt::LeftEdge | Qt::TopEdge) || edges() == (Qt::RightEdge | Qt::BottomEdge)) {
        setCursor(Qt::SizeFDiagCursor);
    } else if (edges() == (Qt::RightEdge | Qt::TopEdge) || edges() == (Qt::LeftEdge | Qt::BottomEdge)) {
        setCursor(Qt::SizeBDiagCursor);
    }
}
