pragma Singleton
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
    property int serialComponentCnt: 1
    property int serialPageCnt: 1
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
            property string textContent: qsTr("文字")
            property color textColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
            property string fontFamily: UniDeskTextStyle.family
            property real fontSize: 30
            property bool smallCaps: false
            property bool bold: false
            property bool italic: false
            property bool underline: false
            property bool strikeout: false
            property real letterSpacing: 0
            property real wordSpacing: 0
            property real lineHeight: 1
            property int weight: Font.Normal
            property var style: Text.Normal
            property color styleColor: UniDeskSettings.primaryColor
            property var textFormat: Text.RichText
            UniDeskText{
                id: cont
                text: base.textContent ? base.textContent : qsTr("请输入文本内容")
                textColor: base.textColor
                font.family: base.fontFamily
                font.pixelSize: base.fontSize
                font.capitalization: base.smallCaps ? Font.SmallCaps : Font.MixedCase
                font.bold: base.bold
                font.italic: base.italic
                font.underline: base.underline
                font.strikeout: base.strikeout
                font.letterSpacing: base.letterSpacing
                font.wordSpacing: base.wordSpacing
                lineHeight: base.lineHeight
                font.weight: base.weight
                style: base.style
                styleColor: base.styleColor
                textFormat: base.textFormat
            }
            QLP.Menu{
                id: menu
                QLP.MenuItem{
                    text: qsTr("编辑")
                    icon.source: "qrc:/media/img/edit-2-line.svg"
                    onTriggered: {
                        optionsText.showActivate()
                    }
                }
                QLP.MenuItem{
                    text: qsTr("删除")
                    icon.source: "qrc:/media/img/delete-bin-2-line.svg"
                    onTriggered: {
                        object.component_list.pop(object.getIndexById(base.identification));
                        optionsText.close();
                        base.close();
                    }
                }
            }
            UniDeskOptionsText{
                id: optionsText
                editingComponent: base
                comManager: object
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
    function add_com_text(){
        var new_com=com_text.createObject(null,{"identification":qsTr("文字 ")+serialComponentCnt,"x":newX,"y": newY,"pageIdx": pageIndex});
        component_list.push(new_com)
        newX=(newX+delta)%(Screen.desktopAvailableWidth-new_com.width)
        newY=(newY+delta)%(Screen.desktopAvailableHeight-new_com.height)
        serialComponentCnt+=1;
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
        page_list_model.append({"text": qsTr("页面")+serialPageCnt.toString(),"idx": serialPageCnt})
        serialPageCnt+=1;
    }
    function validateId(id){
        if(id=="")return false;
        for(var i=0;i<component_list.length;i++){
            if(component_list[i].identification===id){
                return false;
            }
        }
        return true;
    }
    function getIndexById(id){
        for(var i=0;i<component_list.length;i++){
            if(component_list[i].identification===id){
                return i;
            }
        }
        return -1;
    }
    function getComById(id){
        for(var i=0;i<component_list.length;i++){
            if(component_list[i].identification===id){
                return component_list[i];
            }
        }
        return -1;
    }
}