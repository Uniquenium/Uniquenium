pragma Singleton
import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk.Controls
import UniDesk.PyPlugin
import UniDesk.Components
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
    property list<Component> type_list
    property list<string> typename_list
    ListModel{
        id: page_list_model
        ListElement{
            text: qsTr("默认页面")
            idx: 0
        }
    }
    onPageIndexChanged: {
        for(var i=0;i<component_list.length;i++){
            if(pageIndex==component_list[i].pageIdx){
                component_list[i].visible=true;
            }
            else{
                component_list[i].visible=false;
            }
        }
    }
    function add_com(typename,typenameTr){
        var idx=typename_list.indexOf(typename);
        var new_com=type_list[idx].createObject(null,{"identification":qsTr(typenameTr)+" "+serialComponentCnt,"visualX":newX,"visualY": newY,"pageIdx": pageIndex});
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
        return null;
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
            var id_num=parseInt(data[i].identification.split(" ")[1]);
            var new_com;
            for(var j=0;j<typename_list.length;j++){
                if(data[j].type===typename_list[j]){
                    new_com=type_list[j].createObject(null,data[i]);
                }
            }
            component_list.push(new_com)
            if(new_com.pageIdx==pageIndex){
                new_com.visible=true;
            }
            else{
                new_com.visible=false;
            }
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
    function loadComponentTypesFromData(){
        typename_list=UniDeskComponentsData.getComponentTypes();
        for(var i=0;i<typename_list.length;i++){
            type_list.push(Qt.createComponent("UniDesk.Components",typename_list[i]));
        }
    }
    Component.onCompleted: {
        loadComponentTypesFromData();
        pageIndex=UniDeskComponentsData.getCurrentPage();
        loadPagesFromData();
        loadComponentsFromData();
    }
}