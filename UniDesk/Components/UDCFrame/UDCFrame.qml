import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk
import UniDesk.Controls
import UniDesk.Singletons
import UniDesk.Components.UDCFrame

UniDeskComBase{
    id: base
    visible: true
    width: 200
    height: 150
    chosen: comManager.selectMode===UniDeskComponentSelectMode.NoSelect ? (optionsWindow.visible) : selected
    // 框架属性
    property int borderWidth: 1
    property color borderColor: UniDeskGlobals.isLight ? Qt.rgba(0, 0, 0, 1) : Qt.rgba(255, 255, 255, 1)
    property int borderRadius: 3
    property color backgroundColor: UniDeskGlobals.isLight ? Qt.rgba(255, 255, 255, 1) : Qt.rgba(0, 0, 0, 1)
    
    Rectangle{
        id: cont
        width: base.width
        height: base.height
        border.width: base.borderWidth
        border.color: base.borderColor
        radius: base.borderRadius
        color: base.backgroundColor
        opacity: base.itemOpacity
    }
    
    optionsWindow: UDCFrameOptions{
        editingComponent: base
        comManager: base.comManager
    }
    
    function propertyDataEx(){
        return {
            "borderWidth": base.borderWidth,
            "borderColorR": base.borderColor.r,
            "borderColorG": base.borderColor.g,
            "borderColorB": base.borderColor.b,
            "borderColorA": base.borderColor.a,
            "borderRadius": base.borderRadius,
            "bgColorR": base.backgroundColor.r,
            "bgColorG": base.backgroundColor.g,
            "bgColorB": base.backgroundColor.b,
            "bgColorA": base.backgroundColor.a
        }
    }
    
    function loadPropertyDataEx(data){
        if(data.borderWidth!==undefined){base.borderWidth=data.borderWidth;}
        if(data.borderColorR!==undefined){base.borderColor=Qt.rgba(data.borderColorR,data.borderColorG,data.borderColorB,data.borderColorA);}
        if(data.borderRadius!==undefined){base.borderRadius=data.borderRadius;}
        if(data.bgColorR!==undefined){base.backgroundColor=Qt.rgba(data.bgColorR,data.bgColorG,data.bgColorB,data.bgColorA);}
    }
    
    
}