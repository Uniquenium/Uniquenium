import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs 
import QtQml
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import org.itcdt.unidesk

Button {
    property bool disabled: false
    property string contentDescription: ""
    property color normalColor: UniDeskSettings.primaryColor
    property color hoverColor: UniDeskGlobals.isLight ? normalColor.lighter(1.15) : normalColor.darker(1.15)
    property color pressedColor: UniDeskGlobals.isLight ? normalColor.lighter(1.3) : normalColor.darker(1.3)
    property color disableColor: normalColor.darker(3.3)
    property bool textBold: true
    property url webLink
    property color textColor: UniDeskTools.switchColor(normalColor,hoverColor,pressedColor,disableColor,hovered,pressed,disabled)
    id: control
    horizontalPadding: 6
    enabled: !disabled
    font: UniDeskUnits.little
    background: Rectangle {
        implicitWidth: 30
        implicitHeight: 30
        color: "transparent"
    }
    focusPolicy: Qt.TabFocus
    Accessible.role: Accessible.Button
    Accessible.name: control.text
    Accessible.description: contentDescription
    Accessible.onPressAction: control.clicked()
    contentItem: UniDeskText {
        id: btn_text
        text: control.text
        font: control.font
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: control.textColor
    }
    onClicked: {
        if(webLink){
            UniDeskTools.web_browse(webLink)
        }
    }
}
