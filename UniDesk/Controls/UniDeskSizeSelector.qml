import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk.Controls
import UniDesk

Item{
    id: control
    property var editingComponent
    GridLayout{
        id: gridLayout
        columnSpacing: 10
        rowSpacing: 10
        anchors.fill: parent
        UniDeskText{
            id: textWidth
            text: qsTr("宽度")
            font: UniDeskTextStyle.little
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Layout.column: 0
            Layout.row: 0
        }
        UniDeskSpinBox{
            id: widthSpinBox
            Layout.column: 1
            Layout.row: 0
            editable: true
            from: 1
            to: 3000
            onValueModified:{
                if(control.editingComponent){
                    control.editingComponent.geoWidth = value;
                    control.editingComponent.saveComToFile();
                }
            }
            Component.onCompleted: {
                value = control.editingComponent ? control.editingComponent.geoWidth : 200
            }
        }
        UniDeskText{
            id: textHeight
            text: qsTr("高度")
            font: UniDeskTextStyle.little
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Layout.column: 0
            Layout.row: 1
        }
        UniDeskSpinBox{
            id: heightSpinBox
            Layout.column: 1
            Layout.row: 1
            editable: true
            from: 1
            to: 3000
            onValueModified:{
                if(control.editingComponent){
                    control.editingComponent.geoHeight = value;
                    control.editingComponent.saveComToFile();
                }
            }
            Component.onCompleted: {
                value = control.editingComponent ? control.editingComponent.geoHeight : 200
            }
        }
    }
    Component.onCompleted: {
        implicitWidth = gridLayout.childrenRect.width
        implicitHeight = gridLayout.childrenRect.height
    }
    function refreshSize(){
        widthSpinBox.value = control.editingComponent ? control.editingComponent.geoWidth : 200
        heightSpinBox.value = control.editingComponent ? control.editingComponent.geoHeight : 200
    }
}