import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects
import unidesk_qml
import org.itcdt.unidesk

Button{
    id: root
    display: Button.IconOnly
    property bool disabled
    property string contentText
    property string iconSource
    property double radius
    property color contentTextColor: Qt.rgba(0,0,0,1)
    property color iconColor: Qt.rgba(0,0,0,1)
    property color bgNormalColor: "transparent"
    property color bgHoverColor: UniDeskUnits.isLight ? bgNormalColor.darker(1.2) : bgNormalColor.lighter(1.2)
    property color bgPressColor: UniDeskUnits.isLight ? bgNormalColor.darker(1.5) : bgNormalColor.lighter(1.5)
    property color bgDisableColor: UniDeskUnits.isLight ? bgNormalColor.lighter(1.5) : bgNormalColor.darker(1.5)
    font: UniDeskUnits.tiny
    Accessible.role: Accessible.Button
    Accessible.name: root.text
    Accessible.description: contentText
    Accessible.onPressAction: root.clicked()
    horizontalPadding: 10
    verticalPadding: 10
    background: Rectangle {
        implicitWidth: 30
        implicitHeight: 30
        radius: root.radius
        color: UniDeskTools.switchColor(root.bgNormalColor,root.bgHoverColor,root.bgPressColor,root.bgDisableColor,
                    root.hovered,root.pressed,root.disabled)
    }
    Component {
        id: com_icon
        Image {
            id: icon
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            width: 50
            height: 50
            source: root.iconSource
            ColorOverlay{
                anchors.fill: icon
                source: icon
                color: root.iconColor
            }
        }
    }
    Component {
        id: com_row
        RowLayout {
            Loader {
                sourceComponent: com_icon
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                visible: display !== Button.TextOnly
            }
            Text {
                text: root.contentText
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                visible: display !== Button.IconOnly
                color: root.contentTextColor
                font: root.font
            }
        }
    }
    Component {
        id: com_column
        ColumnLayout {
            Loader {
                sourceComponent: com_icon
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                visible: display !== Button.TextOnly
            }
            Text {
                text: root.contentText
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                visible: display !== Button.IconOnly
                color: root.contentTextColor
                font: root.font
            }
        }
    }
    contentItem: Loader{
        sourceComponent: {
            if (display === Button.TextUnderIcon) {
                return com_column
            }
            return com_row
        }
    }
    ToolTip {
        id: tool_tip
        visible: {
            if (root.contentText === "") {
                return false
            }
            if (control.display !== Button.IconOnly) {
                return false
            }
            return hovered
        }
        text: root.contentText
        delay: 1000
    }
}