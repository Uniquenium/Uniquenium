import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import org.uniquenium.unidesk

T.CheckBox {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    padding: 6
    spacing: 6

    font: UniDeskUnits.little
    indicator: Rectangle {
        implicitWidth: 20
        implicitHeight: 20

        x: control.text ? (control.mirrored ? control.width - width - control.rightPadding : control.leftPadding) : control.leftPadding + (control.availableWidth - width) / 2
        y: control.topPadding + (control.availableHeight - height) / 2

        color: control.checkState !== Qt.Unchecked ? control.hovered ? UniDeskSettings.primaryColor.lighter(1.5) : UniDeskSettings.primaryColor : control.hovered ? UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2) :"transparent"
        border.width: 1
        border.color: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
        radius: 5

        UniDeskIcon {
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            source: "qrc:/media/img/check.svg"
            visible: control.checkState === Qt.Checked
            iconColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,1) : Qt.rgba(0,0,0,1)
        }

        Rectangle {
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            width: 16
            height: 3
            color: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,1) : Qt.rgba(0,0,0,1)
            visible: control.checkState === Qt.PartiallyChecked
        }
    }

    contentItem: UniDeskText{
        leftPadding: control.indicator && !control.mirrored ? control.indicator.width + control.spacing : 0
        rightPadding: control.indicator && control.mirrored ? control.indicator.width + control.spacing : 0

        text: control.text
        font: control.font
        verticalAlignment: Qt.AlignVCenter
    }
}
