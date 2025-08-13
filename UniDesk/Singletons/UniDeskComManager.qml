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
    property list<ListModel> compModels
    ListModel{
        id: page_list_model
        ListElement{
            text: qsTr("默认页面")
            idx: 0
        }
    }
    Component{
        id: com_tree_model
        ListModel{
            id: tree
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
    function add_com(typename,typenameTr,pageIdx){
        if(pageIdx){
            pageIndex=pageIdx;
        }
        var idx=typename_list.indexOf(typename);
        var new_com=type_list[idx].createObject(null,{"identification":qsTr(typenameTr)+" "+serialComponentCnt,"x":newX,"y": newY,"pageIdx": pageIndex});
        UniDeskComponentsData.addComponent(new_com.propertyData());
        component_list.push(new_com)
        newX=(newX+delta)%(Screen.desktopAvailableWidth-new_com.width)
        newY=(newY+delta)%(Screen.desktopAvailableHeight-new_com.height)
        serialComponentCnt+=1;
        var pidx=pageIdxConvert(pageIdx)
        compModels[pidx].append({"display":new_com.identification});
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
    function rename_page(index,newname){
        page_list_model.get(index).text=newname
        UniDeskComponentsData.updatePage(index-1,page_list_model.get(index))
    }
    function remove_page(index){
        page_list_model.remove(index)
        UniDeskComponentsData.removePage(index-1)
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
            compModels[new_com.pageIdx].append({"display":new_com.identification});
            new_com.visible=new_com.pageIdx==pageIndex;
            if(!isNaN(id_num)&&id_num>=serialComponentCnt){
                serialComponentCnt=id_num+1;
            }
        }
    }
    function loadPagesFromData(){
        compModels.push(com_tree_model.createObject(null,{}));
        var data=UniDeskComponentsData.getPages();
        for(var i=0;i<data.length;i++){
            page_list_model.append({"text": data[i].text,"idx": data[i].idx});
            compModels.push(com_tree_model.createObject(null,{}));
            var idx_num=data[i].idx;
            if(!isNaN(idx_num)&&idx_num>=serialPageCnt){
                serialPageCnt=idx_num+1;
            }
        }
    }
    function loadComponentTypesFromData(){
        typename_list=UniDeskComponentsData.getComponentTypes();
        for(var i=0;i<typename_list.length;i++){
            print(typename_list[i]+" Loading")
            type_list.push(Qt.createComponent("UniDesk.Components",typename_list[i]));
            print(typename_list[i]+" Loaded")
        }
    }
    function pageIdxConvert(idx){
        for(var i=0;i<page_list_model.count;i++){
            if(page_list_model.get(i).idx===idx){
                return i;
            }
        }
    }
    function getPageIdx(index){
        return page_list_model.get(index) ?page_list_model.get(index).idx : -1
    }
    function move_page_up(index){
        page_list_model.move(index,index-1,1)
        UniDeskComponentsData.updatePage(index-1,page_list_model.get(index))
        UniDeskComponentsData.updatePage(index-2,page_list_model.get(index-1))
    }
    function move_page_down(index){
        page_list_model.move(index,index+1,1)
        UniDeskComponentsData.updatePage(index-1,page_list_model.get(index))
        UniDeskComponentsData.updatePage(index,page_list_model.get(index+1))
    }
    function insert_new_page(index){
        page_list_model.insert(index,{"text": qsTr("页面")+serialPageCnt.toString(),"idx": serialPageCnt});
        UniDeskComponentsData.insertPage(index,{"text": qsTr("页面")+serialPageCnt.toString(),"idx": serialPageCnt});
        serialPageCnt+=1;
    }
    function index_in_compModels(comId){
        var c=getComById(comId);
        for(var i=0;i<compModels[pageIdxConvert(c.pageIdx)].count;i++){
            if(compModels[pageIdxConvert(c.pageIdx)].get(i).display==c.identification){
                return i
            }
        }
    }
    function move_com_to_page(comId,indexPage){
        var c=getComById(comId);
        compModels[indexPage].append({"display":comId});
        compModels[pageIdxConvert(c.pageIdx)].remove(index_in_compModels(comId));
        c.pageIdx=getPageIdx(indexPage);
        c.saveComToFile();
    }
    Component.onCompleted: {
        loadComponentTypesFromData();
        pageIndex=UniDeskComponentsData.getCurrentPage();
        loadPagesFromData();
        loadComponentsFromData();
    }
}