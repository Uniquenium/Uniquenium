import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk
import org.uniquenium.unidesk

UniDeskWindow{
    id: window
    width: 1000
    height: 700
    title: qsTr("文本选项")
    property var comManager
    property UniDeskComBase editingComponent
    ScrollView{
        anchors.fill: parent
        hoverEnabled: true
        contentHeight: 1000
        UniDeskText{
            id: text0
            text: qsTr("组件id（不能重复）")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.margins: 10
            anchors.verticalCenter: idField.verticalCenter
        }
        UniDeskTextField {
            id: idField
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 10
            placeholderText: qsTr("请输入组件id")
            text: editingComponent ? editingComponent.identification : ""
            onEditingFinished: {
                if(UniDeskComManager.validateId(text)){  
                    if (editingComponent) {
                        editingComponent.identification = text;
                    }
                }
                else{
                    text = editingComponent.identification;
                }
            }
        }
        UniDeskText{
            id: text5
            text: qsTr("父组件")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.margins: 10
            anchors.verticalCenter: parentComBox.verticalCenter
        }
        UniDeskComBox{
            id: parentComBox
            anchors.top: idField.bottom
            anchors.right: parent.right
            anchors.margins: 10
            editingComponent: window.editingComponent
            onCurrentTextChanged: {
                if (currentIndex === 0) {
                    editingComponent.parentComponent = null;
                }
                else{
                    editingComponent.parentComponent = UniDeskComManager.getComById(currentText);
                    editingComponent.visualXChanged();
                    editingComponent.visualYChanged();
                }
            }
            Component.onCompleted: {
                currentIndex = editingComponent.parentComponent ? UniDeskComManager.getIndexById(editingComponent.parentComponent.identification) : 0;
            }
        }
        UniDeskPosSelector{
            id: posSelector
            anchors.top: parentComBox.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            editingComponent: window.editingComponent
        }
        UniDeskText{
            id: text1
            text: qsTr("文本内容")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.verticalCenter: textField1.verticalCenter
            anchors.margins: 10
        }
        UniDeskTextArea{
            id: textField1
            anchors.top: posSelector.bottom
            anchors.right: parent.right
            anchors.margins: 10
            area.placeholderText: qsTr("请输入文本内容")
            area.text: editingComponent ? editingComponent.textContent : ""
            area.onTextChanged: {
                if (editingComponent) {
                    editingComponent.textContent = area.text;
                }
            }
        }
        UniDeskText{
            id: text2
            text: qsTr("文本颜色")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.verticalCenter: colorPicker1.verticalCenter
            anchors.margins: 10
        }
        UniDeskColorPicker{
            id: colorPicker1
            anchors.top: textField1.bottom
            anchors.right: parent.right
            anchors.margins: 10
            selectedColor: editingComponent ? editingComponent.textColor : Qt.rgba(0,0,0,1)
            onSelectedColorChanged: {
                if (editingComponent) {
                    editingComponent.textColor = selectedColor;
                }
            }
        }
        UniDeskText{
            id: text3
            text: qsTr("字体")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.verticalCenter: fontBox1.verticalCenter
            anchors.margins: 10
        }
        UniDeskFontBox{
            id: fontBox1
            anchors.top: colorPicker1.bottom
            anchors.right: parent.right
            anchors.margins: 10
            currentIndex:  UniDeskTools.fontIndex(editingComponent.fontFamily ?editingComponent.fontFamily: UniDeskSettings.globalFontFamily)
            onCurrentTextChanged: {
                if (editingComponent) {
                    editingComponent.fontFamily = currentText;
                }
            }
        }
        UniDeskText{
            id: text4
            text: qsTr("字号")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.verticalCenter: fontSizeSpinBox.verticalCenter
            anchors.margins: 10
        }
        UniDeskSpinBox{
            id: fontSizeSpinBox
            anchors.top: fontBox1.bottom
            anchors.right: parent.right
            anchors.margins: 10
            editable: true
            value: editingComponent ? editingComponent.fontSize : 30
            from: 1
            to: 1000
            stepSize: 1
            onValueChanged: {
                if (editingComponent) {
                    editingComponent.fontSize = value;
                }
            }
        }
        UniDeskCheckBox{
            id: canMoveCheckBox
            text: qsTr("可拖动")
            anchors.top: fontSizeSpinBox.bottom
            anchors.left: parent.left
            anchors.margins: 10
            checked: editingComponent ? editingComponent.canMove : false
            onCheckedChanged: {
                editingComponent.canMove=checked;
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