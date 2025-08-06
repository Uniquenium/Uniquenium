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
            UniDeskMenu{
                id: menu
                UniDeskMenuItem{
                    text: qsTr("编辑")
                    iconSource: "qrc:/media/img/edit.svg"
                    onClicked: {
                        optionsText.showActivate()
                    }
                }
                UniDeskMenuItem{
                    text: qsTr("可拖动")
                    iconSource: "qrc:/media/img/move.svg"
                    checkable: true
                    onClicked: {
                        checked=!checked;
                        base.canMove=checked;
                        base.saveComToFile();
                        menu.close();
                    }
                    Component.onCompleted: {
                        checked=base.canMove;
                    }
                }
                UniDeskMenuItem{
                    text: qsTr("删除")
                    iconSource: "qrc:/media/img/delete-bin.svg"
                    onClicked: {
                        UniDeskComponentsData.removeComponent(base.identification);
                        object.component_list.splice(object.getIndexById(base.identification),1);
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
                menu.popup(base)
            }
            onVisualXChanged:{
                saveComToFile();
            }
            onVisualYChanged:{
                saveComToFile();
            }
            function propertyData(){
                return {
                    "type": "text",
                    "identification": base.identification,
                    "pageIdx": base.pageIdx,
                    "parentComponent": base.parentComponent ? base.parentComponent.identification: null,
                    "visualX": base.visualX,
                    "visualY": base.visualY,
                    "canMove": base.canMove,
                    "canResize": base.canResize,
                    "textContent": base.textContent,
                    "textColor": base.textColor,
                    "fontFamily": base.fontFamily,
                    "fontSize": base.fontSize,
                    "smallCaps": base.smallCaps,
                    "bold": base.bold,
                    "italic": base.italic,
                    "underline": base.underline,
                    "strikeout": base.strikeout,
                    "letterSpacing": base.letterSpacing,
                    "wordSpacing": base.wordSpacing,
                    "lineHeight": base.lineHeight,
                    "weight": base.weight,
                    "style": base.style,
                    "styleColor": base.styleColor,
                    "textFormat": base.textFormat
                }
            }
            function saveComToFile(){
                var data= propertyData();
                UniDeskComponentsData.updateComponent(object.getIndexById(identification), data);
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
        var new_com=com_text.createObject(null,{"identification":qsTr("文字 ")+serialComponentCnt,"visualX":newX,"visualY": newY,"pageIdx": pageIndex});
        UniDeskComponentsData.addComponent(new_com.propertyData());
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
        UniDeskComponentsData.setCurrentPage(index);
    }
    function new_page(index){
        page_list_model.append({"text": qsTr("页面")+serialPageCnt.toString(),"idx": serialPageCnt});
        UniDeskComponentsData.addPage({"text": qsTr("页面")+serialPageCnt.toString(),"idx": serialPageCnt});
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
    function getIndexByCom(com){
        for(var i=0;i<component_list.length;i++){
            if(component_list[i]===com){
                return i;
            }
        }
        return -1;
    }
    function loadComponentsFromData(){
        var data=UniDeskComponentsData.getComponents();
        for(var i=0;i<data.length;i++){
            if(data[i].type==="text"){
                var new_com=com_text.createObject(null,{
                    "identification":data[i].identification,
                    "pageIdx":data[i].pageIdx,
                    "parentComponent":data[i].parentComponent ? getComById(data[i].parentComponent) : null,
                    "visualX":data[i].visualX,
                    "visualY":data[i].visualY,
                    "canMove":data[i].canMove,
                    "canResize":data[i].canResize,
                    "textContent":data[i].textContent,
                    "textColor":data[i].textColor,
                    "fontFamily":data[i].fontFamily,
                    "fontSize":data[i].fontSize,
                    "smallCaps":data[i].smallCaps,
                    "bold":data[i].bold,
                    "italic":data[i].italic,
                    "underline":data[i].underline,
                    "strikeout":data[i].strikeout,
                    "letterSpacing":data[i].letterSpacing,
                    "wordSpacing":data[i].wordSpacing,
                    "lineHeight":data[i].lineHeight,
                    "weight":data[i].weight,
                    "style":data[i].style,
                    "styleColor":data[i].styleColor,
                    "textFormat":data[i].textFormat
                });
            }
            else{
                continue;
            }
            new_com.parentComponent=data[i].parentComponent ? getComById(data[i].parentComponent) : null;
            component_list.push(new_com)
            if(new_com.pageIdx==pageIndex){
                new_com.visible=true;
            }
            else{
                new_com.visible=false
            }
            var id_num=parseInt(data[i].identification.split(" ")[1]);
            if(!isNaN(id_num)&&id_num>=serialComponentCnt){
                serialComponentCnt=id_num+1;
            }
        }
    }
    function loadPagesFromData(){
        var data=UniDeskComponentsData.getPages();
        for(var i=0;i<data.length;i++){
            page_list_model.append({"text": data[i].text,"idx": data[i].idx});
            var idx_num=data[i].idx;
            if(!isNaN(idx_num)&&idx_num>=serialPageCnt){
                serialPageCnt=idx_num+1;
            }
        }
    }
    Component.onCompleted: {
        pageIndex=UniDeskComponentsData.getCurrentPage();
        loadPagesFromData();
        loadComponentsFromData();
    }
}