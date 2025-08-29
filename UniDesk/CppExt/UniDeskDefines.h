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

// Used in UniDeskCustomDialog
namespace UniDeskCustomDialogType {
Q_NAMESPACE
enum ButtonFlag { NeutralButton = 0x0001,
    NegativeButton = 0x0002,
    PositiveButton = 0x0004 };

Q_ENUM_NS(ButtonFlag)

QML_NAMED_ELEMENT(UniDeskCustomDialogType)
}

// Used in UniDeskTabView
namespace UniDeskTabViewType {
    Q_NAMESPACE
    enum TabWidthBehavior { Equal = 0x0000, SizeToContent = 0x0001, Compact = 0x0002 };

    Q_ENUM_NS(TabWidthBehavior)

    enum CloseButtonVisibility { Never = 0x0000, Always = 0x0001, OnHover = 0x0002 };

    Q_ENUM_NS(CloseButtonVisibility)

    QML_NAMED_ELEMENT(UniDeskTabViewType)
}

namespace UniDeskNavigationViewType {
    Q_NAMESPACE
    enum DisplayMode { Open = 0x0000, Compact = 0x0001, Minimal = 0x0002, Auto = 0x0004 };

    Q_ENUM_NS(DisplayMode)

    enum PageMode { Stack = 0x0000, NoStack = 0x0001 };

    Q_ENUM_NS(PageMode)

    QML_NAMED_ELEMENT(UniDeskNavigationViewType)
}

namespace UniDeskPageType {
    Q_NAMESPACE
    enum LaunchMode {
        Standard = 0x0000,
        SingleTask = 0x0001,
        SingleTop = 0x0002,
        SingleInstance = 0x0004
    };

    Q_ENUM_NS(LaunchMode)

    QML_NAMED_ELEMENT(UniDeskPageType)
}

#endif // UNIDESKDEFINES_H
