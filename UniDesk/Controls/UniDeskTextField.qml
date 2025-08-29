import QtQuick
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk

T.TextField {
    id: control

    property bool enableFontDelegate: false
    implicitWidth: implicitBackgroundWidth + leftInset + rightInset
                   || Math.max(contentWidth, placeholder.implicitWidth) + leftPadding + rightPadding
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding,
                             placeholder.implicitHeight + topPadding + bottomPadding)
    padding: 2
    leftPadding: padding + 4

    font: enableFontDelegate && UniDeskTools.fontIndex(control.text) !== -1? UniDeskTools.font(control.text, 13) : UniDeskTextStyle.little

    color: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
    selectionColor: UniDeskSettings.primaryColor
    placeholderTextColor: Qt.rgba(0.5,0.5,0.5,1)
    verticalAlignment: TextInput.AlignVCenter

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
    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 35
        border.width: 1
        color: control.hovered ? UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2) :"transparent"
        border.color: control.activeFocus ? UniDeskSettings.primaryColor : UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1) 
        radius: 5
    }
    onEditingFinished:{
        focus=false;
    }
}