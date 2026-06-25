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
    geoWidth: cont.width ? cont.width : 200
    geoHeight: cont.height ? cont.height : 200
    type: "UDCImage"
    property string imagePath: ""
    property int fillMode: Image.Stretch
    property bool smooth: true
    property bool mipmap: false
    optionsWindow: optionsImage
    chosen: optionsImage ? optionsImage.visible : false
    
    Image{
        id: cont
        x: base.rotationOffsetX()
        y: base.rotationOffsetY()
        source: base.imagePath ? base.imagePath : "qrc:/media/logo/unidesk-l-bg.png"
        fillMode: base.fillMode
        opacity: base.opacity
        smooth: base.smooth
        mipmap: base.mipmap
        rotation: base.rotation
        width: base.geoWidth
        height: base.geoHeight
        transformOrigin: Item.TopLeft
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
            id: mi_drag
            text: qsTr("可拖动")
            iconSource: "qrc:/media/img/move.svg"
            checkable: true
            onClicked: {
                base.canMove=checked
                checked=!checked
                base.saveComToFile()
                menu.close()
            }
            Component.onCompleted: {
                checked=base.canMove
            }
            Connections{
                target: base
                function onCanMoveChanged(){
                    mi_drag.checked=base.canMove
                }
            }
        }
        UniDeskMenuItem{
            id: mi_resize
            text: qsTr("可拖拽调整大小")
            iconSource: "qrc:/media/img/resize.svg"
            checkable: true
            onClicked: {
                base.canResize=checked
                checked=!checked
                base.saveComToFile()
                menu.close()
            }
            Component.onCompleted: {
                checked=base.canResize
            }
            Connections{
                target: base
                function onCanResizeChanged(){
                    mi_resize.checked=base.canResize
                }
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
        geoX=x+rotationOffsetX()
        geoY=y+rotationOffsetY()
        //前提： 旋转被禁用
        geoWidth=width
        geoHeight=height
        //
        optionsImage.updatePosition()
        optionsImage.updateSize()
        saveComToFile()
    }
    
    onGeoXChanged:{
        optionsImage.updatePosition()
    }
    
    onGeoYChanged:{
        optionsImage.updatePosition()
    }
    
    onGeoWidthChanged:{
        optionsImage.updateSize()
    }
    
    onGeoHeightChanged:{
        optionsImage.updateSize()
    }
    
    function propertyData(){
        return {
            "type": base.type,
            "identification": base.identification,
            "pageid": base.pageid,
            "x": base.geoX,
            "y": base.geoY,
            "width": base.geoWidth,
            "height": base.geoHeight,
            "canMove": base.canMove,
            "canResize": base.canResize,
            "imagePath": base.imagePath,
            "fillMode": base.fillMode,
            "opacity": base.opacity,
            "smooth": base.smooth,
            "mipmap": base.mipmap,
            "rotation": base.rotation
        }
    }
    
    function loadPropertyData(data){
        if(data.type!==undefined){base.type=data.type}
        if(data.identification!==undefined){base.identification=data.identification}       
        if(data.pageid!==undefined){base.pageid=data.pageid}
        if(data.x!==undefined){base.geoX=data.x}
        if(data.y!==undefined){base.geoY=data.y}
        if(data.width!==undefined){base.geoWidth=data.width}
        if(data.height!==undefined){base.geoHeight=data.height}
        if(data.canMove!==undefined){base.canMove=data.canMove}
        if(data.canResize!==undefined){base.canResize=data.canResize}
        if(data.imagePath!==undefined){base.imagePath=data.imagePath}
        if(data.fillMode!==undefined){base.fillMode=data.fillMode}
        if(data.opacity!==undefined){base.opacity=data.opacity}
        if(data.smooth!==undefined){base.smooth=data.smooth}
        if(data.mipmap!==undefined){base.mipmap=data.mipmap}
        if(data.rotation!==undefined){base.rotation=data.rotation}
    }
    
    function saveComToFile(){
        var data= propertyData()
        UniDeskComponentsData.updateComponent(base.comManager.getIndexById(base.identification), data)
    }
    
    Component.onCompleted:{
        optionsImage.updateSize()
    }
    
    onCloseSignal: ()=>{
        if(optionsImage){
            optionsImage.close()
        }
    }
}