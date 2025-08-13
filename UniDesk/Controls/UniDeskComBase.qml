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
    property bool canMove: false
    property bool canResize: false
    property bool indicated: false
    property bool chosen: false
    property bool subComponentable: false
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
        var pidx=UniDeskComManager.pageIdxConvert(base.pageIdx)
        for(var i=0;i<UniDeskComManager.compModels[pidx].count;i++){
            if(UniDeskComManager.compModels[pidx].get(i).display===base.identification){
                UniDeskComManager.compModels[pidx].remove(i)
            }
        }
        base.baseClose();
        base.destroy();
    }
    function baseClose(){
        indicator_base.close();
        base.close();
    }

}