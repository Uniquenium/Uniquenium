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
    
    optionsWindow: UDCImageOptions{
        editingComponent: base
        comManager: base.comManager
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
    function propertyDataEx(){
        return {
            "imagePath": base.imagePath,
            "fillMode": base.fillMode,
            "smooth": base.smooth,
            "mipmap": base.mipmap,
            "radius": base.radius,
            "isButton": base.isButton,
            "buttonActionType": base.buttonActionType,
            "buttonActionTarget": base.buttonActionTarget
        }
    }
    
    function loadPropertyDataEx(data){
        if(data.imagePath!==undefined){base.imagePath=data.imagePath}
        if(data.fillMode!==undefined){base.fillMode=data.fillMode}
        if(data.smooth!==undefined){base.smooth=data.smooth}
        if(data.mipmap!==undefined){base.mipmap=data.mipmap}
        if(data.radius!==undefined){base.radius=data.radius}
        if(data.isButton!==undefined){base.isButton=data.isButton}
        if(data.buttonActionType!==undefined){base.buttonActionType = data.buttonActionType}
        if(data.buttonActionTarget!==undefined){base.buttonActionTarget=data.buttonActionTarget}
    }
    
}