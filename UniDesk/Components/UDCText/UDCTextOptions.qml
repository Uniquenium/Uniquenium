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
    title: qsTr("文本选项")
    autoVisible: false
    showMinimize: false
    showMaximize: false
    autoDestroy: false
    property var comManager
    property UniDeskComBase editingComponent
    ScrollView{
        anchors.fill: parent
        hoverEnabled: true
        contentHeight: verticalAlignmentComboBox.y+verticalAlignmentComboBox.height-text0.y+30
        UniDeskText{
            id: text0
            text: qsTr("组件名称（不能重复）")
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
            placeholderText: qsTr("请输入组件名称")
            text: editingComponent ? editingComponent.name : ""
            onEditingFinished: {
                if(comManager.validateName(text)){  
                    if (editingComponent)   {
                        editingComponent.name = text;
                    }
                }
                else{
                    text = editingComponent.name;
                }
                editingComponent.saveComToFile();
            }
        }
        UniDeskText{
            text: qsTr("父组件")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.margins: 10
            anchors.verticalCenter: parentComboBox.verticalCenter
        }
        UniDeskComBox{
            id: parentComboBox
            anchors.top: idField.bottom
            anchors.right: parent.right
            anchors.margins: 10
            comManager: window.comManager
            editingComponent: window.editingComponent
            currentComponent: window.editingComponent.parent
            onActivated: {
                let p = parentComboBox.getComByIndex(currentIndex);
                editingComponent.changeParentWithoutMoving(p);
                editingComponent.saveComToFile();
            }
        }
        UniDeskPosSelector{
            id: posSelector
            comManager: window.comManager
            anchors.top: parentComboBox.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            editingComponent: window.editingComponent
        }
        UniDeskSizeSelector{
            id: sizeSelector
            anchors.top: posSelector.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            editingComponent: window.editingComponent
        }
        UniDeskText{
            id: text13
            text: qsTr("旋转角度")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.verticalCenter: rotationSpinBox.verticalCenter
            anchors.margins: 10
        }
        UniDeskSpinBox{
            id: rotationSpinBox
            anchors.top: sizeSelector.bottom
            anchors.right: parent.right
            anchors.margins: 10
            editable: true
            value: editingComponent ? editingComponent.rotation : 0
            from: 0
            to: 359
            stepSize: 1
            onValueModified: {
                if (editingComponent) {
                    editingComponent.rotation = value;
                    editingComponent.saveComToFile();
                }
            }
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
            anchors.top: rotationSpinBox.bottom
            anchors.right: parent.right
            anchors.margins: 10
            width: 300
            area.placeholderText: qsTr("请输入文本内容")
            area.text: editingComponent ? editingComponent.textContent : ""
            area.onTextChanged: {
                if (editingComponent) {
                    editingComponent.textContent = area.text;
                    editingComponent.saveComToFile();
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
                    editingComponent.saveComToFile();
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
            comManager: window.comManager
            anchors.top: colorPicker1.bottom
            anchors.right: parent.right
            anchors.margins: 10
            currentIndex:  UniDeskTools.fontIndex(editingComponent.fontFamily ?editingComponent.fontFamily: UniDeskSettings.globalFontFamily)
            onCurrentTextChanged: {
                if (editingComponent) {
                    editingComponent.fontFamily = currentText;
                    editingComponent.saveComToFile();
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
            onValueModified: {
                if (editingComponent) {
                    editingComponent.fontSize = value;
                    editingComponent.saveComToFile();
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
            value: editingComponent ? editingComponent.weight : 400
            onValueModified: {
                if (editingComponent) {
                    editingComponent.weight = value;
                    editingComponent.saveComToFile();
                }
            }
            Component.onCompleted: {
                value = editingComponent ? editingComponent.weight : 400;
            }
        }
        UniDeskText{
            id: textOpacity
            text: qsTr("透明度")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.margins: 10
            anchors.verticalCenter: opacitySpinBox.verticalCenter
        }
        UniDeskSpinBox{
            id: opacitySpinBox
            anchors.top: fontWeightSpinBox.bottom
            anchors.right: parent.right
            anchors.margins: 10
            editable: true
            value: editingComponent ? editingComponent.itemOpacity * 100 : 100
            from: 0
            to: 100
            stepSize: 1
            onValueModified: {
                if (editingComponent) {
                    editingComponent.itemOpacity = value / 100;
                    editingComponent.saveComToFile();
                }
            }
        }
        UniDeskCheckBox{
            id: smallCapsCheckBox
            text: qsTr("小大写字母")
            anchors.top: opacitySpinBox.bottom
            anchors.left: parent.left
            anchors.margins: 10
            checked: editingComponent ? editingComponent.smallCaps : false
            onCheckedChanged: {
                editingComponent.smallCaps=checked;
                editingComponent.saveComToFile();
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
                editingComponent.saveComToFile();
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
                editingComponent.saveComToFile();
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
                editingComponent.saveComToFile();
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
                editingComponent.saveComToFile();
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
            onValueModified: {
                if (editingComponent) {
                    editingComponent.letterSpacing = value;
                    editingComponent.saveComToFile();
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
            onValueModified: {
                if (editingComponent) {
                    editingComponent.wordSpacing = value;
                    editingComponent.saveComToFile();
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
                    editingComponent.saveComToFile();
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
            comManager: window.comManager
            currentIndex: editingComponent ? (editingComponent.style===Text.Normal ? 0 : editingComponent.style===Text.Raised ? 1 : editingComponent.style===Text.Outline ? 2 : 3) : 0
            onActivated:  {
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
                editingComponent.saveComToFile();
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
                    editingComponent.saveComToFile();
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
            comManager: window.comManager
            model: [qsTr("自动"), qsTr("纯文本"), qsTr("富文本（HTML）"), qsTr("Markdown")]
            currentIndex: editingComponent ? (editingComponent.textFormat === Text.AutoText ? 0 : editingComponent.textFormat === Text.PlainText ? 1 : editingComponent.textFormat === Text.RichText ? 2 : 3) : 0
            onActivated:  {
                if (editingComponent) {
                    editingComponent.textFormat = currentIndex === 0 ? Text.AutoText : currentIndex === 1 ? Text.PlainText : currentIndex === 2 ? Text.RichText : Text.MarkdownText;
                    editingComponent.saveComToFile();
                }
            }
        }
        UniDeskText{
            id: textWrapMode
            text: qsTr("换行模式")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.verticalCenter: wrapModeComboBox.verticalCenter
            anchors.margins: 10
        }
        UniDeskComboBox{
            id: wrapModeComboBox
            anchors.top: renderFormatComboBox.bottom
            anchors.right: parent.right
            anchors.margins: 10
            comManager: window.comManager
            model: [qsTr("自动换行"), qsTr("不换行"), qsTr("任意位置换行"), qsTr("词边界换行")]
            currentIndex: {
                var idx = 0;
                if (editingComponent) {
                    if (editingComponent.wrapMode === Text.Wrap) idx = 0;
                    else if (editingComponent.wrapMode === Text.NoWrap) idx = 1;
                    else if (editingComponent.wrapMode === Text.WrapAnywhere) idx = 2;
                    else if (editingComponent.wrapMode === Text.WrapAtWordBoundaryOrAnywhere) idx = 3;
                }
                return idx;
            }
            onActivated:  {
                if (editingComponent) {
                    if (currentIndex === 0) editingComponent.wrapMode = Text.Wrap;
                    else if (currentIndex === 1) editingComponent.wrapMode = Text.NoWrap;
                    else if (currentIndex === 2) editingComponent.wrapMode = Text.WrapAnywhere;
                    else if (currentIndex === 3) editingComponent.wrapMode = Text.WrapAtWordBoundaryOrAnywhere;
                    editingComponent.saveComToFile();
                }
            }
        }
        UniDeskText{
            id: textHorizontalAlignment
            text: qsTr("水平对齐")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.verticalCenter: horizontalAlignmentComboBox.verticalCenter
            anchors.margins: 10
        }
        UniDeskComboBox{
            id: horizontalAlignmentComboBox
            anchors.top: wrapModeComboBox.bottom
            anchors.right: parent.right
            anchors.margins: 10
            comManager: window.comManager
            model: [qsTr("左对齐"), qsTr("居中对齐"), qsTr("右对齐")]
            currentIndex: {
                var idx = 1;
                if (editingComponent) {
                    if (editingComponent.horizontalAlignment === Text.AlignLeft) idx = 0;
                    else if (editingComponent.horizontalAlignment === Text.AlignHCenter) idx = 1;
                    else if (editingComponent.horizontalAlignment === Text.AlignRight) idx = 2;
                }
                return idx;
            }
            onActivated:  {
                if (editingComponent) {
                    if (currentIndex === 0) editingComponent.horizontalAlignment = Text.AlignLeft;
                    else if (currentIndex === 1) editingComponent.horizontalAlignment = Text.AlignHCenter;
                    else if (currentIndex === 2) editingComponent.horizontalAlignment = Text.AlignRight;
                    editingComponent.saveComToFile();
                }
            }
        }
        UniDeskText{
            id: textVerticalAlignment
            text: qsTr("垂直对齐")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.verticalCenter: verticalAlignmentComboBox.verticalCenter
            anchors.margins: 10
        }
        UniDeskComboBox{
            id: verticalAlignmentComboBox
            anchors.top: horizontalAlignmentComboBox.bottom
            anchors.right: parent.right
            anchors.margins: 10
            comManager: window.comManager
            model: [qsTr("顶部对齐"), qsTr("居中对齐"), qsTr("底部对齐")]
            currentIndex: {
                var idx = 1;
                if (editingComponent) {
                    if (editingComponent.verticalAlignment === Text.AlignTop) idx = 0;
                    else if (editingComponent.verticalAlignment === Text.AlignVCenter) idx = 1;
                    else if (editingComponent.verticalAlignment === Text.AlignBottom) idx = 2;
                }
                return idx;
            }
            onActivated:  {
                if (editingComponent) {
                    if (currentIndex === 0) editingComponent.verticalAlignment = Text.AlignTop;
                    else if (currentIndex === 1) editingComponent.verticalAlignment = Text.AlignVCenter;
                    else if (currentIndex === 2) editingComponent.verticalAlignment = Text.AlignBottom;
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
    Component.onCompleted: {
        posSelector.refreshPosition();
    }
}
