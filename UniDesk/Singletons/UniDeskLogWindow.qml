pragma Singleton
import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects
import UniDesk.Controls
import UniDesk.Singletons
import UniDesk

UniDeskWindow{
    id: window
    width: 500
    height: 350
    title: qsTr("日志")
    autoDestroy: false
    autoVisible: false
    UniDeskTextArea{
        id: textArea
        anchors.fill: parent
        anchors.margins: 10
        
        area.readOnly: true
        area.text: UniDeskConsole.consoleContent
        Connections{
            target: textArea.area
            function onTextChanged() {
                textArea.view.contentY = textArea.view.contentHeight-textArea.view.height-10
            }
        }
    }
}