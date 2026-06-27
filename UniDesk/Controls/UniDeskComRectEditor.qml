// the editor to edit the width,height,rotation of a component by mouse drag easily
import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk.Controls
import UniDesk.Singletons
import UniDesk
import Qt.labs.platform as QLP

Item{
    id: control
    property var comManager
    property Item editingComponent
    visible: editingComponent.chosen
    property real initialBaseRotation: 0
    property real initialBaseWidth: 0
    property real initialBaseHeight: 0
    property point initialBaseCenter: Qt.point(0,0)
    property point initialBaseTopLeft: Qt.point(0,0)
    property real initialMouseX: 0
    property real initialMouseY: 0
    property bool isRotating: false
    property bool isDraggingTopLeftCorner: false
    property bool isDraggingTopSide: false
    property bool isDraggingRightSide: false
    property bool isDraggingBottomSide: false
    property bool isDraggingLeftSide: false
    Rectangle{
        id: rect
        color: "transparent"
        border.width: 2
        border.color: UniDeskSettings.primaryColor
        anchors.fill: parent
        
    }
    Rectangle{
        id: rect_connection
        color: UniDeskSettings.primaryColor
        width: rect.border.width
        border.width: 1
        border.color: UniDeskSettings.primaryColor
        height: 30
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.margins: -height
    }
    UniDeskButton{
        id: btn_topleft
        anchors.left: parent.left
        anchors.top: parent.top
        width: 10
        height: width
        anchors.margins: -width/2 + rect.border.width/2
        radius: width/2
        borderWidth: 1
        bgNormalColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,1) : Qt.rgba(0,0,0,1)
        borderColor: UniDeskSettings.primaryColor
        onPressed: {
            control.isDraggingTopLeftCorner = true
            control.recordInitialState()
        }
    }
    UniDeskButton{
        id: btn_top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: 10
        height: width
        anchors.margins: -width/2 + rect.border.width/2
        radius: width/2
        borderWidth: 1
        bgNormalColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,1) : Qt.rgba(0,0,0,1)
        borderColor: UniDeskSettings.primaryColor
        onPressed: {
            control.isDraggingTopSide = true
            control.recordInitialState()
        }
    }
    UniDeskButton{
        id: btn_topright
        anchors.right: parent.right
        anchors.top: parent.top
        width: 10
        height: width
        anchors.margins: -width/2 + rect.border.width/2
        radius: width/2
        borderWidth: 1
        bgNormalColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,1) : Qt.rgba(0,0,0,1)
        borderColor: UniDeskSettings.primaryColor
        onPressed: {
            control.isDraggingTopSide = true
            control.isDraggingRightSide = true
            control.recordInitialState()
        }
    }
    UniDeskButton{
        id: btn_left
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        height: width
        anchors.margins: -width/2 + rect.border.width/2
        radius: width/2
        borderWidth: 1
        bgNormalColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,1) : Qt.rgba(0,0,0,1)
        borderColor: UniDeskSettings.primaryColor
        onPressed: {
            control.isDraggingLeftSide = true
            control.recordInitialState()
        }
    }
    UniDeskButton{
        id: btn_right
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        height: width
        anchors.margins: -width/2 + rect.border.width/2
        radius: width/2
        borderWidth: 1
        bgNormalColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,1) : Qt.rgba(0,0,0,1)
        borderColor: UniDeskSettings.primaryColor
        onPressed: {
            control.isDraggingRightSide = true
            control.recordInitialState()
        }
    }
    UniDeskButton{
        id: btn_bottomleft
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: 10
        height: width
        anchors.margins: -width/2 + rect.border.width/2
        radius: width/2
        borderWidth: 1
        bgNormalColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,1) : Qt.rgba(0,0,0,1)
        borderColor: UniDeskSettings.primaryColor
        onPressed: {
            control.isDraggingBottomSide = true
            control.isDraggingLeftSide = true
            control.recordInitialState()
        }
    }
    UniDeskButton{
        id: btn_bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        width: 10
        height: width
        anchors.margins: -width/2 + rect.border.width/2
        radius: width/2
        borderWidth: 1
        bgNormalColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,1) : Qt.rgba(0,0,0,1)
        borderColor: UniDeskSettings.primaryColor
        onPressed: {
            control.isDraggingBottomSide = true
            control.recordInitialState()
        }
    }
    UniDeskButton{
        id: btn_bottomright
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: 10
        height: width
        anchors.margins: -width/2 + rect.border.width/2
        radius: width/2
        borderWidth: 1
        bgNormalColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,1) : Qt.rgba(0,0,0,1)
        borderColor: UniDeskSettings.primaryColor
        onPressed: {
            control.isDraggingBottomSide = true
            control.isDraggingRightSide = true
            control.recordInitialState()
        }
    }
    UniDeskButton{
        id: btn_rotate
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: 10
        height: width
        anchors.margins: -rect_connection.height-rect.border.width/2
        radius: width/2
        borderWidth: 1
        bgNormalColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,1) : Qt.rgba(0,0,0,1)
        borderColor: UniDeskSettings.primaryColor
        onPressed:{
            control.isRotating = true
            control.recordInitialState()
        }
    }
    function hoverOnAnyButton(pos){      
        if(btn_topleft.contains(btn_topleft.mapFromGlobal(pos))){
            return true;
        }
        if(btn_top.contains(btn_top.mapFromGlobal(pos))){
            return true;
        }
        if(btn_topright.contains(btn_topright.mapFromGlobal(pos))){
            return true;
        }
        if(btn_left.contains(btn_left.mapFromGlobal(pos))){
            return true;
        }
        if(btn_right.contains(btn_right.mapFromGlobal(pos))){
            return true;
        }
        if(btn_bottomleft.contains(btn_bottomleft.mapFromGlobal(pos))){
            return true;
        }
        if(btn_bottom.contains(btn_bottom.mapFromGlobal(pos))){
            return true;
        }
        if(btn_bottomright.contains(btn_bottomright.mapFromGlobal(pos))){
            return true;
        }
        if(btn_rotate.contains(btn_rotate.mapFromGlobal(pos))){
            return true;
        }
        return false;
    }
    function recordInitialState(){
        initialBaseRotation = editingComponent.rotation
        initialBaseWidth = editingComponent.width
        initialBaseHeight = editingComponent.height
        initialBaseCenter = editingComponent.mapToGlobal(Qt.point(editingComponent.width/2, editingComponent.height/2))
        initialBaseTopLeft = editingComponent.mapToGlobal(Qt.point(0, 0))
        initialMouseX = UniDeskTools.getCursorPosition().x
        initialMouseY = UniDeskTools.getCursorPosition().y
    }
    Connections{
        target: control.comManager.root
        function onMouseMoved(pos){
            if(control.comManager.root.isMousePressed && control.visible && control.isRotating){
                let offsetRotation = Math.atan2(UniDeskTools.getCursorPosition().y-editingComponent.y, UniDeskTools.getCursorPosition().x-editingComponent.x) * 180 / Math.PI - 
                Math.atan2(initialMouseY-editingComponent.y, initialMouseX-editingComponent.x) * 180 / Math.PI
                editingComponent.rotation = (initialBaseRotation + offsetRotation + 360) % 360
                editingComponent.saveComToFile()
            }
            if(control.comManager.root.isMousePressed && control.visible && control.isDraggingTopLeftCorner){
                let offsetMouseX = UniDeskTools.getCursorPosition().x - initialMouseX
                let offsetMouseY = UniDeskTools.getCursorPosition().y - initialMouseY
                let offsetWidth = offsetMouseX* Math.cos(editingComponent.rotation * Math.PI / 180) 
                        + offsetMouseY* Math.sin(editingComponent.rotation * Math.PI / 180)
                offsetWidth=Math.min(offsetWidth, initialBaseWidth)
                let offsetHeight = offsetMouseX* Math.sin(editingComponent.rotation * Math.PI / 180) 
                        - offsetMouseY* Math.cos(editingComponent.rotation * Math.PI / 180)
                offsetHeight=Math.max(offsetHeight, -initialBaseHeight) 
                offsetMouseX=offsetWidth*Math.cos(editingComponent.rotation * Math.PI / 180)
                        + offsetHeight*Math.sin(editingComponent.rotation * Math.PI / 180)
                offsetMouseY=offsetWidth*Math.sin(editingComponent.rotation * Math.PI / 180)
                        - offsetHeight*Math.cos(editingComponent.rotation * Math.PI / 180)
                editingComponent.x =  initialBaseTopLeft.x + offsetMouseX
                editingComponent.y =  initialBaseTopLeft.y + offsetMouseY
                editingComponent.width = initialBaseWidth - offsetWidth
                editingComponent.height = initialBaseHeight + offsetHeight
                editingComponent.saveComToFile()
            }
            if(control.comManager.root.isMousePressed && control.visible && control.isDraggingTopSide){
                let offsetMouseX = UniDeskTools.getCursorPosition().x - initialMouseX
                let offsetMouseY = UniDeskTools.getCursorPosition().y - initialMouseY
                let offset = offsetMouseX* Math.sin(editingComponent.rotation * Math.PI / 180) 
                        - offsetMouseY* Math.cos(editingComponent.rotation * Math.PI / 180)
                offset=Math.max(offset, -initialBaseHeight)
                let offsetX = offset*Math.sin(editingComponent.rotation * Math.PI / 180)
                let offsetY = offset*Math.cos(editingComponent.rotation * Math.PI / 180)    
                editingComponent.x =  initialBaseTopLeft.x + offsetX
                editingComponent.y =  initialBaseTopLeft.y - offsetY
                editingComponent.height = initialBaseHeight + offset
                editingComponent.saveComToFile()
            }
            if(control.comManager.root.isMousePressed && control.visible && control.isDraggingBottomSide){
                let offsetMouseX = UniDeskTools.getCursorPosition().x - initialMouseX
                let offsetMouseY = UniDeskTools.getCursorPosition().y - initialMouseY
                let offset = offsetMouseX* Math.sin(editingComponent.rotation * Math.PI / 180) 
                        - offsetMouseY* Math.cos(editingComponent.rotation * Math.PI / 180)
                offset=Math.min(offset, initialBaseHeight)
                editingComponent.height = initialBaseHeight - offset
                editingComponent.saveComToFile()
            }
            if(control.comManager.root.isMousePressed && control.visible && control.isDraggingLeftSide){
                let offsetMouseX = UniDeskTools.getCursorPosition().x - initialMouseX
                let offsetMouseY = UniDeskTools.getCursorPosition().y - initialMouseY
                let offset = offsetMouseX* Math.cos(editingComponent.rotation * Math.PI / 180) 
                        + offsetMouseY* Math.sin(editingComponent.rotation * Math.PI / 180)
                offset=Math.min(offset, initialBaseWidth)
                let offsetX = offset*Math.cos(editingComponent.rotation * Math.PI / 180)
                let offsetY = offset*Math.sin(editingComponent.rotation * Math.PI / 180)    
                editingComponent.x =  initialBaseTopLeft.x + offsetX
                editingComponent.y =  initialBaseTopLeft.y + offsetY
                editingComponent.width = initialBaseWidth - offset
                editingComponent.saveComToFile()
            }
            if(control.comManager.root.isMousePressed && control.visible && control.isDraggingRightSide){
                let offsetMouseX = UniDeskTools.getCursorPosition().x - initialMouseX
                let offsetMouseY = UniDeskTools.getCursorPosition().y - initialMouseY
                let offset = offsetMouseX* Math.cos(editingComponent.rotation * Math.PI / 180) 
                        + offsetMouseY* Math.sin(editingComponent.rotation * Math.PI / 180)
                offset=Math.max(offset, -initialBaseWidth)
                let offsetX = offset*Math.cos(editingComponent.rotation * Math.PI / 180)
                let offsetY = offset*Math.sin(editingComponent.rotation * Math.PI / 180)    
                editingComponent.width = initialBaseWidth + offset
                editingComponent.saveComToFile()
            }

        }
        function onMouseReleased(){
            control.isRotating = false
            control.isDraggingTopLeftCorner = false
            control.isDraggingTopSide = false
            control.isDraggingRightSide = false
            control.isDraggingBottomSide = false
            control.isDraggingLeftSide = false
        }
    }
}