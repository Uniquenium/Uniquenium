import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk.Controls
import UniDesk.Singletons
import UniDesk

Item{
    id: base
    signal closeSignal()
    signal focusOut()
    signal rightClicked()
    signal endDrag()
    property alias bg: rect_bg
    property string type
    property string identification
    property int pageid
    property bool canMove: false
    property bool canResize: false
    property bool indicated: false
    property bool chosen: false
    property bool subComponentable: false
    property real rotation: 0
    property real geoX: 0
    property real geoY: 0
    property real geoWidth: 0
    property real geoHeight: 0
    property var comManager
    property var optionsWindow
    property int margins: 4
    property int edges: 0
    property bool moving: false
    property bool resizing: false
    property real initialMouseX: 0
    property real initialMouseY: 0
    property real initialBaseX: 0
    property real initialBaseY: 0
    property real initialBaseWidth: 0
    property real initialBaseHeight: 0
    width: rotatedWidth()
    height: rotatedHeight()
    Rectangle{
        id: rect_bg
        anchors.fill: parent
        color: "transparent"
    }
    Rectangle{
        id: rect_border
        anchors.fill: parent
        color: "transparent"
        border.width: base.chosen ? 1: 0
        border.color: UniDeskSettings.primaryColor
        z: 32766
    }
    Item{
        id: indicator_base
        x: base.x
        y: base.y-height >=0 ? base.y-height : base.y+base.height
        width: id_text.width
        height: id_text.height
        visible: base.indicated && base.visible
        Rectangle{
            width: id_text.width
            height: id_text.height
            color: UniDeskSettings.primaryColor
            z: 32767
            UniDeskText{
                id: id_text
                font: UniDeskTextStyle.little
                text: base.identification
            }
        }
    }
    // MouseArea {
    //     id: mouseArea
    //     anchors.fill: parent
    //     hoverEnabled: true
    //     acceptedButtons: Qt.LeftButton | Qt.RightButton
    //     onPressed: (mouse) => {
    //         if (mouse.button === Qt.LeftButton) {
    //             if (base.edges !== 0 && base.canResize) {
    //                 base.resizing = true;
    //             } else if (base.canMove) {
    //                 base.moving = true;
    //                 mouseArea.cursorShape = Qt.SizeAllCursor;
    //             }
    //             base.initialMouseX = mouse.x;
    //             base.initialMouseY = mouse.y;
    //             base.initialBaseX = base.geoX;
    //             base.initialBaseY = base.geoY;
    //             base.initialBaseWidth = base.geoWidth;
    //             base.initialBaseHeight = base.geoHeight;
    //         }
    //     }

    //     onReleased: (mouse) => {
    //         base.edges = 0;
    //         updateCursor();
    //         if (mouse.button === Qt.LeftButton) {
    //             base.endDrag();
    //         } else if (mouse.button === Qt.RightButton) {
    //             base.rightClicked();
    //         }
    //         base.moving = false;
    //         base.resizing = false;
    //     }
        
    //     onPositionChanged: (mouse) => {
    //         updateCursor();
    //         let offsetX=mouse.x - base.initialMouseX;
    //         let offsetY=mouse.y - base.initialMouseY;
    //         if (base.moving) {
    //             base.geoX = base.initialBaseX + offsetX;
    //             base.geoY = base.initialBaseY + offsetY;
    //         } else if (base.resizing) {
    //             if(base.edges & Qt.LeftEdge){
    //                 base.geoX = base.initialBaseX + offsetX;
    //                 base.geoWidth = base.initialBaseWidth - offsetX;
    //             }
    //             if(base.edges & Qt.RightEdge){
    //                 base.geoWidth = base.initialBaseWidth + offsetX;
    //             }
    //             if(base.edges & Qt.TopEdge){
    //                 base.geoY = base.initialBaseY + offsetY;
    //                 base.geoHeight = base.initialBaseHeight - offsetY;
    //             }
    //             if(base.edges & Qt.BottomEdge){
    //                 base.geoHeight = base.initialBaseHeight + offsetY;
    //             }
    //         }
    //         else{
    //             base.edges = 0;
    //             if(mouse.x<base.margins){
    //                 base.edges |= Qt.LeftEdge;
    //             }
    //             if(mouse.x>base.width-base.margins){
    //                 base.edges |= Qt.RightEdge;
    //             }
    //             if(mouse.y<base.margins){
    //                 base.edges |= Qt.TopEdge;
    //             }
    //             if(mouse.y>base.height-base.margins){
    //                 base.edges |= Qt.BottomEdge;
    //             }
    //         }
    //     }
    // }
    function updateCursor() {
        if (base.edges === 0) {
            comManager.root.setCursorShape(Qt.ArrowCursor);
        } else if (base.canResize) {
            if (base.edges === Qt.LeftEdge || base.edges === Qt.RightEdge) {
                comManager.root.setCursorShape(Qt.SizeHorCursor);
            } else if (base.edges === Qt.TopEdge || base.edges === Qt.BottomEdge) {
                comManager.root.setCursorShape(Qt.SizeVerCursor);
            } else if (base.edges === (Qt.LeftEdge | Qt.TopEdge) || base.edges === (Qt.RightEdge | Qt.BottomEdge)) {
                comManager.root.setCursorShape(Qt.SizeFDiagCursor);
            } else if (base.edges === (Qt.RightEdge | Qt.TopEdge) || base.edges === (Qt.LeftEdge | Qt.BottomEdge)) {
                comManager.root.setCursorShape(Qt.SizeBDiagCursor);
            }
        } else {
            comManager.root.setCursorShape(Qt.ArrowCursor);
        }
    }
    function deleteCom(){
        UniDeskComponentsData.removeComponent(base.identification);
        comManager.component_list.splice(comManager.getIndexById(base.identification),1);
        var pidx=comManager.pid2pindex(base.pageid)
        for(var i=0;i<comManager.compModels.get(pidx).value.count;i++){
            if(comManager.compModels.get(pidx).value.get(i).display===base.identification){
                comManager.compModels.get(pidx).value.remove(i);
            }
        }
        base.closeSignal();
        base.visible=false;
        // base.destroy();  //this may cause the whole process terminated
    }
    function rotatedWidth(){
        return Math.abs(Math.cos(base.rotation*Math.PI/180)*base.geoWidth)+Math.abs(Math.sin(base.rotation*Math.PI/180)*base.geoHeight);
    }
    function rotatedHeight(){
        return Math.abs(Math.sin(base.rotation*Math.PI/180)*base.geoWidth)+Math.abs(Math.cos(base.rotation*Math.PI/180)*base.geoHeight);
    }
    function rotationOffsetX(){
        if(0<=base.rotation && base.rotation<90){
            return base.geoHeight*Math.sin(base.rotation*Math.PI/180);
        }
        else if(90<=base.rotation && base.rotation<180){
            return rotatedWidth();
        }
        else if(180<=base.rotation && base.rotation<270){
            return -base.geoWidth*Math.cos(base.rotation*Math.PI/180);
        }
        else if(270<=base.rotation && base.rotation<=360){
            return 0;
        }
    }
    function rotationOffsetY(){
        if(0<=base.rotation && base.rotation<90){
            return 0;
        }
        else if(90<=base.rotation && base.rotation<180){
            return -base.geoHeight*Math.cos(base.rotation*Math.PI/180);
        }
        else if(180<=base.rotation && base.rotation<270){
            return rotatedHeight();
        }
        else if(270<=base.rotation && base.rotation<=360){
            return -base.geoWidth*Math.sin(base.rotation*Math.PI/180);
        }
    }
    onRotationChanged:{
        x=geoX-rotationOffsetX();
        y=geoY-rotationOffsetY();
        width=rotatedWidth();
        height=rotatedHeight();
    }
    onGeoXChanged:{
        x=geoX-rotationOffsetX();
    }
    onGeoYChanged:{
        y=geoY-rotationOffsetY();
    }
    onGeoWidthChanged:{
        x=geoX-rotationOffsetX();
        y=geoY-rotationOffsetY();
        width=rotatedWidth();
        height=rotatedHeight();
    }
    onGeoHeightChanged:{
        x=geoX-rotationOffsetX();
        y=geoY-rotationOffsetY();
        width=rotatedWidth();
        height=rotatedHeight();
    }
    Connections{
        target: UniDeskGlobals
        function onApplicationQuit() {
            base.closeSignal();
        }
    }
    function containsGlobalPoint(point) {
        var pos = base.mapToGlobal(0, 0)
        var rect = Qt.rect(pos.x, pos.y, base.width, base.height)
        if (point.x > rect.x && point.x < (rect.x + rect.width)
                && point.y > rect.y && point.y < (rect.y + rect.height)) {
            return true
        }
        return false
    }
    // Connections{
    //     target: comManager.root
    //     function onMouseMoved(point){
    //         updateCursor();
    //         let offsetX=point.x-base.mouseX;
    //         let offsetY=point.y-base.mouseY;
    //         if(base.moving){
    //             base.x+=offsetX;
    //             base.y+=offsetY;
    //         }
    //         else if(base.resizing){
    //             if(base.edges & Qt.LeftEdge){
    //                 base.x-=offsetX;
    //                 base.width+=offsetX;
    //             }
    //             if(base.edges & Qt.TopEdge){
    //                 base.y-=offsetY;
    //                 base.height+=offsetY;
    //             }
    //             if(base.edges & Qt.RightEdge){
    //                 base.width+=offsetX;
    //             }
    //             if(base.edges & Qt.BottomEdge){
    //                 base.height+=offsetY;
    //             }
    //         }
    //     }
    // }
}
