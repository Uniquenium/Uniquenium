import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects
import unidesk_qml
import org.itcdt.unidesk

TabButton{
    id: control
    property bool disabled
    property color bgNormalColor: "transparent"
    property color bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
    property color bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
    property color bgDisableColor: UniDeskGlobals.isLight ? bgNormalColor.lighter(1.5) : bgNormalColor.darker(1.5)
    width: implicitWidth
    background: Rectangle{
        radius: 3
        color: control.checked ? UniDeskSettings.primaryColor : 
            UniDeskTools.switchColor(control.bgNormalColor,control.bgHoverColor,control.bgPressColor,control.bgDisableColor,control.hovered,control.pressed,control.disabled)
        border.color: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
        border.width: 1
    }
    contentItem: UniDeskText{
        text: control.text
    }
    anchors.margins: 2
    padding: 10
}