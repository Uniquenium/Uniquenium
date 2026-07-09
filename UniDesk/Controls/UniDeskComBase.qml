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
    property string name
    property string type
    property int identification
    property int pageid
    property bool canMove: chosen
    property bool indicated: false
    property bool chosen: false
    property var comManager
    property var optionsWindow
    property int margins: 4
    property int edges: 0
    property bool moving: false
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
                if (base.canMove) {
                    base.moving = true;
                    mouseArea.cursorShape = Qt.SizeAllCursor;
                }
                base.initialMouseX = UniDeskTools.getCursorPosition().x;
                base.initialMouseY = UniDeskTools.getCursorPosition().y;
                base.initialBaseX = base.x;
                base.initialBaseY = base.y;
            }
        }

        onReleased: (mouse) => {
            mouseArea.cursorShape = Qt.ArrowCursor;
            base.edges = 0;
            if (mouse.button === Qt.LeftButton) {
                base.endDrag();
            } else if (mouse.button === Qt.RightButton) {
                base.rightClicked();
            }
            base.moving = false;
        }
        
        onPositionChanged: (mouse) => {
            let offsetX=UniDeskTools.getCursorPosition().x - base.initialMouseX;
            let offsetY=UniDeskTools.getCursorPosition().y - base.initialMouseY;
            if (base.moving) {
                base.x = base.initialBaseX + offsetX;
                base.y = base.initialBaseY + offsetY;
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
        let point = p.mapFromItem(base,0,0);
        base.x = point.x;
        base.y = point.y;
        base.parent = p;
    }
}
