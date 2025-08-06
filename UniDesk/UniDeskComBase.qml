import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk
import org.uniquenium.unidesk

UniDeskBase{
    id: base
    property alias bg: rect_bg
    property double mouseX: mouseArea.mouseX
    property double mouseY: mouseArea.mouseY
    property string identification
    property int pageIdx
    property UniDeskComBase parentComponent
    property double visualX
    property double visualY
    property bool canMove: false
    property bool canResize: false
    onVisualXChanged:{
        x=parentComponent ? parentComponent.x+visualX : visualX
    }
    onVisualYChanged:{
        y=parentComponent ? parentComponent.y+visualY : visualY
    }
    x: parentComponent ? parentComponent.x+visualX : visualX
    y: parentComponent ? parentComponent.y+visualY : visualY
    onXChanged: {
        var newVisualX = parentComponent ? x-parentComponent.x : x
        if (newVisualX !== visualX) {
            visualX = newVisualX;
        }
    }
    onYChanged: {
        var newVisualY = parentComponent ? y-parentComponent.y : y
        if (newVisualY !== visualY) {
            visualY = newVisualY;
        }
    }
    onParentComponentChanged: {
        var newVisualX = parentComponent ? x-parentComponent.x : x
        if (newVisualX !== visualX) {
            visualX = newVisualX;
        }
        var newVisualY = parentComponent ? y-parentComponent.y : y
        if (newVisualY !== visualY) {
            visualY = newVisualY;
        }
    }
    color: "transparent"
    Rectangle{
        id: rect_bg
        anchors.fill: parent
        color: "transparent"
    }
    MouseArea{
        id: mouseArea
        anchors.fill: parent
    }
    Connections{
        target: base.parentComponent
        function onXChanged(){
            base.x = base.parentComponent ? base.parentComponent.x+base.visualX : base.visualX
        }
        function onYChanged(){
            base.y = base.parentComponent ? base.parentComponent.y+base.visualY : base.visualY
        }
        
    }
    function baseClose(){
        base.close()
    }
}