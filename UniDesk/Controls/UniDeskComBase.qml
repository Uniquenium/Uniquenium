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
    signal leftClicked()
    signal rightClicked()
    signal endDrag()
    signal componentCompleted()
    property alias bg: rect_bg
    property alias controlPressed: mouseArea.pressed
    property bool controlHovered
    property string name
    property string type
    property string identification
    property string pageid
    property bool canMove: chosen
    property bool indicated: false
    property bool selected: false
    property bool chosen: false
    property var comManager
    property var optionsWindow
    property int margins: 4
    property int edges: 0
    property bool moving: false
    property bool moved: false
    property real initialMouseX: 0
    property real initialMouseY: 0
    property real initialBaseX: 0
    property real initialBaseY: 0
    property real itemOpacity: 1
    transformOrigin: Item.TopLeft
    Rectangle{
        id: rect_bg
        anchors.fill: parent
        color: "transparent"
    }
    UniDeskTooltip{
        id: indicator_base
        text: base.name
        visible: base.indicated && base.visible
        closePolicy: undefined
    }
    UniDeskComRectEditor{
        id: rect_border
        anchors.fill: parent
        comManager: base.comManager
        editingComponent: base
        z: 32767
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                base.leftClicked();
                if (base.canMove) {
                    base.moving = true;
                }
                base.initialMouseX = UniDeskTools.getCursorPosition().x;
                base.initialMouseY = UniDeskTools.getCursorPosition().y;
                if(base.comManager.selectMode===UniDeskComponentSelectMode.MultiSelect){
                    base.comManager.prepare_multi_move();
                }else{
                    base.initialBaseX = base.x;
                    base.initialBaseY = base.y;
                }
            }
        }

        onReleased: (mouse) => {
            base.edges = 0;
            if (mouse.button === Qt.LeftButton) {
                base.endDrag();
                if(base.comManager.selectMode!==UniDeskComponentSelectMode.NoSelect&&(!base.moved)){
                    base.comManager.select_com(base);
                }
            } else if (mouse.button === Qt.RightButton) {
                base.rightClicked();
            }
            base.moving = false;
            base.moved= false;
            mouseArea.cursorShape = Qt.ArrowCursor;
        }
        
        onPositionChanged: (mouse) => {
            let offsetX=UniDeskTools.getCursorPosition().x - base.initialMouseX;
            let offsetY=UniDeskTools.getCursorPosition().y - base.initialMouseY;
            if (base.moving) {
                base.moved= true;
                mouseArea.cursorShape = Qt.SizeAllCursor;
                if(base.comManager.selectMode===UniDeskComponentSelectMode.MultiSelect){
                    base.comManager.multi_move(offsetX, offsetY);
                }else{
                    base.x = base.initialBaseX + offsetX;
                    base.y = base.initialBaseY + offsetY;
                }
            }
        }
    }
    function deleteCom(){
        comManager.delete_com(base.identification);
    }
    function copyCom(){
        return comManager.copy_com(base);
    }
    function createSubComponent(){
        comManager.parentOfNewCom = base;
        comManager.comWindow.pageid = base.pageid;
        comManager.comWindow.showActivate();
    }
    Connections{
        target: UniDeskGlobals
        function onApplicationQuit() {
            base.closeSignal();
        }
    }
    function containsGlobalPoint(point) {
        return base.contains(base.mapFromGlobal(point))||rect_border.hoverOnAnyButton(point);
    }
    function changeParentWithoutMoving(p){
        // 检查是否跨窗口重新父化
        let currentWindow = base.currentLayer();
        let targetWindow = null;
        if(p===comManager.root.contentItem){
            targetWindow = "Desktop";
        }
        else if(p===comManager.wallpaperLayer.contentItem){
            targetWindow = "Wallpaper";
        }
        else if(p===comManager.topMostLayer.contentItem){
            targetWindow = "TopMost";
        }
        else {
            targetWindow = p.currentLayer();
        }
        // 如果在同一个窗口内，可以直接重新父化
        if(currentWindow && targetWindow && currentWindow === targetWindow){
            let point = p.mapFromItem(base,0,0);
            base.x = point.x;
            base.y = point.y;
            base.parent = p;
        } else {
            let data= base.propertyData();
            let point = p.mapFromItem(base,0,0);
            data["x"] = point.x;
            data["y"] = point.y;
            data["parent"]=comManager.getComId(p)
            UniDeskComponentsData.updateComponent(base.comManager.getIndexById(base.identification), data);
            comManager.loadComponentsFromData();
        }
    }
    function currentLayer(){
        let p=base.parent
        while(p.identification){
            p=p.parent;
        }
        if(p===comManager.root.contentItem){
            return "Desktop";
        }
        else if(p===comManager.wallpaperLayer.contentItem){
            return "Wallpaper";
        }
        else if(p===comManager.topMostLayer.contentItem){
            return "TopMost";
        }
    }
    Component.onCompleted: {
        base.componentCompleted();
    }
    Connections{
        target: comManager.root
        function onMouseMoved(){
            base.controlHovered = base.contains(base.mapFromGlobal(UniDeskTools.getCursorPosition()));
        }
    }
}
