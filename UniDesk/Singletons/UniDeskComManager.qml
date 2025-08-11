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
    property list<UniDeskTreeModel> treeModels
    ListModel{
        id: page_list_model
        ListElement{
            text: qsTr("默认页面")
            idx: 0
        }
    }
    Component{
        id: com_tree_model
        UniDeskTreeModel{
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
    function add_com(typename,typenameTr,parentId,pageIdx){
        if(pageIdx){
            pageIndex=pageIdx;
        }
        var idx=typename_list.indexOf(typename);
        var new_com=type_list[idx].createObject(null,{"identification":qsTr(typenameTr)+" "+serialComponentCnt,"visualX":newX,"visualY": newY,"pageIdx": pageIndex});
        new_com.parentIdentification=parentId;
        UniDeskComponentsData.addComponent(new_com.propertyData());
        component_list.push(new_com)
        newX=(newX+delta)%(Screen.desktopAvailableWidth-new_com.width)
        newY=(newY+delta)%(Screen.desktopAvailableHeight-new_com.height)
        serialComponentCnt+=1;
        var pidx=pageIdxConvert(pageIdx)
        var pid=treeModels[pidx].find(parentId)
        var id=treeModels[pidx].appendRow(pid)
        treeModels[pidx].setData(id,new_com.identification)
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
        treeModels.push(com_tree_model.createObject(null,{}));
        var data=UniDeskComponentsData.getPages();
        for(var i=0;i<data.length;i++){
            page_list_model.append({"text": data[i].text,"idx": data[i].idx});
            treeModels.push(com_tree_model.createObject(null,{}));
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
    function loadTree(){
        for(var i=0;i<component_list.length;i++){
            var c=component_list[i];
            var pidx=pageIdxConvert(c.pageIdx)
            var id=treeModels[pidx].appendRow(treeModels[pidx].rootIndex())
            treeModels[pidx].setData(id,c.identification)
        }
        for(var i=0;i<component_list.length;i++){
            var c=component_list[i];
            if(c.parentIdentification!==""){
                var pidx=pageIdxConvert(c.pageIdx)
                var pid=treeModels[pidx].find(c.parentIdentification)
                var iid=treeModels[pidx].find(c.identification)
                treeModels[pidx].removeIndex(iid);
                var id=treeModels[pidx].appendRow(pid);
                treeModels[pidx].setData(id,c.identification)
            }
        }
    }
    function pageIdxConvert(idx){
        for(var i=0;i<page_list_model.count;i++){
            if(page_list_model.get(i).idx===idx){
                return i;
            }
        }
    }
    Component.onCompleted: {
        loadComponentTypesFromData();
        pageIndex=UniDeskComponentsData.getCurrentPage();
        loadPagesFromData();
        loadComponentsFromData();
        loadTree();
    }
}