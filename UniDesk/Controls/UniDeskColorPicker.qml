import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk.Controls
import UniDesk

Item{
    id: root
    property color selectedColor
    property var comManager
    property UniDeskComboBox colorTypeBox: combobox
    implicitHeight: 40
    Rectangle{
        id: rect_color
        color: root.selectedColor
        border.width: 2
        radius: 5
        border.color: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
        width: 200
        height: 30
        anchors.margins: 10
        anchors.right: combobox.left
        anchors.verticalCenter: parent.verticalCenter
    }
    UniDeskComboBox{
        id: combobox
        comManager: root.comManager
        model: ["RGBA","HSLA","HSVA","HEX"]
        currentIndex: 0
        width: 100 
        height: 30
        anchors.right: combobox.currentText==="HEX" ? tf_hex.left : tf_r_h.left
        anchors.margins: 10
        anchors.verticalCenter: parent.verticalCenter
    }
    UniDeskTextField{
        id: tf_r_h
        text: {
            if (combobox.currentText === "RGBA"){
                return Math.floor(root.selectedColor.r*255).toString();
            }
            else if (combobox.currentText === "HSLA"){
                return Math.floor(root.selectedColor.hslHue*360).toString();
            }
            else if (combobox.currentText === "HSVA"){
                return Math.floor(root.selectedColor.hsvHue*360).toString();
            }
        }
        width: 40
        height: 30
        visible: combobox.currentText!=="HEX"
        anchors.right: tf_g_s.left
        anchors.margins: 10
        anchors.verticalCenter: parent.verticalCenter
        onEditingFinished: {
            if (combobox.currentText === "RGBA"){
                root.selectedColor.r=text/255;
            }
            else if (combobox.currentText === "HSLA"){
                root.selectedColor.hslHue=text/360;
            }
            else if (combobox.currentText === "HSVA"){
                root.selectedColor.hsvHue=text/360;
            }
        }
    }
    UniDeskTextField{
        id: tf_g_s
        text: {
            if (combobox.currentText === "RGBA"){
                return Math.floor(root.selectedColor.g*255).toString();
            }
            else if (combobox.currentText === "HSLA"){
                return Math.floor(root.selectedColor.hslSaturation*100).toString();
            }
            else if (combobox.currentText === "HSVA"){
                return Math.floor(root.selectedColor.hsvSaturation*100).toString();
            }
        }
        width: 40
        height: 30
        visible: combobox.currentText!=="HEX"
        anchors.right: tf_b_l_v.left
        anchors.margins: 10
        anchors.verticalCenter: parent.verticalCenter
        onEditingFinished: {
            if (combobox.currentText === "RGBA"){
                root.selectedColor.g=text/255;
            }
            else if (combobox.currentText === "HSLA"){
                root.selectedColor.hslSaturation=text/100;
            }
            else if (combobox.currentText === "HSVA"){
                root.selectedColor.hsvSaturation=text/100;
            }
        }
    }
    UniDeskTextField{
        id: tf_b_l_v
        text: {
            if (combobox.currentText === "RGBA"){
                return Math.floor(root.selectedColor.b*255).toString();
            }
            else if (combobox.currentText === "HSLA"){
                return Math.floor(root.selectedColor.hslLightness*100).toString();
            }
            else if (combobox.currentText === "HSVA"){
                return Math.floor(root.selectedColor.hsvValue*100).toString();
            }
        }
        width: 40
        height: 30
        visible: combobox.currentText!=="HEX"
        anchors.right: tf_a.left
        anchors.margins: 10
        anchors.verticalCenter: parent.verticalCenter
        onEditingFinished: {
            if (combobox.currentText === "RGBA"){
                root.selectedColor.b=text/255;
            }
            else if (combobox.currentText === "HSLA"){
                root.selectedColor.hslLightness=text/100;
            }
            else if (combobox.currentText === "HSVA"){
                root.selectedColor.hsvValue=text/100;
            }
        }
    }
    UniDeskTextField{
        id: tf_a
        text: Math.floor(root.selectedColor.a*100).toString()
        width: 40
        height: 30
        visible: combobox.currentText!=="HEX"
        anchors.right: btnSelectColor.left
        anchors.margins: 10
        anchors.verticalCenter: parent.verticalCenter
        onEditingFinished: {
            root.selectedColor.a=text/100;
        }
    }
    UniDeskTextField{
        id: tf_hex
        width: 195
        height: 30
        anchors.verticalCenter: parent.verticalCenter
        text: root.selectedColor.toString()
        visible: combobox.currentText==="HEX"
        anchors.right: btnSelectColor.left
        anchors.margins: 10
        onEditingFinished: {
            root.selectedColor=text
        }
    }
    
    UniDeskButton{
        id: btnSelectColor
        display: Button.TextOnly
        contentText: qsTr("选择颜色")
        bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
        bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
        borderWidth: 1
        radius: 5
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        onClicked: {
            color_dialog.open()
        }
    }
    ColorDialog{
        id: color_dialog
        title: qsTr("选择颜色")
        options: ColorDialog.ShowAlphaChannel
        selectedColor: root.selectedColor
        onAccepted:{
            root.selectedColor=selectedColor;
        }
    }

}