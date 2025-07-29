import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects
import unidesk_qml
import org.itcdt.unidesk

T.SpinBox {
    id: control

    // Note: the width of the indicators are calculated into the padding
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             up.implicitIndicatorHeight, down.implicitIndicatorHeight)

    leftPadding: padding + (control.mirrored ? (up.indicator ? up.indicator.width : 0) : (down.indicator ? down.indicator.width : 0)) + 10
    rightPadding: padding + (control.mirrored ? (down.indicator ? down.indicator.width : 0) : (up.indicator ? up.indicator.width : 0)) + 10
    validator: IntValidator {
        locale: control.locale.name
        bottom: Math.min(control.from, control.to)
        top: Math.max(control.from, control.to)
    }
    contentItem: UniDeskTextField {
        z: 2
        text: control.value
        clip: width < implicitWidth
        padding: 6

        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: control.inputMethodHints
        onTextEdited: {
            control.value=text;
        }
    }

    up.indicator: Rectangle {
        x: control.mirrored ? 0 : control.width - width
        height: control.height
        implicitWidth: 40
        implicitHeight: 40
        color: control.up.pressed ? UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5) : "transparent"
        border.color: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
        radius: 5
        Rectangle {
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            width: parent.width / 3
            height: 2
            color: enabled ? UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1) : control.palette.mid
        }
        Rectangle {
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            width: 2
            height: parent.width / 3
            color: enabled ? UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1) : control.palette.mid
        }
    }

    down.indicator: Rectangle {
        x: control.mirrored ? parent.width - width : 0
        height: control.height
        implicitWidth: 40
        implicitHeight: 40
        color: control.down.pressed ? UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5) : "transparent"
        border.color: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
        radius: 5
        Rectangle {
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            width: parent.width / 3
            height: 2
            color: enabled ? UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1) : control.palette.mid
        }
    }

    background: Rectangle {
        implicitWidth: 140
        color: "transparent"
        border.color: "transparent"
    }
}
