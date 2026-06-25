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
    title: qsTr("图片选项")
    autoVisible: false
    showMinimize: false
    showMaximize: false
    autoDestroy: false
    property var comManager
    property UniDeskComBase editingComponent
    
    ScrollView{
        anchors.fill: parent
        hoverEnabled: true
        contentHeight: mipmapCheckBox.y+mipmapCheckBox.height-text0.y+30
        
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
                        editingComponent.identification = text
                    }
                }
                else{
                    text = editingComponent.identification
                }
                editingComponent.saveComToFile()
            }
        }
        
        UniDeskPosSelector{
            id: posSelector
            anchors.top: idField.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            editingComponent: window.editingComponent
        }
        
        UniDeskText{
            id: textImagePath
            text: qsTr("图片路径")
            font: UniDeskTextStyle.little
            anchors.left: parent.left
            anchors.margins: 10
            anchors.verticalCenter: pathSelector.verticalCenter
        }
        
        UniDeskPathSelector{
            id: pathSelector
            anchors.top: posSelector.bottom
            anchors.left: textImagePath.right
            anchors.right: parent.right
            anchors.margins: 10
            path: editingComponent ? editingComponent.imagePath : ""
            onSubmit: {
                if (editingComponent) {
                    editingComponent.imagePath = path.toString()
                    editingComponent.saveComToFile()
                }
            }
        }
        
        UniDeskSizeSelector{
            id: sizeSelector
            anchors.top: pathSelector.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            editingComponent: window.editingComponent
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
            onCurrentIndexChanged: {
                if (editingComponent) {
                    if (currentIndex === 0) editingComponent.fillMode = Image.Stretch
                    else if (currentIndex === 1) editingComponent.fillMode = Image.PreserveAspectFit
                    else if (currentIndex === 2) editingComponent.fillMode = Image.PreserveAspectCrop
                    else if (currentIndex === 3) editingComponent.fillMode = Image.Tile
                    else if (currentIndex === 4) editingComponent.fillMode = Image.Pad
                    editingComponent.saveComToFile()
                }
            }
            Component.onCompleted: {
                var idx = 0
                if (editingComponent) {
                    if (editingComponent.fillMode === Image.Stretch) idx = 0
                    else if (editingComponent.fillMode === Image.PreserveAspectFit) idx = 1
                    else if (editingComponent.fillMode === Image.PreserveAspectCrop) idx = 2
                    else if (editingComponent.fillMode === Image.Tile) idx = 3
                    else if (editingComponent.fillMode === Image.Pad) idx = 4
                }
                currentIndex = idx
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
            value: editingComponent ? editingComponent.opacity * 100 : 100
            from: 0
            to: 100
            stepSize: 1
            onValueModified: {
                if (editingComponent) {
                    editingComponent.opacity = value / 100
                    editingComponent.saveComToFile()
                }
            }
        }
        
        UniDeskCheckBox{
            id: canMoveCheckBox
            text: qsTr("可拖动")
            anchors.top: opacitySpinBox.bottom
            anchors.left: parent.left
            anchors.margins: 10
            checked: editingComponent ? editingComponent.canMove : true
            onCheckedChanged: {
                if (editingComponent) {
                    editingComponent.canMove = checked
                    editingComponent.saveComToFile()
                }
            }
        }

        UniDeskCheckBox{
            id: canResizeCheckBox
            text: qsTr("可拖拽调整大小")
            anchors.top: canMoveCheckBox.bottom
            anchors.left: parent.left
            anchors.margins: 10
            checked: editingComponent ? editingComponent.canResize : true
            onCheckedChanged: {
                if (editingComponent) {
                    editingComponent.canResize = checked
                    editingComponent.saveComToFile()
                }
            }
        }

        UniDeskCheckBox{
            id: smoothCheckBox
            text: qsTr("平滑")
            anchors.top: canResizeCheckBox.bottom
            anchors.left: parent.left
            anchors.margins: 10
            checked: editingComponent ? editingComponent.smooth : true
            onCheckedChanged: {
                if (editingComponent) {
                    editingComponent.smooth = checked
                    editingComponent.saveComToFile()
                }
            }
        }
        
        UniDeskCheckBox{
            id: mipmapCheckBox
            text: qsTr("Mipmap")
            anchors.top: smoothCheckBox.bottom
            anchors.left: parent.left
            anchors.margins: 10
            checked: editingComponent ? editingComponent.mipmap : false
            onCheckedChanged: {
                if (editingComponent) {
                    editingComponent.mipmap = checked
                    editingComponent.saveComToFile()
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
    
    function updatePosition(){
        posSelector.refreshPosition()
    }
    
    function updateSize(){
        sizeSelector.refreshSize()
    }
    
    Component.onCompleted: {
        updatePosition()
    }
}
