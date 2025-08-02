import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import org.uniquenium.unidesk

T.Menu {
    id: control
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                            contentHeight + topPadding + bottomPadding)
    property Item bg: background
    margins: 0
    overlap: 1
    spacing: 0
    delegate: UniDeskMenuItem {}
    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
            duration: 100
        }
    }
    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1
            to: 0
            duration: 100
        }
    }
    closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutside
    contentItem: ListView {
        implicitHeight: contentHeight
        model: control.contentModel
        interactive: Window.window ? contentHeight + control.topPadding
                                        + control.bottomPadding > Window.window.height : false
        clip: true
        currentIndex: control.currentIndex
        ScrollBar.vertical: ScrollBar {}
    }
    background: Rectangle {
        implicitWidth: 150
        implicitHeight: 36
        color: UniDeskGlobals.isLight ? Qt.rgba(1, 1, 1 , 0.7) : Qt.rgba(0,0,0, 0.7)
        border.color: UniDeskGlobals.isLight ? Qt.rgba(0, 0, 0,1) : Qt.rgba(1, 1, 1, 1)
        border.width: 1
        radius: 3
    }
    T.Overlay.modal: Rectangle {
        color: "transparent"
        radius: window.windowVisibility === Window.Maximized ? 0 : 3
    }
    T.Overlay.modeless: Rectangle {
        color: "transparent"
        radius: window.windowVisibility === Window.Maximized ? 0 : 3
    }
}

