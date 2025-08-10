import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk.Controls
import UniDesk.PyPlugin

UniDeskDialog{
    id: control
    width: 400
    height: 200
    flags: Qt.Dialog | Qt.FramelessWindowHint | Qt.WindowMinimizeButtonHint | Qt.WindowStaysOnTopHint 
    property int clickedIndex: -1
    property string text
    property bool autoCloseAfterClick: true
    signal buttonClicked
    ListModel{
        id: buttonlist
    }
    UniDeskText{
        id: content_text
        text: control.text
        font.family: UniDeskTextStyle.little.family
        font.pixelSize: 20
        anchors.top: parent.top
        anchors.bottom: buttons_view.top
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Qt.AlignHCenter
    }
    ListView{
        id: buttons_view
        model: buttonlist
        orientation: Qt.Horizontal
        spacing: 10
        width: contentWidth
        height: 40
        delegate: UniDeskButton{
            display: Button.TextOnly
            contentText: model.text
            bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
            bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
            borderWidth: 1
            radius: 5
            onClicked: {
                control.clickedIndex = index
                control.buttonClicked();
                if(control.autoCloseAfterClick){
                    control.close();
                }
            }
        }
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 10
    }
    function addButton(text){
        buttonlist.append({"text":text})
    }
}