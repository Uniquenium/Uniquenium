//please use 'comManager' property in other files
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

UniDeskObject{
    id: object
    property int currentPid: 0
    property int serialComponentCnt: 1
    property int serialPageCnt: 1
    property int delta: 100
    property list<var> component_list
    property int newX: 0
    property int newY: 0
    property alias page_list: page_list_model
    property list<Component> type_list
    property list<string> typename_list
    property list<var> componentInfoList
    property ListModel compModels: ListModel{}
    ListModel{
        id: page_list_model
        ListElement{
            text: qsTr("默认页面")
            pid: 0
        }
    }
    Component{
        id: com_tree_model
        ListModel{
            id: tree
        }
    }
    onCurrentPidChanged: {
        for(var i=0;i<component_list.length;i++){
            if(currentPid===component_list[i].pageid){
                component_list[i].visible=true;
            }
            else{
                component_list[i].visible=false;
            }
        }
    }
    function add_com(typename,typenameTr,pageid){
        if(pageid){
            currentPid=pageid;
        }
        let typid=typename_list.indexOf(typename);
        let new_com=type_list[typid].createObject(null,{"identification":qsTr(typenameTr)+" "+serialComponentCnt,"pageid": currentPid,"comManager":object,"x":newX,"y":newY});
        UniDeskComponentsData.addComponent(new_com.propertyData());
        component_list.push(new_com);
        for(var i=0;i<component_list.length;i++){
            if(currentPid===component_list[i].pageid){
                component_list[i].visible=true;
            }
            else{
                component_list[i].visible=false;
            }
        }
        newX=(newX+delta)%(Screen.desktopAvailableWidth-new_com.width);
        newY=(newY+delta)%(Screen.desktopAvailableHeight-new_com.height);
        serialComponentCnt+=1;
        compModels.get(pid2pindex(currentPid)).value.append({"display":new_com.identification});
    }
    function close_all(){
        for(var i=0;i<component_list.length;i++){
            component_list[i].close();
        }
    }
    function toggle_page_to(index){
        currentPid=index;
        UniDeskComponentsData.setCurrentPage(index);
    }
    function new_page(index){
        page_list_model.append({"text": qsTr("页面")+serialPageCnt.toString(),"pid": serialPageCnt});
        compModels.append({"value":com_tree_model.createObject(null,{})});
        UniDeskComponentsData.addPage({"text": qsTr("页面")+serialPageCnt.toString(),"pid": serialPageCnt});
        serialPageCnt+=1;
    }
    function rename_page(index,newname){
        page_list_model.get(index).text=newname
        UniDeskComponentsData.updatePage(index-1,page_list_model.get(index))
    }
    function remove_page(index){
        page_list_model.remove(index)
        compModels.remove(index);
        UniDeskComponentsData.removePage(index-1)
    }
    function validateId(id){
        if(id==="")return false;
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
                if(data[i].type===typename_list[j]){
                    new_com=type_list[j].createObject(null,{"identification":data[i].identification,"pageid": data[i].pageid,"comManager":object,"geoX":data[i].x,"geoY":data[i].y});
                    new_com.loadPropertyData(data[i]);
                }
            }
            component_list.push(new_com)
            compModels.get(pid2pindex(new_com.pageid)).value.append({"display":new_com.identification});
            new_com.visible=new_com.pageid===currentPid;
            if(!isNaN(id_num)&&id_num>=serialComponentCnt){
                serialComponentCnt=id_num+1;
            }
        }
    }
    function loadPagesFromData(){
        compModels.append({"value":com_tree_model.createObject(null,{})});
        var data=UniDeskComponentsData.getPages();
        for(var i=0;i<data.length;i++){
            page_list_model.append({"text": data[i].text,"pid": data[i].pid});
            compModels.append({"value":com_tree_model.createObject(null,{})});
            var idx_num=data[i].pid;
            if(!isNaN(idx_num)&&idx_num>=serialPageCnt){
                serialPageCnt=idx_num+1;
            }
        }
    }
    function loadComponentTypesFromData(){
        componentInfoList=UniDeskComponentsData.getComponentTypes();
        typename_list=[];
        type_list=[];
        for(var i=0;i<componentInfoList.length;i++){
            var info=componentInfoList[i];
            typename_list.push(info.filename);
            print(info.filename+" Loading")
            type_list.push(Qt.createComponent("UniDesk.Components."+info.filename,info.filename,Component.Synchronous, null));
            print(info.filename+" Loaded")
        }
    }
    function pid2pindex(pid){
        for(var i=0;i<page_list_model.count;i++){
            if(page_list_model.get(i).pid===pid){
                return i;
            }
        }
    }
    function pindex2pid(index){
        return page_list_model.get(index) ?page_list_model.get(index).pid : -1
    }
    function move_page_up(index){
        page_list_model.move(index,index-1,1);
        compModels.move(index,index-1,1);
        UniDeskComponentsData.updatePage(index-1,page_list_model.get(index));
        UniDeskComponentsData.updatePage(index-2,page_list_model.get(index-1));
    }
    function move_page_down(index){
        page_list_model.move(index,index+1,1);
        compModels.move(index,index+1,1);
        UniDeskComponentsData.updatePage(index-1,page_list_model.get(index));
        UniDeskComponentsData.updatePage(index,page_list_model.get(index+1));
    }
    function insert_new_page(index){
        page_list_model.insert(index,{"text": qsTr("页面")+serialPageCnt.toString(),"pid": serialPageCnt});
        compModels.insert(index,{"value":com_tree_model.createObject(null,{})});
        //Don't change "index-1" for unnecessary reasons!
        UniDeskComponentsData.insertPage(index-1,{"text": qsTr("页面")+serialPageCnt.toString(),"pid": serialPageCnt});
        serialPageCnt+=1;
    }
    function index_in_compModels(comId){
        var c=getComById(comId);
        for(var i=0;i<compModels.get(pid2pindex(c.pageid)).value.count;i++){
            if(compModels.get(pid2pindex(c.pageid)).value.get(i).display===c.identification){
                return i
            }
        }
    }
    function move_com_to_page(comId,indexPage){
        var c=getComById(comId);
        compModels.get(indexPage).value.append({"display":comId});
        compModels.get(pid2pindex(c.pageid)).value.remove(index_in_compModels(comId));
        c.pageid=pindex2pid(indexPage);
        c.saveComToFile();
    }
}
