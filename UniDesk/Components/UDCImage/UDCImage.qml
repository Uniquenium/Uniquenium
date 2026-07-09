import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
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
    optionsWindow: optionsImage
    chosen: optionsImage ? optionsImage.visible : false
    AnimatedImage{
        id: cont
        source: base.imagePath ? base.imagePath : "qrc:/media/logo/unidesk-l-bg.png"
        fillMode: base.fillMode
        opacity: base.itemOpacity
        smooth: base.smooth
        mipmap: base.mipmap
        width: base.width
        height: base.height
        transformOrigin: Item.TopLeft
        playing: status === AnimatedImage.Ready
    }
    UniDeskMenu{
        id: menu
        UniDeskMenuItem{
            text: qsTr("编辑")
            iconSource: "qrc:/media/img/edit.svg"
            onClicked: {
                optionsImage.show()
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
        menu.popup(cont)
    }
    
    onEndDrag: {
        optionsImage.updatePosition()
        optionsImage.updateSize()
        saveComToFile()
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
            "rotation": base.rotation
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
    }
    
    function saveComToFile(){
        var data= propertyData()
        UniDeskComponentsData.updateComponent(base.comManager.getIndexById(base.identification), data)
    }
    
    Component.onCompleted:{
        optionsImage.updatePosition()
        optionsImage.updateSize()
    }
    onXChanged: ()=>{
        optionsImage.updatePosition();
    }
    onYChanged: ()=>{
        optionsImage.updatePosition();
    }
    onWidthChanged: {
        optionsImage.updateSize();
    }
    onHeightChanged: {
        optionsImage.updateSize();
    }
    onCloseSignal: ()=>{
        if(optionsImage){
            optionsImage.close()
        }
    }
}