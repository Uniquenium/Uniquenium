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
    title: qsTr("图片/按钮选项")
    autoVisible: false
    showMinimize: false
    showMaximize: false
    autoDestroy: false
    property var comManager
    property UniDeskComBase editingComponent
    property UniDeskComBase ec: editingComponent
    
    ScrollView{
        anchors.fill: parent
        hoverEnabled: true
        contentHeight: buttonActionTargetField.y+buttonActionTargetField.height-basicOptions.y+30
        
        UniDeskComBasicOptions{
            id: basicOptions
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 10
            comManager: window.comManager
            editingComponent: window.editingComponent
        }
        
        UniDeskText{
            id: textImagePath
            text: qsTr("图片地址（支持网络图片）")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.margins: 10
            anchors.verticalCenter: pathSelector.verticalCenter
        }
        
        UniDeskPathSelector{
            id: pathSelector
            anchors.top: basicOptions.bottom
            anchors.left: textImagePath.right
            anchors.right: parent.right
            anchors.margins: 10
            path: window.ec ? window.ec.imagePath : ""
            parentWindow: window
            onSubmit: {
                if (window.ec) {
                    window.ec.imagePath = path
                    window.ec.saveComToFile()
                }
            }
        }
        
        
        UniDeskText{
            id: textFillMode
            text: qsTr("填充模式")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.margins: 10
            anchors.verticalCenter: fillModeComboBox.verticalCenter
        }
        
        UniDeskComboBox{
            id: fillModeComboBox
            anchors.top: pathSelector.bottom
            anchors.right: parent.right
            anchors.margins: 10
            model: [qsTr("拉伸"), qsTr("保持比例适应"), qsTr("保持比例裁剪"), qsTr("平铺"), qsTr("保持比例填充")]
            currentIndex: window.ec ? [Image.Stretch, Image.PreserveAspectFit, Image.PreserveAspectCrop, Image.Tile, Image.Pad].indexOf(window.ec.fillMode) : 0
            onActivated:  {
                if (window.ec) {
                    window.ec.fillMode = [Image.Stretch, Image.PreserveAspectFit, Image.PreserveAspectCrop, Image.Tile, Image.Pad][currentIndex]
                    window.ec.saveComToFile()
                }
            }
        }
        UniDeskCheckBox{
            id: smoothCheckBox
            text: qsTr("平滑")
            anchors.top: fillModeComboBox.bottom
            anchors.left: parent.left
            anchors.margins: 10
            checked: window.ec ? window.ec.smooth : true
            onCheckedChanged: {
                if (window.ec) {
                    window.ec.smooth = checked
                    window.ec.saveComToFile()
                }
            }
        }
        
        UniDeskCheckBox{
            id: mipmapCheckBox
            text: qsTr("Mipmap")
            anchors.top: smoothCheckBox.bottom
            anchors.left: parent.left
            anchors.margins: 10
            checked: window.ec ? window.ec.mipmap : false
            onCheckedChanged: {
                if (window.ec) {
                    window.ec.mipmap = checked
                    window.ec.saveComToFile()
                }
            }
        }
        
        // 圆角选项
        UniDeskText{
            id: textRadius
            text: qsTr("圆角半径")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.margins: 10
            anchors.verticalCenter: radiusSpinBox.verticalCenter
        }
        UniDeskSpinBox{
            id: radiusSpinBox
            anchors.top: mipmapCheckBox.bottom
            anchors.right: parent.right
            anchors.margins: 10
            editable: true
            value: window.ec ? window.ec.radius : 0
            from: 0
            to: Math.min(editingComponent.width, editingComponent.height) / 2
            stepSize: 1
            onValueModified: {
                if (window.ec) {
                    window.ec.radius = value;
                    window.ec.saveComToFile();
                }
            }
        }
        
        // 按钮模式选项
        UniDeskCheckBox{
            id: isButtonCheckBox
            text: qsTr("按钮模式")
            anchors.top: radiusSpinBox.bottom
            anchors.left: parent.left
            anchors.margins: 10
            checked: window.ec ? window.ec.isButton : false
            onCheckedChanged: {
                if (window.ec) {
                    window.ec.isButton = checked
                    window.ec.saveComToFile()
                }
            }
        }
        
        // 按钮动作类型
        UniDeskText{
            id: textButtonActionType
            text: qsTr("点击动作")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.margins: 10
            anchors.verticalCenter: buttonActionTypeComboBox.verticalCenter
            visible: isButtonCheckBox.checked
        }
        UniDeskComboBox{
            id: buttonActionTypeComboBox
            anchors.top: isButtonCheckBox.bottom
            anchors.right: parent.right
            anchors.margins: 10
            model: [qsTr("打开应用程序"), qsTr("打开网页"), qsTr("运行命令")]
            currentIndex: window.ec ? window.ec.buttonActionType : UniDeskButtonActionType.ButtonActionApp
            visible: isButtonCheckBox.checked
            onActivated: {
                if (window.ec) {
                    window.ec.buttonActionType = currentIndex
                    window.ec.buttonActionTarget = ""
                    window.ec.saveComToFile()
                }
            }
        }
        // 按钮动作目标
        UniDeskText{
            id: textButtonActionTarget
            text: [qsTr("应用程序路径"), qsTr("网页地址"), qsTr("命令")][buttonActionTypeComboBox.currentIndex]
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.margins: 10
            anchors.verticalCenter: buttonActionTargetField.verticalCenter
            visible: isButtonCheckBox.checked
        }
        UniDeskTextField{
            id: buttonActionTargetField
            anchors.top: buttonActionTypeComboBox.bottom
            anchors.right: parent.right
            anchors.margins: 10
            anchors.left: textButtonActionTarget.right
            placeholderText: [qsTr("请输入应用程序路径"), qsTr("请输入网页地址"), qsTr("请输入命令")][buttonActionTypeComboBox.currentIndex]
            text: window.ec ? window.ec.buttonActionTarget : ""
            visible: isButtonCheckBox.checked
            onEditingFinished: {
                if (window.ec) {
                    window.ec.buttonActionTarget = text
                    window.ec.saveComToFile()
                }
            }
        }
    }
}
