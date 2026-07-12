// e:\Uniquenium\Uniquenium\UniDesk\Components\UDCFrame\UDCFrame.qml
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
    type: "UDCFrame"
    width: 200
    height: 150
    optionsWindow: optionsFrame
    chosen: optionsFrame ? optionsFrame.visible : false
    
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
    
    UniDeskMenu{
        id: menu
        UniDeskMenuItem{
            text: qsTr("编辑")
            iconSource: "qrc:/media/img/edit.svg"
            onClicked: {
                optionsFrame.show()
            }
        }
        UniDeskMenuItem{
            text: qsTr("复制")
            iconSource: "qrc:/media/img/copy.svg"
            onClicked: {
                base.copyCom();
            }
        }
        UniDeskMenuItem{
            text: qsTr("新建子组件")
            iconSource: "qrc:/media/img/add-line.svg"
            onClicked: {
                base.createSubComponent();
            }
        }
        UniDeskMenuItem{
            text: qsTr("删除")
            iconSource: "qrc:/media/img/delete-bin.svg"
            onClicked: {
                base.deleteCom();
            }
        }
    }
    
    UDCFrameOptions{
        id: optionsFrame
        editingComponent: base
        comManager: base.comManager
    }
    
    onRightClicked: {
        menu.popup(cont);
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
            "borderWidth": base.borderWidth,
            "borderColorR": base.borderColor.r,
            "borderColorG": base.borderColor.g,
            "borderColorB": base.borderColor.b,
            "borderColorA": base.borderColor.a,
            "borderRadius": base.borderRadius,
            "bgColorR": base.backgroundColor.r,
            "bgColorG": base.backgroundColor.g,
            "bgColorB": base.backgroundColor.b,
            "bgColorA": base.backgroundColor.a,
            "opacity": base.itemOpacity,
            "rotation": base.rotation
        }
    }
    
    function loadPropertyData(data){
        if(data.type!==undefined){base.type=data.type;}
        if(data.identification!==undefined){base.identification=data.identification;}       
        if(data.pageid!==undefined){base.pageid=data.pageid;}
        if(data.x!==undefined){base.x=data.x;}
        if(data.y!==undefined){base.y=data.y;}
        if(data.name!==undefined){base.name=data.name;}
        if(data.parent!==undefined){base.parent=base.comManager.getComById(data.parent);}
        if(data.width!==undefined){base.width=data.width;}
        if(data.height!==undefined){base.height=data.height;}
        if(data.borderWidth!==undefined){base.borderWidth=data.borderWidth;}
        if(data.borderColorR!==undefined){base.borderColor=Qt.rgba(data.borderColorR,data.borderColorG,data.borderColorB,data.borderColorA);}
        if(data.borderRadius!==undefined){base.borderRadius=data.borderRadius;}
        if(data.bgColorR!==undefined){base.backgroundColor=Qt.rgba(data.bgColorR,data.bgColorG,data.bgColorB,data.bgColorA);}
        if(data.opacity!==undefined){base.itemOpacity=data.opacity;}else{base.itemOpacity=1;}
        if(data.rotation!==undefined){base.rotation=data.rotation;}
    }
    
    function saveComToFile(){
        var data= propertyData();
        UniDeskComponentsData.updateComponent(base.comManager.getIndexById(base.identification), data);
    }
    
    onCloseSignal: ()=>{
        if(optionsFrame){
            optionsFrame.close();
        }
    }
}