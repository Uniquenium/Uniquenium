pragma Singleton
import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects
import UniDesk.Controls
import UniDesk.PyPlugin

UniDeskWindow{
    id: window
    width: 1000
    height: 700
    title: qsTr("页面层级")
    ScrollView{
        UniDeskTreeView{
            model: UniDeskComManager.componentTree()
            anchors.fill:parent
            
        }
    }
}