import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import unidesk_qml
import org.itcdt.unidesk

Item{
    id: root
    property color selectedColor
    RowLayout{
        anchors.fill: parent
        spacing: 10
        Rectangle{
            color: root.selectedColor
            border.width: 2
            radius: 5
            border.color: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,0)
            Layout.preferredWidth: 200 
        }
        UniDeskComboBox{
            id: combobox
            model: ["RGBA","HSLA","HSVA","HEX"]
            currentIndex: 0
            Layout.preferredWidth: 100 
        }
        UniDeskTextField{
            id: tf_r_h
            text: {
                if (combobox.currentText === "RGBA"){
                    return root.selectedColor.r.toString();
                }
                else if (combobox.currentText === "HSLA"){
                    return root.selectedColor.hslHue.toString();
                }
                else if (combobox.currentText === "HSVA"){
                    return root.selectedColor.hsvHue.toString();
                }
            }
            Layout.preferredWidth: 40
            visible: combobox.currentText!=="HEX"
            onEditingFinished: {
                if (combobox.currentText === "RGBA"){
                    root.selectedColor.r=text;
                }
                else if (combobox.currentText === "HSLA"){
                    root.selectedColor.hslHue=text;
                }
                else if (combobox.currentText === "HSVA"){
                    root.selectedColor.hsvHue=text;
                }
            }
        }
        UniDeskTextField{
            id: tf_g_s
            text: {
                if (combobox.currentText === "RGBA"){
                    return root.selectedColor.g.toString();
                }
                else if (combobox.currentText === "HSLA"){
                    return root.selectedColor.hslSaturation.toString();
                }
                else if (combobox.currentText === "HSVA"){
                    return root.selectedColor.hsvSaturation.toString();
                }
            }
            Layout.preferredWidth: 40
            visible: combobox.currentText!=="HEX"
            onEditingFinished: {
                if (combobox.currentText === "RGBA"){
                    root.selectedColor.g=text;
                }
                else if (combobox.currentText === "HSLA"){
                    root.selectedColor.hslSaturation=text;
                }
                else if (combobox.currentText === "HSVA"){
                    root.selectedColor.hsvSaturation=text;
                }
            }
        }
        UniDeskTextField{
            id: tf_b_l_v
            text: {
                if (combobox.currentText === "RGBA"){
                    return root.selectedColor.b.toString();
                }
                else if (combobox.currentText === "HSLA"){
                    return root.selectedColor.hslLightness.toString();
                }
                else if (combobox.currentText === "HSVA"){
                    return root.selectedColor.hsvValue.toString();
                }
            }
            Layout.preferredWidth: 40
            visible: combobox.currentText!=="HEX"
            onEditingFinished: {
                if (combobox.currentText === "RGBA"){
                    root.selectedColor.r=text;
                }
                else if (combobox.currentText === "HSLA"){
                    root.selectedColor.hslLightness=text;
                }
                else if (combobox.currentText === "HSVA"){
                    root.selectedColor.hsvValue=text;
                }
            }
        }
        UniDeskTextField{
            id: tf_a
            text: root.selectedColor.a.toString()
            Layout.preferredWidth: 40
            visible: combobox.currentText!=="HEX"
            onEditingFinished: {
                root.selectedColor.a=text;
            }
        }
        UniDeskTextField{
            id: tf_hex
            Layout.preferredWidth: 200
            visible: combobox.currentText==="HEX"
        }
        
        UniDeskButton{
            display: Button.TextOnly
            contentText: qsTr("选择颜色")
            bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
            bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
            borderWidth: 1
            radius: 5
            onClicked: {
            }
        }
    }
    ColorDialog{
        id: color_dialog
        options: ColorDialog.ShowAlphaChannel
        selectedColor: root.selectedColor
        onAccepted:{
            root.selectedColor=selectedColor;
        }
    }
}