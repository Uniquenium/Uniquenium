import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk
import org.uniquenium.unidesk
import Qt.labs.platform as QLP

UniDeskObject{
    id: object
    property int pageIndex: 0
    property int serialCnt: 1
    property int delta: 100
    property list<UniDeskComBase> component_list
    property int newX: 0
    property int newY: 0
    property alias page_list: page_list_model
    ListModel{
        id: page_list_model
        ListElement{
            text: qsTr("默认页面")
            idx: 0
        }
    }
    Component{
        id: com_text
        UniDeskComBase{
            id: base
            visible: true
            width: cont.width
            height: cont.height
            property string textContent
            property color textColor
            property string fontFamily
            property string fontSize
            UniDeskText{
                id: cont
                text: base.textContent ? base.textContent : qsTr("请输入文本内容")
                textColor: base.textColor
                fontFamily: base.fontFamily
                fontSize: base.fontSize
            }
            QLP.Menu{
                id: menu
                QLP.MenuItem{
                    text: qsTr("编辑")
                    icon.source: "qrc:/media/img/edit-2-line.svg"
                    onTriggered: {
                        optionsText.show();
                    }
                }
                QLP.MenuItem{
                    text: qsTr("删除")
                    icon.source: "qrc:/media/img/delete-bin-2-line.svg"
                    onTriggered: {
                        base.close();
                    }
                }
            }
            UniDeskOptionsText{
                id: optionsText
                editingComponent: base
            }
            onRightClicked: {
                menu.open();
            }
        }
    }
    onPageIndexChanged: {
        for(var i=0;i<component_list.length;i++){
            if(pageIndex==component_list[i].pageIdx){
                component_list[i].visible=true;
            }
            else{
                component_list[i].visible=false
            }
        }
    }
    function add_com_text(text,color,family,size){
        var new_com=com_text.createObject(null,{"textContent":text,"textColor":color,"fontFamily":family,"fontSize":size,"x":newX,"y": newY,"pageIdx": pageIndex});
        component_list.push(new_com)
        newX=(newX+delta)%(Screen.desktopAvailableWidth-new_com.width)
        newY=(newY+delta)%(Screen.desktopAvailableHeight-new_com.height)
    }
    function close_all(){
        for(var i=0;i<component_list.length;i++){
            component_list[i].close();
        }
    }
    function toggle_page_to(index){
        pageIndex=index;
    }
    function new_page(index){
        page_list_model.append({"text": qsTr("页面")+serialCnt.toString(),"idx": serialCnt})
        serialCnt+=1;
    }
}