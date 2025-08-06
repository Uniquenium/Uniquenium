import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls.Basic
import QtQuick.Templates as T
import Qt5Compat.GraphicalEffects
import UniDesk
import org.uniquenium.unidesk
import Qt.labs.platform as QLP

Button{
    id: root
    display: Button.IconOnly
    property bool disabled
    property string contentText
    property string iconSource
    property double radius: 3
    property double iconSize: 15

    property color textNormalColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
    property color iconNormalColor: Qt.rgba(0,0,0,1)
    property color bgNormalColor: "transparent"

    property color bgHoverColor: UniDeskGlobals.isLight ? bgNormalColor.darker(1.2) : bgNormalColor.lighter(1.2)
    property color bgPressColor: UniDeskGlobals.isLight ? bgNormalColor.darker(1.5) : bgNormalColor.lighter(1.5)
    property color bgDisableColor: UniDeskGlobals.isLight ? bgNormalColor.lighter(1.5) : bgNormalColor.darker(1.5)

    property color iconHoverColor: UniDeskGlobals.isLight ? iconNormalColor.darker(1.2) : iconNormalColor.lighter(1.2)
    property color iconPressColor: UniDeskGlobals.isLight ? iconNormalColor.darker(1.5) : iconNormalColor.lighter(1.5)
    property color iconDisableColor: UniDeskGlobals.isLight ? iconNormalColor.lighter(1.5) : iconNormalColor.darker(1.5)

    property color textHoverColor: UniDeskGlobals.isLight ? textNormalColor.darker(1.2) : textNormalColor.lighter(1.2)
    property color textPressColor: UniDeskGlobals.isLight ? textNormalColor.darker(1.5) : textNormalColor.lighter(1.5)
    property color textDisableColor: UniDeskGlobals.isLight ? textNormalColor.lighter(1.5) : textNormalColor.darker(1.5)

    property color bgColor: UniDeskTools.switchColor(bgNormalColor,bgHoverColor,bgPressColor,bgDisableColor,hovered,pressed,disabled)
    property color iconColor: UniDeskTools.switchColor(iconNormalColor,iconHoverColor,iconPressColor,iconDisableColor,hovered,pressed,disabled)
    property color textColor: UniDeskTools.switchColor(textNormalColor,textHoverColor,textPressColor,textDisableColor,hovered,pressed,disabled)

    property double borderWidth: 0
    property color borderColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)

    property int mouseX: mouse_area.mouseX
    property int mouseY: mouse_area.mouseY

    font: UniDeskTextStyle.tiny
    clip: false
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
        border.width: root.borderWidth
        border.color: root.borderColor
        color: root.bgColor
        MouseArea{
            id: mouse_area
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            hoverEnabled: true
            onHoveredChanged:{
                tool_tip.x=mouseX;
                tool_tip.y=mouseY;
            }
        }
    }
    Component {
        id: com_icon
        UniDeskIcon {
            id: icon
            iconColor: root.iconColor
            iconSize: root.iconSize
            iconSource: root.iconSource
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
            UniDeskText {
                text: root.contentText
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                visible: display !== Button.IconOnly
                color: root.textColor
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
            UniDeskText {
                text: root.contentText
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                visible: display !== Button.IconOnly
                color: root.textColor
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
            if (root.display !== Button.IconOnly) {
                return false
            }
            return hovered
        }
        text: root.contentText
        delay: 2000
        font: root.font
    }
}