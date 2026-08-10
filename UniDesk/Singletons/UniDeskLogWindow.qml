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
    autoDestroy: false// keep the system appbar hidden (temporary solution)
    autoVisible: false
    UniDeskTextArea{
        id: textArea
        anchors.fill: parent
        anchors.margins: 10
        
        area.readOnly: true
        area.text: UniDeskConsole.consoleContent
    }
}