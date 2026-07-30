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
    property string currentPid: "default"
    property var parentOfNewCom: root.contentItem;
    property int serialComponentCnt: 1
    property int serialPageCnt: 1
    property int delta: 100
    property list<Item> component_list
    property alias page_list: compModels
    property list<Component> type_list
    property list<string> typename_list
    property list<var> componentInfoList
    ListModel{
        id: compModels
        ListElement{
            text: qsTr("默认页面")
            pid: "default"
        }
    }
    property ListModel tempInfo: ListModel{}
    property var wallpaperLayer
    property var root
    property var topMostLayer
    property var comWindow
    property var selectMode: UniDeskComponentSelectMode.NoSelect
    property list<Item> selectedComponents
    property list<Item> needMoveComponents
    signal menuClosed()

    Component{
        id: com_tree_model
        UniDeskComponentTreeModel{
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
        let uuid = UniDeskTools.createUuid();
        let new_com=type_list[typid].createObject(parentOfNewCom,{"name":qsTr(typenameTr)+" "+serialComponentCnt,"identification":uuid,"pageid": currentPid,"comManager":object,"x":50,"y":50,"type":typename});
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
        serialComponentCnt+=1;
        compModels.get(pid2pindex(currentPid)).value.append({"identification":new_com.identification, "name":new_com.name, "type":new_com.type, "parentId":new_com.parent ? new_com.parent.identification : ""});
    }
    function toggle_page_to(id){
        currentPid=id;
        UniDeskComponentsData.setCurrentPage(id);
    }
    function new_page(){
        let uuid = UniDeskTools.createUuid();
        compModels.append({"text": qsTr("页面")+serialPageCnt.toString(), "pid": uuid, "value":com_tree_model.createObject(null,{})});
        UniDeskComponentsData.addPage({"text": qsTr("页面")+serialPageCnt.toString(),"pid": uuid});
        serialPageCnt+=1;
    }
    function rename_page(index,newname){
        compModels.get(index).text=newname
        UniDeskComponentsData.updatePage(index-1,compModels.get(index))
    }
    function remove_page(index){
        if(pindex2pid(index) === currentPid && compModels.count > 1){
            var newIndex = Math.max(0, index - 1);
            currentPid = pindex2pid(newIndex);
            UniDeskComponentsData.setCurrentPage(currentPid);
        }
        UniDeskComponentsData.removePage(pindex2pid(index))
        compModels.remove(index);
    }
    function copy_com(com){
        // 创建新组件（位置偏移delta）
        let uuid = UniDeskTools.createUuid();
        var new_com=copy_com_basic(com,{
            "identification": uuid,
            "pageid": com.pageid,
            "x": com.x+50,
            "y": com.y+50,
            "name": qsTr(com.type) + " " + serialComponentCnt
        });
        return new_com;
    }
    function delete_com(id){
        var com=getComById(id);
        for(var i=0;i<com.children.length;i++){
            if(com.children[i].identification){
                com.children[i].changeParentWithoutMoving(com.parent);
                com.children[i].saveComToFile();
            }
        }
        UniDeskComponentsData.removeComponent(id);
        component_list.splice(getIndexById(id),1);
        
        if(selectedComponents.indexOf(com)!==-1)selectedComponents.splice(selectedComponents.indexOf(com),1);
        update_need_move_com();
        var pidx=pid2pindex(com.pageid)
        for(var i=0;i<compModels.get(pidx).value.count;i++){
            if(compModels.get(pidx).value.getIdentification(i)===id){
                compModels.get(pidx).value.remove(i);
                break;
            }
        }
        com.closeSignal();
        com.visible=false;
        // UniDeskUtils.deleteLater(com); //this cause the whole app to crash
    }
    function clear_page(index){
        //no 'i++': count will auto decrease
        var ids = [];
        for(var i=0;i<compModels.get(index).value.count;i++){
            ids.push(compModels.get(index).value.getIdentification(i));
        }
        for(var i=ids.length-1;i>=0;i--){
            delete_com(ids[i]);
        }
    }
    function copy_page(index){
        // 获取源页面的pid
        var sourcePid = pindex2pid(index);
        var sourcePageData = compModels.get(index);
        var newPageName = sourcePageData.text + qsTr("副本");
        var newPid = UniDeskTools.createUuid();
        compModels.append({"text": newPageName, "pid": newPid, "value":com_tree_model.createObject(null,{})});
        UniDeskComponentsData.addPage({"text": newPageName, "pid": newPid});
        serialPageCnt+=1;
        var oldIds=[];
        var newIds=[];
        // 复制该页面的所有组件
        for (var i = 0; i < component_list.length; i++) {
            var com = component_list[i];
            if (com.pageid === sourcePid) {
                var new_com=copy_com_basic(com,{
                    "identification": UniDeskTools.createUuid(),
                    "pageid": newPid,
                    "x": com.x,
                    "y": com.y,
                    "name": qsTr(com.type) + " " + serialComponentCnt
                })
                oldIds.push(com.identification);
                newIds.push(new_com.identification);
            }
        }
        for(var i=0;i<newIds.length;i++){
            var com=getComById(newIds[i]);
            if(com.parent.identification){
                com.parent=getComById(newIds[oldIds.indexOf(getComId(com.parent))]);
            }
            com.saveComToFile();
        }
        return newPid;
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
        if(id==="Wallpaper"){
            return wallpaperLayer.contentItem;
        }
        else if(id==="Desktop"){
            return root.contentItem;
        }
        else if(id==="TopMost"){
            return topMostLayer.contentItem;
        }
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
        tempInfo.clear();
        for(var i=0;i<component_list.length;i++){
            tempInfo.append({"id":component_list[i].identification,"optionsWindowVis":component_list[i].optionsWindow ? component_list[i].optionsWindow.visible : false});
            component_list[i].closeSignal();
            component_list[i].visible=false;
            UniDeskUtils.deleteLater(component_list[i]);
        }
        component_list=[];
        for(var i=0;i<compModels.count;i++){
            compModels.get(i).value.clear();
        }
        var data=UniDeskComponentsData.getComponents();
        for(var i=0;i<data.length;i++){
            var id_num=data[i].identification;
            var new_com;
            for(var j=0;j<typename_list.length;j++){
                if(data[i].type===typename_list[j]){
                    //set parent to desktop layer temporarily
                    new_com=type_list[j].createObject(root.contentItem,{"identification":data[i].identification,"pageid": data[i].pageid,"comManager":object,"x":data[i].x,"y":data[i].y});
                    new_com.loadPropertyData(data[i]); 
                }
            }
            component_list.push(new_com)
            compModels.get(pid2pindex(new_com.pageid)).value.append({"identification":new_com.identification, "name":new_com.name, "type":new_com.type, "parentId":data[i].parent ? data[i].parent : ""});
            new_com.visible=new_com.pageid===currentPid;
        }
        for(var i=0;i<data.length;i++){
            var id_num=data[i].identification;
            var com=getComById(id_num);
            if(com){
                com.parent=getComById(data[i].parent);
            }
        }
        // 重新组织每个页面模型的父子关系
        for(var pi=0;pi<compModels.count;pi++){
            compModels.get(pi).value.reparentAll();
        }
        for(var i=0;i<tempInfo.count;i++){
            var com=getComById(tempInfo.get(i).id);
            if(tempInfo.get(i).optionsWindowVis){
                com.optionsWindow.show();
            }
        }
    }
    function loadPagesFromData(){
        compModels.clear();
        compModels.append({"text": qsTr("默认页面"), "pid": "default", "value":com_tree_model.createObject(null,{})});
        var data=UniDeskComponentsData.getPages();
        for(var i=0;i<data.length;i++){
            compModels.append({"text": data[i].text, "pid": data[i].pid, "value":com_tree_model.createObject(null,{})});
        }
    }
    function loadComponentTypesFromData(){
        componentInfoList=UniDeskComponentsData.getComponentTypes();
        typename_list=[];
        type_list=[];
        for(var i=0;i<componentInfoList.length;i++){
            var info=componentInfoList[i];
            print(info.filename+" Loading")
            var component = Qt.createComponent("UniDesk.Components."+info.filename,info.filename,Component.Synchronous, null)
            if(component.status===Component.Ready){
                type_list.push(component);
                typename_list.push(info.filename);
                print(info.filename+" Loaded")
            }
            else if(component.status===Component.Error){
                print("Error loading "+info.filename+": "+component.errorString())
            }
        }
        var plugins=UniDeskPluginMgr.plugins_list;
        for(var i=0;i<plugins.length;i++){
            for(var j=0;j<plugins[i].components.length;j++){
                var info=plugins[i].components[j];
                print(info.name+" Loading")
                var component = Qt.createComponent(Qt.resolvedUrl("file:///"+plugins[i].dirpath+"/"+info.path),Component.Synchronous, null)
                if(component.status===Component.Ready){
                    type_list.push(component);
                    typename_list.push(info.name);
                    print(info.name+" Loaded")
                }
                else if(component.status===Component.Error){
                    print("Error loading "+info.name+": "+component.errorString())
                }
            }
        }
    }
    function pid2pindex(pid){
        for(var i=0;i<compModels.count;i++){
            if(compModels.get(i).pid===pid){
                return i;
            }
        }
        return 0;
    }
    function pindex2pid(index){
        return compModels.get(index) ? compModels.get(index).pid : ""
    }
    function move_page_up(index){
        compModels.move(index,index-1,1);
        UniDeskComponentsData.updatePage(index-1,compModels.get(index));
        UniDeskComponentsData.updatePage(index-2,compModels.get(index-1));
    }
    function move_page_down(index){
        compModels.move(index,index+1,1);
        UniDeskComponentsData.updatePage(index-1,compModels.get(index));
        UniDeskComponentsData.updatePage(index,compModels.get(index+1));
    }
    function insert_new_page(index){
        let uuid = UniDeskTools.createUuid();
        compModels.insert(index,{"text": qsTr("页面")+serialPageCnt.toString(), "pid": uuid, "value":com_tree_model.createObject(null,{})});
        //Don't change "index-1" for unnecessary reasons!
        UniDeskComponentsData.insertPage(index-1,{"text": qsTr("页面")+serialPageCnt.toString(),"pid": uuid});
        serialPageCnt+=1;
    }
    function index_in_compModels(comId){
        var c=getComById(comId);
        if(!c) return -1;
        return compModels.get(pid2pindex(c.pageid)).value.findRow(c.identification);
    }
    function move_com_to_page(comId,indexPage){
        var c=getComById(comId);
        compModels.get(indexPage).value.append({"identification":comId, "name":c.name, "type":c.type, "parentId":c.parent ? c.parent.identification : ""});
        compModels.get(pid2pindex(c.pageid)).value.removeById(comId);
        c.pageid=pindex2pid(indexPage);
        c.saveComToFile();
    }
    function mouse_on_any_com(mousePos,layer){
        for(var i=0;i<component_list.length;i++){
            if(component_list[i].visible){
                if(component_list[i].containsGlobalPoint(mousePos)&&component_list[i].currentLayer()===layer){
                    return true;
                }
            }
        }
        return false;
    }
    function is_first_page(){
        return pid2pindex(currentPid)===0;
    }
    function is_last_page(){
        return pid2pindex(currentPid)===compModels.count-1;
    }
    function previous_page(){
        let currentPindex=pid2pindex(currentPid);
        if(!is_first_page()){
            toggle_page_to(pindex2pid(currentPindex-1));
        }
    }
    function next_page(){
        let currentPindex=pid2pindex(currentPid);
        if(!is_last_page()){
            toggle_page_to(pindex2pid(currentPindex+1));
        }
    }
    function select_com(com){
        if(selectMode===UniDeskComponentSelectMode.SingleSelect){
            unselect_all_com();
        }
        if(com.selected){
            selectedComponents.splice(selectedComponents.indexOf(com),1);
            update_need_move_com();
            com.selected=false;
        }
        else{
            selectedComponents.push(com);
            update_need_move_com();
            com.selected=true;
        }
    }
    function unselect_all_com(){
        for(var i=0;i<selectedComponents.length;i++){
            selectedComponents[i].selected=false;
        }
        selectedComponents=[];
        update_need_move_com();
    }
    function update_need_move_com(){
        //如果同时出现祖先和后代组件，去除后代组件
        //使用while循环直到根组件
        needMoveComponents=[];
        let p;
        for(var i=0;i<selectedComponents.length;i++){
            p=selectedComponents[i].parent;
            let flag=true;
            while(p.identification){
                if(selectedComponents.indexOf(p)!==-1){
                    flag=false;
                    break;
                }
                p=p.parent;
            }
            if(flag){
                needMoveComponents.push(selectedComponents[i]);
            }
        }
    }
    function prepare_multi_move(){
        for(var i=0;i<needMoveComponents.length;i++){
            needMoveComponents[i].initialBaseX=needMoveComponents[i].x;
            needMoveComponents[i].initialBaseY=needMoveComponents[i].y;
        }
    }
    function multi_move(offsetX,offsetY){
        for(var i=0;i<needMoveComponents.length;i++){
            if(needMoveComponents[i].pageid===currentPid){
                needMoveComponents[i].x=needMoveComponents[i].initialBaseX+offsetX;
                needMoveComponents[i].y=needMoveComponents[i].initialBaseY+offsetY;
                needMoveComponents[i].saveComToFile();
            }
        }
    }
    onSelectModeChanged: {
        if(selectMode!==UniDeskComponentSelectMode.MultiSelect){
            unselect_all_com();
        }
    }
    function getComId(com){
        if(com===wallpaperLayer.contentItem){
            return "Wallpaper";
        }
        else if(com===root.contentItem){
            return "Desktop";
        }
        else if(com===topMostLayer.contentItem){
            return "TopMost";
        }
        else{
            return com.identification;
        }
    }
    function copy_com_basic(com,data){
        var new_com = type_list[typename_list.indexOf(com.type)].createObject(com.parent, {
            "comManager": object
        });
        new_com.loadPropertyData(com.propertyData());
        new_com.name=data.name;
        new_com.identification=data.identification;
        new_com.pageid=data.pageid;
        new_com.x=data.x;
        new_com.y=data.y;
        new_com.visible = new_com.pageid === currentPid;
        UniDeskComponentsData.addComponent(new_com.propertyData());
        component_list.push(new_com);
        compModels.get(pid2pindex(data.pageid)).value.append({"identification":new_com.identification, "name":new_com.name, "type":new_com.type, "parentId":new_com.parent ? new_com.parent.identification : ""});
        serialComponentCnt += 1;
        return new_com;
    }
}
