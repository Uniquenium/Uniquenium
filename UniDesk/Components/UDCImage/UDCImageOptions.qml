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
        contentHeight: buttonActionTargetField.y+buttonActionTargetField.height-text0.y+30
        
        UniDeskText{
            id: text0
            text: qsTr("组件名称")
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
            text: window.ec ? window.ec.name : ""
            onEditingFinished: {
                if (window.ec) {
                    window.ec.name = text
                }
                window.ec.saveComToFile()
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
            anchors.top: parentComboBox.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            editingComponent: window.ec
        }

        UniDeskText{
            id: textRotation
            text: qsTr("旋转角度")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.verticalCenter: rotationSpinBox.verticalCenter
            anchors.margins: 10
        }
        UniDeskSpinBox{
            id: rotationSpinBox
            anchors.top: posSelector.bottom
            anchors.right: parent.right
            anchors.margins: 10
            editable: true
            value: window.ec ? window.ec.rotation : 0
            from: 0
            to: 359
            stepSize: 1
            onValueModified: {
                if (window.ec) {
                    window.ec.rotation = value;
                    window.ec.saveComToFile();
                }
            }
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
            anchors.top: rotationSpinBox.bottom
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
        
        UniDeskSizeSelector{
            id: sizeSelector
            anchors.top: pathSelector.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            editingComponent: window.ec
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
            anchors.top: sizeSelector.bottom
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
            onModelChanged: {
                currentIndex = [Image.Stretch, Image.PreserveAspectFit, Image.PreserveAspectCrop, Image.Tile, Image.Pad].indexOf(window.ec.fillMode)
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
            anchors.top: fillModeComboBox.bottom
            anchors.right: parent.right
            anchors.margins: 10
            editable: true
            value: window.ec ? window.ec.itemOpacity * 100 : 100
            from: 0
            to: 100
            stepSize: 1
            onValueModified: {
                if (window.ec) {
                    window.ec.itemOpacity = value / 100
                    window.ec.saveComToFile()
                }
            }
        }
        
        

        UniDeskCheckBox{
            id: smoothCheckBox
            text: qsTr("平滑")
            anchors.top: opacitySpinBox.bottom
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
            onModelChanged: {
                currentIndex = window.ec ? window.ec.buttonActionType : UniDeskButtonActionType.ButtonActionApp
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
    
    Connections{
        target: UniDeskGlobals
        function onApplicationQuit() {
            window.close()
        }
    }
    Component.onCompleted: {
        posSelector.refreshPosition();
    }
}
