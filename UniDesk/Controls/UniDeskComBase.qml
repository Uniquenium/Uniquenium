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
    transformOrigin: Item.TopLeft
    Rectangle{
        id: rect_bg
        anchors.fill: parent
        color: "transparent"
    }
    UniDeskTooltip{
        id: indicator_base
        text: base.identification
        visible: base.indicated && base.visible
        closePolicy: undefined
    }
    UniDeskComRectEditor{
        id: rect_border
        anchors.fill: parent
        comManager: base.comManager
        editingComponent: base
        z: 32766
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
        // UniDeskUtils.deleteLater(base); //this may cause the whole process terminated
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
}
