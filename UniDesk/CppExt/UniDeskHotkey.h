#pragma once

#include "QHotkey"
#include "stdafx.h"

#include <QObject>
#include <QQuickItem>

#include <memory>


class UniDeskHotkey : public QObject {

    Q_OBJECT
    Q_PROPERTY_AUTO(QString, sequence)
    Q_PROPERTY_AUTO(QString, name)
    Q_PROPERTY_READONLY_AUTO(bool, isRegistered)
    QML_NAMED_ELEMENT(UniDeskHotkey)

public:
    explicit UniDeskHotkey(QObject* parent = nullptr);
    ~UniDeskHotkey() = default;
    
    Q_SIGNAL void activated();

private:
    std::shared_ptr<QHotkey> _hotkey;
};
