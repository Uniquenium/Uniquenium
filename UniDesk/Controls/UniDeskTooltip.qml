import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects
import UniDesk.Controls
import UniDesk

T.ToolTip {
    id: root
    x: parent ? (parent.width - implicitWidth) / 2 : 0
    y: -implicitHeight - 3
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)
    margins: 6
    padding: 6
    font: UniDeskTextStyle.tiny
    closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutsideParent
                 | T.Popup.CloseOnReleaseOutsideParent
    contentItem: UniDeskText {
        text: root.text
        font: root.font
        wrapMode: Text.Wrap
    }
    background: Rectangle {
        color: UniDeskGlobals.isLight ? Qt.rgba(1, 1, 1, 1) : Qt.rgba(0, 0, 0, 1)
        border.color: UniDeskGlobals.isLight ? Qt.rgba(0, 0, 0, 1) : Qt.rgba(1, 1, 1, 1)
        border.width: 0.5
    }
}
