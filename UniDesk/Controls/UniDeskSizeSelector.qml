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
            from: 0
            to: 3000
            value: control.editingComponent ? control.editingComponent.width : 100
            onValueModified:{
                if(control.editingComponent){
                    control.editingComponent.width = value;
                    control.editingComponent.saveComToFile();
                }
            }
            Component.onCompleted: {
                value = control.editingComponent.width
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
            from: 0
            to: 3000
            value: control.editingComponent ? control.editingComponent.height : 50
            onValueModified:{
                if(control.editingComponent){
                    control.editingComponent.height = value;
                    control.editingComponent.saveComToFile();
                }
            }
            Component.onCompleted: {
                value = control.editingComponent.height
            }
        }
    }
    Component.onCompleted: {
        implicitWidth = gridLayout.childrenRect.width
        implicitHeight = gridLayout.childrenRect.height
        refreshSize();
    }
    function refreshSize(){
        widthSpinBox.value = control.editingComponent.width 
        heightSpinBox.value = control.editingComponent.height 
    }
    onEditingComponentChanged: {
        refreshSize();
    }
    Connections{
        target: control.editingComponent
        function onComponentCompleted(){
            refreshSize();
        }
        function onEndDrag(){
            refreshSize();
            control.editingComponent.saveComToFile();
        }
        function onWidthChanged(){
            refreshSize();
        }
        function onHeightChanged(){
            refreshSize();
        }
    }
}