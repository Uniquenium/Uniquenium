#ifndef UNIDESKBASE_H
#define UNIDESKBASE_H

#include "stdafx.h"
#include <QQuickWindow>
#include <QMouseEvent>
#include <QCursor>
#include <QtQml/qqml.h>

class UniDeskBase : public QQuickWindow {
    Q_OBJECT
    Q_PROPERTY_AUTO(int, margins)
    Q_PROPERTY_AUTO(Qt::Edges, edges)
    QML_NAMED_ELEMENT(UniDeskBase)
public:
    explicit UniDeskBase(QQuickWindow *parent = nullptr);
    ~UniDeskBase() override;
signals:
    void focusOut();
    void rightClicked();

protected:
    void focusOutEvent(QFocusEvent *event) override;
    void mouseMoveEvent(QMouseEvent *event) override;
    void mousePressEvent(QMouseEvent *event) override;
    void mouseReleaseEvent(QMouseEvent *event) override;
    void updateCursor();
};

#endif // UNIDESKBASE_H
