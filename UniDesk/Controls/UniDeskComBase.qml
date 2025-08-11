import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk.Controls
import UniDesk.Singletons
import UniDesk.PyPlugin

UniDeskBase{
    id: base
    property alias bg: rect_bg
    property double mouseX: mouseArea.mouseX
    property double mouseY: mouseArea.mouseY
    property string type
    property string identification
    property int pageIdx
    property string parentIdentification
    property double visualX
    property double visualY
    property bool canMove: false
    property bool canResize: false
    property bool indicated: false
    property bool chosen: false
    onVisualXChanged:{
        x=parentComponent() ? parentComponent().x+visualX : visualX
    }
    onVisualYChanged:{
        y=parentComponent() ? parentComponent().y+visualY : visualY
    }
    x: parentComponent() ? parentComponent().x+visualX : visualX
    y: parentComponent() ? parentComponent().y+visualY : visualY
    onXChanged: {
        var newVisualX = parentComponent() ? x-parentComponent().x : x
        if (newVisualX !== visualX) {
            visualX = newVisualX;
        }
    }
    onYChanged: {
        var newVisualY = parentComponent() ? y-parentComponent().y : y
        if (newVisualY !== visualY) {
            visualY = newVisualY;
        }
    }
    onParentIdentificationChanged: {
        var newVisualX = parentComponent() ? x-parentComponent().x : x
        if (newVisualX !== visualX) {
            visualX = newVisualX;
        }
        var newVisualY = parentComponent() ? y-parentComponent().y : y
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
    Connections{
        target: base.parentComponent() ? base.parentComponent() : null
        function onXChanged(){
            base.x = base.parentComponent() ? base.parentComponent().x+base.visualX : base.visualX
        }
        function onYChanged(){
            base.y = base.parentComponent() ? base.parentComponent().y+base.visualY : base.visualY
        }
        
    }
    function deleteCom(){
        for(var i=0;i<UniDeskComManager.component_list.length;i++){
            var c=UniDeskComManager.component_list[i]
            if(c.parentIdentification===base.identification){
                c.deleteCom();
            }
        }
        UniDeskComponentsData.removeComponent(base.identification);
        UniDeskComManager.component_list.splice(UniDeskComManager.getIndexById(base.identification),1);
        var pidx=UniDeskComManager.pageIdxConvert(base.pageIdx)
        var id=UniDeskComManager.treeModels[pidx].find(base.identification)
        UniDeskComManager.treeModels[pidx].removeIndex(id)
        base.baseClose();
        base.destroy();
    }
    function baseClose(){
        indicator_base.close();
        base.close();
    }
    function parentComponent(){
        return UniDeskComManager.getComById(parentIdentification);
    }

}