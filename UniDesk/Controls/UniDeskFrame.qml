import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk

T.Frame {
    id: control
    property alias border: d.border
    property alias color: d.color
    property alias radius: d.radius
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, contentHeight + topPadding + bottomPadding)
    padding: 0
    background: Rectangle {
        id: d
        radius: 3
        border.width: 1
        border.color: UniDeskGlobals.isLight ? Qt.rgba(0, 0, 0, 1) : Qt.rgba(255, 255, 255, 1)
        color: UniDeskGlobals.isLight ? Qt.rgba(255, 255, 255, 1) : Qt.rgba(0, 0, 0, 1)
    }
}