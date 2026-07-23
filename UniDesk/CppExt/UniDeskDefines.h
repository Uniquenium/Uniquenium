/**
 *  @brief This file contains commonly used types, etc.
 *         for UniDesk
 */
#ifndef UNIDESKDEFINES_H
#define UNIDESKDEFINES_H

#include <QObject>
#include <QQmlEngine>

/**
 * @brief UniDeskWindowType
 */
namespace UniDeskWindowType {
Q_NAMESPACE

enum LaunchMode {
    Standard = 0,
    SingleTask = 1,
    SingleInstance = 2
};
Q_ENUM_NS(LaunchMode)

QML_NAMED_ELEMENT(UniDeskWindowType)
}

namespace UniDeskColorMode {
Q_NAMESPACE
enum ColorMode {
    ColorModeLight = 0x0000,
    ColorModeDark = 0x0001,
    ColorModeSystem = 0x0002
};

Q_ENUM_NS(ColorMode)

QML_NAMED_ELEMENT(UniDeskColorMode)
}

namespace UniDeskFileMode {
Q_NAMESPACE
enum FileMode {
    FileModeFile = 0 ,
    FileModeFolder = 1
};

Q_ENUM_NS(FileMode)

QML_NAMED_ELEMENT(UniDeskFileMode)
}

namespace UniDeskApiRequestType {
Q_NAMESPACE
enum ApiRequestType {
    ApiRequestTypeGet = 0,
    ApiRequestTypePost = 1,
    ApiRequestTypePut = 2,
    ApiRequestTypeDelete = 3
};

Q_ENUM_NS(ApiRequestType)

QML_NAMED_ELEMENT(UniDeskApiRequestType)
}

namespace UniDeskButtonActionType {
Q_NAMESPACE
enum ButtonActionType {
    ButtonActionApp = 0,
    ButtonActionWeb = 1,
    ButtonActionCommand = 2
};

Q_ENUM_NS(ButtonActionType)

QML_NAMED_ELEMENT(UniDeskButtonActionType)
}

namespace UniDeskMainPanelOrientation {
Q_NAMESPACE
enum MainPanelOrientation {
    Horizontal = 0,  // 横向
    Vertical = 1     // 纵向
};

Q_ENUM_NS(MainPanelOrientation)

QML_NAMED_ELEMENT(UniDeskMainPanelOrientation)
}

namespace UniDeskMainPanelPosition {
Q_NAMESPACE
enum MainPanelPosition {
    Top = 0,    // 顶部
    Bottom = 1  // 底部
};

Q_ENUM_NS(MainPanelPosition)

QML_NAMED_ELEMENT(UniDeskMainPanelPosition)
}

#endif // UNIDESKDEFINES_H