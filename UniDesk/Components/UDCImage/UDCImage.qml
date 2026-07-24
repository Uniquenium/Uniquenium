import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects
import UniDesk
import UniDesk.Controls
import UniDesk.Singletons
import UniDesk.Components.UDCImage

UniDeskComBase{
    id: base
    visible: true
    width: 200
    height: 200
    type: "UDCImage"
    property string imagePath: ""
    property int fillMode: Image.Stretch
    smooth: true
    property bool mipmap: false
    // 圆角功能
    property int radius: 0
    // 按钮功能
    property bool isButton: false
    // 按钮动作类型: UniDeskButtonActionType.ButtonActionApp/ButtonActionWeb/ButtonActionCommand
    property int buttonActionType: UniDeskButtonActionType.ButtonActionApp
    // 按钮动作目标: 应用程序路径/网页URL/命令
    property string buttonActionTarget: ""
    optionsWindow: optionsImage

    chosen: comManager.selectMode===UniDeskComponentSelectMode.NoSelect ? (optionsWindow.visible) : selected
    AnimatedImage{
        id: cont
        source: base.imagePath!=="" ? base.imagePath : "qrc:/media/logo/unidesk-l-bg.png"
        fillMode: base.fillMode
        opacity: base.itemOpacity 
        smooth: base.smooth
        mipmap: base.mipmap
        width: base.width
        height: base.height
        transformOrigin: Item.TopLeft
        playing: status === Image.Ready
        clip: true
        layer.enabled: true
        layer.smooth: true
        layer.effect: OpacityMask{
            maskSource: Rectangle {
                width: cont.width
                height: cont.height
                radius: base.radius
            }
        }
    }
    ColorOverlay{
        id: overlay_image
        anchors.fill: parent
        source: cont
        color: {
            if(base.controlPressed){
                return Qt.rgba(0, 0, 0, 0.3)
            }
            else if (base.controlHovered){
                return Qt.rgba(0, 0, 0, 0.2)
            }
            return "transparent"
        }
        visible: base.isButton && !base.chosen && base.controlHovered
        layer.enabled: true
        layer.smooth: true
        layer.effect: OpacityMask{
            maskSource: Rectangle {
                width: cont.width
                height: cont.height
                radius: base.radius
            }
        }
    }
    UniDeskMenu{
        id: menu
        UniDeskMenuItem{
            text: qsTr("编辑")
            iconSource: "qrc:/media/img/edit.svg"
            onClicked: {
                optionsImage.show()
                base.comManager.select_com(base);
            }
        }
        UniDeskMenuItem{
            text: qsTr("复制")
            iconSource: "qrc:/media/img/copy.svg"
            onClicked: {
                base.copyCom()
            }
        }
        UniDeskMenuItem{
            text: qsTr("新建子组件")
            iconSource: "qrc:/media/img/add-line.svg"
            onClicked: {
                base.createSubComponent()
            }
        }
        UniDeskMenuItem{
            id: mi_delete
            text: qsTr("删除")
            iconSource: "qrc:/media/img/delete-bin.svg"
            onClicked: {
                base.deleteCom()
            }
        }
    }
    
    UDCImageOptions{
        id: optionsImage
        editingComponent: base
        comManager: base.comManager
    }
    
    onRightClicked: {
        if(base.comManager.selectMode===UniDeskComponentSelectMode.NoSelect){
            menu.popup(cont);
        }
    }
    
    // 按钮点击处理 - 使用函数数组消除if判断
    onLeftClicked: {
        if (base.isButton && !base.chosen && !menu.visible) {
            var actionHandlers = [
                function(t) { UniDeskTools.openFileOrDir(t) },
                function(t) { UniDeskTools.web_browse(t) },
                function(t) { UniDeskTools.systemCommand(t) }
            ]
            if (base.buttonActionType >= 0 && base.buttonActionType < actionHandlers.length) {
                actionHandlers[base.buttonActionType](base.buttonActionTarget)
            }
        }
    }
    function propertyData(){
        return {
            "type": base.type,
            "identification": base.identification,
            "pageid": base.pageid,
            "x": base.x,
            "y": base.y,
            "name": base.name,
            "parent": base.parent === comManager.root.contentItem ? "Desktop" : base.parent.identification,
            "width": base.width,
            "height": base.height,
            "imagePath": base.imagePath,
            "fillMode": base.fillMode,
            "opacity": base.itemOpacity,
            "smooth": base.smooth,
            "mipmap": base.mipmap,
            "rotation": base.rotation,
            "radius": base.radius,
            "isButton": base.isButton,
            "buttonActionType": base.buttonActionType,
            "buttonActionTarget": base.buttonActionTarget
        }
    }
    
    function loadPropertyData(data){
        if(data.type!==undefined){base.type=data.type}
        if(data.identification!==undefined){base.identification=data.identification}       
        if(data.pageid!==undefined){base.pageid=data.pageid}
        if(data.name!==undefined){base.name=data.name}
        if(data.parent!==undefined){base.parent = base.comManager.getComById(data.parent)}
        if(data.x!==undefined){base.x=data.x}
        if(data.y!==undefined){base.y=data.y}
        if(data.width!==undefined){base.width=data.width}
        if(data.height!==undefined){base.height=data.height}
        if(data.imagePath!==undefined){base.imagePath=data.imagePath}
        if(data.fillMode!==undefined){base.fillMode=data.fillMode}
        if(data.opacity!==undefined){base.itemOpacity=data.opacity}
        if(data.smooth!==undefined){base.smooth=data.smooth}
        if(data.mipmap!==undefined){base.mipmap=data.mipmap}
        if(data.rotation!==undefined){base.rotation=data.rotation}
        if(data.radius!==undefined){base.radius=data.radius}
        if(data.isButton!==undefined){base.isButton=data.isButton}
        if(data.buttonActionType!==undefined){base.buttonActionType = data.buttonActionType}
        if(data.buttonActionTarget!==undefined){base.buttonActionTarget=data.buttonActionTarget}
    }
    
    function saveComToFile(){
        var data= propertyData()
        UniDeskComponentsData.updateComponent(base.comManager.getIndexById(base.identification), data)
    }
    onCloseSignal: ()=>{
        if(optionsImage){
            optionsImage.close()
        }
    }
}