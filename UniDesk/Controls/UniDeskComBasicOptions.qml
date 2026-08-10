import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk.Controls
import UniDesk.Singletons
import UniDesk

Item {
    id: control
    property var comManager
    property var editingComponent
    onEditingComponentChanged: {
        posSelector.refreshPosition();
    }
    implicitHeight: column.implicitHeight
    ColumnLayout{
        id: column
        anchors.fill: parent
        spacing: 10
        UniDeskText{
            text: qsTr("组件名称")
            font: UniDeskTextStyle.little
            Layout.leftMargin: 10
            Layout.fillWidth: true
        }
        UniDeskTextField {
            id: idField
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            placeholderText: qsTr("请输入组件名称")
            text: control.editingComponent ? control.editingComponent.name : ""
            onEditingFinished: {
                if (control.editingComponent) {
                    control.editingComponent.name = text;
                    control.editingComponent.saveComToFile();
                }
            }
        }
        RowLayout{
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            spacing: 10
            UniDeskText{
                text: qsTr("父组件（设为壁纸层将冻结组件）")
                font: UniDeskTextStyle.little
                Layout.alignment: Qt.AlignVCenter
            }
            Item{Layout.fillWidth: true}
            UniDeskComBox{
                id: parentComboBox
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 200
                comManager: control.comManager
                editingComponent: control.editingComponent
                currentComponent: control.editingComponent ? control.editingComponent.parent : null
                onActivated: {
                    let p = parentComboBox.getComByIndex(currentIndex);
                    if(control.editingComponent){
                        control.editingComponent.chgePrntWthoutMvAndSv(p);
                    }
                }
                onCurrentComponentChanged: {
                    currentIndex=getIndexByCom(currentComponent);
                }
                Component.onCompleted: {
                    currentIndex=getIndexByCom(currentComponent);
                }
            }
        }
        UniDeskPosSelector{
            id: posSelector
            comManager: control.comManager
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            editingComponent: control.editingComponent
        }
        UniDeskSizeSelector{
            id: sizeSelector
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            editingComponent: control.editingComponent
        }
        RowLayout{
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            spacing: 10
            UniDeskText{
                text: qsTr("旋转角度")
                font: UniDeskTextStyle.little
                Layout.alignment: Qt.AlignVCenter
            }
            Item{Layout.fillWidth: true}
            UniDeskSpinBox{
                id: rotationSpinBox
                editable: true
                value: control.editingComponent ? control.editingComponent.rotation : 0
                from: 0
                to: 359
                stepSize: 1
                onValueModified: {
                    if (control.editingComponent) {
                        control.editingComponent.rotation = value;
                        control.editingComponent.saveComToFile();
                    }
                }
            }
        }
        RowLayout{
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            spacing: 10
            UniDeskText{
                text: qsTr("Z坐标")
                font: UniDeskTextStyle.little
                Layout.alignment: Qt.AlignVCenter
            }
            Item{Layout.fillWidth: true}
            UniDeskSpinBox{
                id: zSpinBox
                editable: true
                value: control.editingComponent ? control.editingComponent.z : 0
                from: -99999
                to: 99999
                stepSize: 1
                onValueModified: {
                    if (control.editingComponent) {
                        control.editingComponent.z = value;
                        control.editingComponent.saveComToFile();
                        if(control.comManager){
                            control.comManager.updateComTreeZ(control.editingComponent, value);
                        }
                    }
                }
            }
        }
        RowLayout{
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            spacing: 10
            UniDeskText{
                text: qsTr("透明度")
                font: UniDeskTextStyle.little
                Layout.alignment: Qt.AlignVCenter
            }
            Item{Layout.fillWidth: true}
            UniDeskSpinBox{
                id: opacitySpinBox
                editable: true
                value: control.editingComponent ? control.editingComponent.itemOpacity * 100 : 100
                from: 0
                to: 100
                stepSize: 1
                onValueModified: {
                    if (control.editingComponent) {
                        control.editingComponent.itemOpacity = value / 100;
                        control.editingComponent.saveComToFile();
                    }
                }
            }
        }
    }
    function refreshPosition(){
        posSelector.refreshPosition();
    }
    Component.onCompleted: {
        refreshPosition();
    }
}