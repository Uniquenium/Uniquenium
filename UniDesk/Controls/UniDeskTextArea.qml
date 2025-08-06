import QtQuick
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk.PyPlugin


Rectangle {
    id: rect_r
    implicitWidth: 200
    implicitHeight: 200
    border.width: 1
    color: control.hovered ? UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2) :"transparent"
    border.color: control.activeFocus ? UniDeskSettings.primaryColor : UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1) 
    radius: 5
    property alias area: control
    ScrollView{
        anchors.fill: parent
        hoverEnabled: true
        T.TextArea {
            id: control

            implicitWidth: Math.max(contentWidth + leftPadding + rightPadding,
                                    implicitBackgroundWidth + leftInset + rightInset,
                                    placeholder.implicitWidth + leftPadding + rightPadding)
            implicitHeight: Math.max(contentHeight + topPadding + bottomPadding,
                                    implicitBackgroundHeight + topInset + bottomInset,
                                    placeholder.implicitHeight + topPadding + bottomPadding)

            padding: 6
            leftPadding: padding + 4

            color: control.palette.text
            placeholderTextColor: control.palette.placeholderText
            selectionColor: control.palette.highlight
            selectedTextColor: control.palette.highlightedText
            
            font: UniDeskTextStyle.little
            UniDeskText {
                id: placeholder
                x: control.leftPadding
                y: control.topPadding
                width: control.width - (control.leftPadding + control.rightPadding)
                height: control.height - (control.topPadding + control.bottomPadding)

                text: control.placeholderText
                font: control.font
                color: control.placeholderTextColor
                verticalAlignment: control.verticalAlignment
                visible: !control.length && !control.preeditText && (!control.activeFocus || control.horizontalAlignment !== Qt.AlignHCenter)
                elide: Text.ElideRight
                renderType: control.renderType
            }
            onEditingFinished:{
                focus=false;
            }
        }
    }
}