import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import unidesk_qml
import org.itcdt.unidesk

UniDeskObject{
    id: object
    property int pageIndex: 1
    property int delta: 100
    property list<UniDeskComBase> component_list
    property int newX: 0
    property int newY: 0
    Component{
        id: com_text
        UniDeskComBase{
            id: base
            visible: object.pageIndex===page
            width: cont.width
            height: cont.height
            property string textContent
            property color textColor
            property url fontSource
            property string fontFamily
            property string fontSize
            property int page
            UniDeskText{
                id: cont
                text: base.textContent
                textColor: base.textColor
                fontSource: base.fontSource
                fontFamily: base.fontFamily
                fontSize: base.fontSize
            }
        }
    }
    function add_com_text(text,color,fontSource,family,size){
        var new_com=com_text.createObject(null,{"textContent":text,"textColor":color,"fontFamily":family,"fontSource":fontSource,"fontSize":size,"x":newX,"y": newY,"page": object.pageIndex});
        component_list.push(new_com)
        newX=(newX+delta)%Screen.desktopAvailableWidth
        newY=(newY+delta)%Screen.desktopAvailableHeight
    }
    function close_all(){
        for(var i=0;i<component_list.length;i++){
            component_list[i].close();
        }
    }
}