import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk.Controls
import UniDesk.Singletons
import UniDesk

UniDeskBase{
    id: base
    signal closeSignal
    property alias bg: rect_bg
    property double mouseX: mouseArea.mouseX
    property double mouseY: mouseArea.mouseY
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
    width: rotatedWidth()
    height: rotatedHeight()
    color: "transparent"
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
    MouseArea{
        id: mouseArea
        anchors.fill: parent
    }
    UniDeskBase{
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
    function deleteCom(){
        UniDeskComponentsData.removeComponent(base.identification);
        UniDeskComManager.component_list.splice(UniDeskComManager.getIndexById(base.identification),1);
        var pidx=UniDeskComManager.pid2pindex(base.pageid)
        for(var i=0;i<UniDeskComManager.compModels.get(pidx).value.count;i++){
            if(UniDeskComManager.compModels.get(pidx).value.get(i).display===base.identification){
                UniDeskComManager.compModels.get(pidx).value.remove(i);
            }
        }
        base.closeSignal();
        base.baseClose();
        // base.destroy();  //this cause the whole process terminated
    }
    function baseClose(){
        indicator_base.close();
        base.close();
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
            base.baseClose();
        }
    }
}
