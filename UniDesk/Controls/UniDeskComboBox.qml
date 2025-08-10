pragma ComponentBehavior: Bound
import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk.Controls
import UniDesk.Singletons
import UniDesk.PyPlugin

T.ComboBox {
    id: control

    property bool enableFontDelegate: false
    property bool enableComDelegate: false
    padding: 5
    height: 30
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    leftPadding: padding + (!control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
    rightPadding: padding + (control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
    
    delegate: UniDeskMenuItem {
        required property var model
        required property int index

        width: ListView.view.width
        text: model[control.textRole]
        font: control.enableFontDelegate ? UniDeskTools.font(model[control.textRole],13) : UniDeskTextStyle.little

        highlighted: control.highlightedIndex === index
        hoverEnabled: control.hoverEnabled
        onHighlightedChanged: {
            if(control.enableComDelegate){
                var com=UniDeskComManager.getComById(text)
                if(com){
                    com.indicated=highlighted;
                }
            }
        }
    }

    indicator: UniDeskIcon {
        x: control.mirrored ? control.padding : control.width - width - control.padding
        y: control.topPadding + (control.availableHeight - height) / 2
        source: popup.visible ? "qrc:/media/img/arrow-up-s-line.svg" : "qrc:/media/img/arrow-down-s-line.svg"
        iconSize: 15
        opacity: enabled ? 1 : 0.3
        iconColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
    }

    contentItem: UniDeskTextField {
        leftPadding: !control.mirrored ? 12 : control.editable && activeFocus ? 3 : 1
        rightPadding: control.mirrored ? 12 : control.editable && activeFocus ? 3 : 1
        topPadding: 6 - control.padding
        bottomPadding: 6 - control.padding

        text: control.editable ? control.editText : control.displayText
        enabled: control.editable
        autoScroll: control.editable
        readOnly: control.down
        inputMethodHints: control.inputMethodHints
        validator: control.validator
        selectByMouse: control.selectTextByMouse

        color: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
        verticalAlignment: Text.AlignVCenter

        background: Rectangle {
            visible: control.enabled && control.editable && !control.flat
            border.width: 0
            border.color: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
            color: "transparent"
        }
        enableFontDelegate: control.enableFontDelegate
    }

    background: Rectangle {
        implicitWidth: 140
        implicitHeight: 40

        color: control.hovered ? UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2) :"transparent"
        border.color: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
        border.width: 1
        radius: 5
        visible: !control.flat || control.down
    }

    popup: T.Popup {
        y: control.height
        width: control.width
        height: Math.min(contentItem.implicitHeight, control.Window.height - topMargin - bottomMargin)
        topMargin: 6
        bottomMargin: 6
        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.delegateModel
            currentIndex: control.highlightedIndex
            highlightMoveDuration: 10
            ScrollBar.vertical: ScrollBar {}
        }

        background: Rectangle {
            width: parent.width
            height: parent.height
            color: UniDeskGlobals.isLight ? Qt.rgba(1, 1, 1 , 0.7) : Qt.rgba(0,0,0, 0.7)
            border.color: UniDeskGlobals.isLight ? Qt.rgba(0, 0, 0,1) : Qt.rgba(1, 1, 1, 1)
            border.width: 1
            radius: 3
        }
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
    }
}
