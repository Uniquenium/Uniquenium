import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk

T.MenuItem {
    property bool disabled
    property Component iconDelegate : com_icon
    property int iconSpacing: 5
    property string iconSource
    property int iconSize: 16
    property color textColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
    id: root
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)
    padding: 1
    spacing: 1
    height: visible ? implicitHeight : 0
    font: UniDeskTextStyle.little
    enabled: !disabled
    Component{
        id:com_icon
        UniDeskIcon{
            id: content_icon
            iconSize: root.iconSize
            iconSource: root.iconSource
            iconColor: enabled ? UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1) : root.palette.mid
        }
    }
    contentItem: Item{
        Row{
            spacing: root.iconSpacing
            readonly property real arrowPadding: root.subMenu && root.arrow ? root.arrow.width + root.spacing : 0
            readonly property real indicatorPadding: root.checkable && root.indicator ? root.indicator.width + root.spacing : 0
            anchors{
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: (!root.mirrored ? indicatorPadding : arrowPadding)+5
                right: parent.right
                rightMargin: (root.mirrored ? indicatorPadding : arrowPadding)+5
            }
            Loader{
                id:loader_icon
                sourceComponent: iconDelegate
                anchors.verticalCenter: parent.verticalCenter
                visible: status === Loader.Ready
            }
            UniDeskText {
                id:content_text
                text: root.text
                font: root.font
                color: enabled ? root.textColor : root.palette.mid
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
    indicator: UniDeskIcon {
        x: root.mirrored ? root.width - width - root.rightPadding : root.leftPadding
        y: root.topPadding + (root.availableHeight - height) / 2
        visible: root.checked
        iconSource: "qrc:/media/img/check.svg"
        iconColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
    }
    arrow: UniDeskIcon {
        x: root.mirrored ? root.leftPadding+20 : root.width - width - root.rightPadding-20
        y: root.topPadding + (root.availableHeight - height) / 2
        visible: root.subMenu
        iconSource: "qrc:/media/img/arrow-right-s-line.svg"
        iconColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
    }
    background: Item {
        implicitWidth: 150
        implicitHeight: 36
        x: 1
        y: 1
        width: root.width - 2
        height: root.height - 2
        Rectangle{
            anchors.fill: parent
            anchors.margins: 3
            radius: 3
            color: {
                if(root.highlighted){
                    return UniDeskSettings.primaryColor
                }
                return Qt.rgba(1,1,1,0)
            }
        }
    }
    onHoveredChanged:{
        highlighted=hovered;
    }
}