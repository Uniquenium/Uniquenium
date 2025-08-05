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
        contentHeight: renderFormatComboBox.y+renderFormatComboBox.height-text0.y+30
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
        UniDeskText{
            id: text11
            text: qsTr("字重")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.verticalCenter: fontWeightSpinBox.verticalCenter
            anchors.margins: 10
        }
        UniDeskSpinBox{
            id: fontWeightSpinBox
            anchors.top: fontSizeSpinBox.bottom
            anchors.right: parent.right
            anchors.margins: 10
            editable: true
            from: 100
            to: 1000
            stepSize: 100
            onValueChanged: {
                if (editingComponent) {
                    editingComponent.weight = value;
                }
            }
            Component.onCompleted: {
                value = editingComponent ? editingComponent.weight : 400;
            }
        }
        UniDeskCheckBox{
            id: canMoveCheckBox
            text: qsTr("可拖动")
            anchors.top: fontWeightSpinBox.bottom
            anchors.left: parent.left
            anchors.margins: 10
            checked: editingComponent ? editingComponent.canMove : false
            onCheckedChanged: {
                editingComponent.canMove=checked;
            }
        }
        UniDeskCheckBox{
            id: smallCapsCheckBox
            text: qsTr("小大写字母")
            anchors.top: canMoveCheckBox.bottom
            anchors.left: parent.left
            anchors.margins: 10
            checked: editingComponent ? editingComponent.smallCaps : false
            onCheckedChanged: {
                editingComponent.smallCaps=checked;
            }
        }
        UniDeskCheckBox{
            id: boldCheckBox
            text: qsTr("粗体")
            anchors.top: smallCapsCheckBox.bottom
            anchors.left: parent.left
            anchors.margins: 10
            checked: editingComponent ? editingComponent.bold : false
            onCheckedChanged: {
                editingComponent.bold = checked;
            }
        }
        UniDeskCheckBox{
            id: italicCheckBox
            text: qsTr("斜体")
            anchors.top: boldCheckBox.bottom
            anchors.left: parent.left
            anchors.margins: 10
            checked: editingComponent ? editingComponent.italic : false
            onCheckedChanged: {
                editingComponent.italic = checked;
            }
        }
        UniDeskCheckBox{
            id: underlineCheckBox
            text: qsTr("下划线")
            anchors.top: italicCheckBox.bottom
            anchors.left: parent.left
            anchors.margins: 10
            checked: editingComponent ? editingComponent.underline : false
            onCheckedChanged: {
                editingComponent.underline = checked;
            }
        }
        UniDeskCheckBox{
            id: strikeoutCheckBox
            text: qsTr("删除线")
            anchors.top: underlineCheckBox.bottom
            anchors.left: parent.left
            anchors.margins: 10
            checked: editingComponent ? editingComponent.strikeout : false
            onCheckedChanged: {
                editingComponent.strikeout = checked;
            }
        }
        UniDeskText{
            id: text6
            text: qsTr("字间距")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.verticalCenter: letterSpacingSpinBox.verticalCenter
            anchors.margins: 10
        }
        UniDeskSpinBox{
            id: letterSpacingSpinBox
            anchors.top: strikeoutCheckBox.bottom
            anchors.right: parent.right
            anchors.margins: 10
            editable: true
            value: editingComponent ? editingComponent.letterSpacing : 0
            from: -1000
            to: 1000
            stepSize: 1
            onValueChanged: {
                if (editingComponent) {
                    editingComponent.letterSpacing = value;
                }
            }
        }
        UniDeskText{
            id: text7
            text: qsTr("词间距")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.verticalCenter: wordSpacingSpinBox.verticalCenter
            anchors.margins: 10
        }
        UniDeskSpinBox{
            id: wordSpacingSpinBox
            anchors.top: letterSpacingSpinBox.bottom
            anchors.right: parent.right
            anchors.margins: 10
            editable: true
            value: editingComponent ? editingComponent.wordSpacing : 0
            from: -1000
            to: 1000
            stepSize: 1
            onValueChanged: {
                if (editingComponent) {
                    editingComponent.wordSpacing = value;
                }
            }
        }
        UniDeskText{
            id: text8
            text: qsTr("行高倍数")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.verticalCenter: lineHeightField.verticalCenter
            anchors.margins: 10
        }
        UniDeskTextField{
            id: lineHeightField
            anchors.top: wordSpacingSpinBox.bottom
            anchors.right: parent.right
            anchors.margins: 10
            onEditingFinished: {
                if (editingComponent) {
                    editingComponent.lineHeight = parseFloat(text);
                }
            }
            Component.onCompleted: {
                text = editingComponent ? editingComponent.lineHeight.toString() : "1"
            }
        }
        UniDeskText{
            id: text9
            text: qsTr("文本样式")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.verticalCenter: styleComboBox.verticalCenter
            anchors.margins: 10
        }
        UniDeskComboBox{
            id: styleComboBox
            anchors.top: lineHeightField.bottom
            anchors.right: parent.right
            anchors.margins: 10
            model: [qsTr("正常"), qsTr("凸起"), qsTr("描边"), qsTr("凹陷")]
            onCurrentIndexChanged: {
                if (editingComponent) {
                    if (currentIndex === 0) {
                        editingComponent.style = Text.Normal;
                    } else if (currentIndex === 1) {
                        editingComponent.style = Text.Raised;
                    } else if (currentIndex === 2) {
                        editingComponent.style = Text.Outline;
                    } else if (currentIndex === 3) {
                        editingComponent.style = Text.Sunken;
                    }
                }
            }
            Component.onCompleted: {
                currentIndex = editingComponent ? (editingComponent.style===Text.Normal ? 0 : editingComponent.style===Text.Raised ? 1 : editingComponent.style==Text.Outline ? 2 : 3) : 0
            }
        }
        UniDeskText{
            id: text10
            text: qsTr("文本样式颜色")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.verticalCenter: styleColorPicker.verticalCenter
            anchors.margins: 10
        }
        UniDeskColorPicker{
            id: styleColorPicker
            anchors.top: styleComboBox.bottom
            anchors.right: parent.right
            anchors.margins: 10
            selectedColor: editingComponent ? editingComponent.styleColor : Qt.rgba(0,0,0,1)
            onSelectedColorChanged: {
                if (editingComponent) {
                    editingComponent.styleColor = selectedColor;
                }
            }
        }
        UniDeskText{
            id: text12
            text: qsTr("渲染格式")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.verticalCenter: renderFormatComboBox.verticalCenter
            anchors.margins: 10
        }
        UniDeskComboBox{
            id: renderFormatComboBox
            anchors.top: styleColorPicker.bottom
            anchors.right: parent.right
            anchors.margins: 10
            model: [qsTr("自动"), qsTr("纯文本"), qsTr("富文本（HTML）"), qsTr("Markdown")]
            onCurrentIndexChanged: {
                if (editingComponent) {
                    editingComponent.textFormat = currentIndex === 0 ? Text.AutoText : currentIndex === 1 ? Text.PlainText : currentIndex === 2 ? Text.RichText : Text.MarkdownText;
                }
            }
            Component.onCompleted: {
                currentIndex = editingComponent ? (editingComponent.textFormat === Text.AutoText ? 0 : editingComponent.textFormat === Text.PlainText ? 1 : editingComponent.textFormat === Text.RichText ? 2 : 3) : 0;
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