import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk
import UniDesk.Controls
import UniDesk.Singletons

UniDeskWindow{
    id: window
    width: 1000
    height: 700
    title: qsTr("框架选项")
    autoVisible: false
    showMinimize: false
    showMaximize: false
    autoDestroy: false
    property var comManager
    property UniDeskComBase editingComponent
    
    ScrollView{
        anchors.fill: parent
        hoverEnabled: true
        contentHeight: bgColorPicker.y+bgColorPicker.height-basicOptions.y+30
        
        UniDeskComBasicOptions{
            id: basicOptions
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 10
            comManager: window.comManager
            editingComponent: window.editingComponent
        }
        
        // 边框宽度
        UniDeskText{
            text: qsTr("边框宽度")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.margins: 10
            anchors.verticalCenter: borderWidthSpinBox.verticalCenter
        }
        UniDeskSpinBox{
            id: borderWidthSpinBox
            anchors.top: basicOptions.bottom
            anchors.right: parent.right
            anchors.margins: 10
            editable: true
            value: editingComponent ? editingComponent.borderWidth : 1
            from: 0
            to: 10
            stepSize: 1
            onValueModified: {
                if (editingComponent) {
                    editingComponent.borderWidth = value;
                    editingComponent.saveComToFile();
                }
            }
        }
        
        // 边框圆角
        UniDeskText{
            text: qsTr("边框圆角")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.margins: 10
            anchors.verticalCenter: borderRadiusSpinBox.verticalCenter
        }
        UniDeskSpinBox{
            id: borderRadiusSpinBox
            anchors.top: borderWidthSpinBox.bottom
            anchors.right: parent.right
            anchors.margins: 10
            editable: true
            value: editingComponent ? editingComponent.borderRadius : 3
            from: 0
            to: Math.min(editingComponent.width, editingComponent.height) / 2
            stepSize: 1
            onValueModified: {
                if (editingComponent) {
                    editingComponent.borderRadius = value;
                    editingComponent.saveComToFile();
                }
            }
        }
        
        // 边框颜色
        UniDeskText{
            text: qsTr("边框颜色")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.margins: 10
            anchors.verticalCenter: borderColorPicker.verticalCenter
        }
        UniDeskColorPicker{
            id: borderColorPicker
            anchors.top: borderRadiusSpinBox.bottom
            anchors.right: parent.right
            anchors.margins: 10
            selectedColor: editingComponent ? editingComponent.borderColor : (UniDeskGlobals.isLight ? "#000000" : "#ffffff")
            onSelectedColorChanged: {
                if (editingComponent) {
                    editingComponent.borderColor = selectedColor;
                    editingComponent.saveComToFile();
                }
            }
        }
        
        // 背景颜色
        UniDeskText{
            text: qsTr("背景颜色")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.margins: 10
            anchors.verticalCenter: bgColorPicker.verticalCenter
        }
        UniDeskColorPicker{
            id: bgColorPicker
            anchors.top: borderColorPicker.bottom
            anchors.right: parent.right
            anchors.margins: 10
            selectedColor: editingComponent ? editingComponent.backgroundColor : (UniDeskGlobals.isLight ? "#ffffff" : "#000000")
            onSelectedColorChanged: {
                if (editingComponent) {
                    editingComponent.backgroundColor = selectedColor;
                    editingComponent.saveComToFile();
                }
            }
        }
    }
    
    Connections{
        target: UniDeskGlobals
        function onApplicationQuit() {
            window.close();
        }
    }
}