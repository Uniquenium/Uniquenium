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
    property var parentOfNewCom: root.contentItem;
    property int serialComponentCnt: 1
    property int serialPageCnt: 1
    property int delta: 100
    property list<Item> component_list
    property alias page_list: page_list_model
    property list<Component> type_list
    property list<string> typename_list
    property list<var> componentInfoList
    property ListModel compModels: ListModel{}
    property var root
    property var comWindow
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
        let new_com=type_list[typid].createObject(parentOfNewCom,{"name":qsTr(typenameTr)+" "+serialComponentCnt,"identification":serialComponentCnt,"pageid": currentPid,"comManager":object,"x":50,"y":50});
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
        compModels.get(pid2pindex(currentPid)).value.append({"display":new_com.identification});
    }
    function toggle_page_to(id){
        currentPid=id;
        UniDeskComponentsData.setCurrentPage(id);
    }
    function new_page(){
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
        // 如果要删除的是当前页面，先切换到前一个页面
        if(pindex2pid(index) === currentPid && page_list_model.count > 1){
            var newIndex = Math.max(0, index - 1);
            currentPid = pindex2pid(newIndex);
            UniDeskComponentsData.setCurrentPage(currentPid);
        }
        UniDeskComponentsData.removePage(pindex2pid(index))
        page_list_model.remove(index);
        compModels.remove(index);
    }
    function copy_com(com){
        // 获取源组件的类型和属性数据
        var typename = com.type;
        var data = com.propertyData();
        // 查找类型索引
        var typid = typename_list.indexOf(typename);
        if (typid === -1) return;
        // 创建新组件（位置偏移delta）
        var new_com = type_list[typid].createObject(com.parent, {
            "name": qsTr(typename) + " " + serialComponentCnt,
            "identification": serialComponentCnt,
            "pageid": com.pageid,
            "comManager": object,
        });
        // 设置属性数据（使用新的identification）
        new_com.loadPropertyData(data);
        new_com.x=com.x+50;
        new_com.y=com.y+50;
        new_com.name = qsTr(typename) + " " + serialComponentCnt;
        // 添加到列表
        UniDeskComponentsData.addComponent(new_com.propertyData());
        component_list.push(new_com);
        // 设置可见性
        new_com.visible = new_com.pageid === currentPid;
        // 更新索引
        serialComponentCnt += 1;
        // 更新右侧列表
        compModels.get(pid2pindex(new_com.pageid)).value.append({"display": new_com.identification});
        return new_com;
    }
    function delete_com(id){
        var com=getComById(id);
        for(var i=0;i<com.children.length;i++){
            if(com.children[i].identification){
                com.children[i].changeParentWithoutMoving(com.parent);
            }
        }
        UniDeskComponentsData.removeComponent(id);
        component_list.splice(getIndexById(id),1);
        var pidx=pid2pindex(com.pageid)
        for(var i=0;i<compModels.get(pidx).value.count;i++){
            if(compModels.get(pidx).value.get(i).display===id){
                compModels.get(pidx).value.remove(i);
            }
        }
        com.closeSignal();
        com.visible=false;
        // UniDeskUtils.deleteLater(com); //this cause the whole app to crash
    }
    function clear_page(index){
        //no 'i++': count will auto decrease
        for(var i=0;i<compModels.get(index).value.count;){
            delete_com(compModels.get(index).value.get(i).display);
        }
    }
    function copy_page(index){
        // 获取源页面的pid
        var sourcePid = pindex2pid(index);
        var sourcePageData = page_list_model.get(index);
        // 创建新页面
        var newPageName = sourcePageData.text + qsTr("副本");
        var newPid = serialPageCnt;
        page_list_model.append({"text": newPageName, "pid": newPid});
        compModels.append({"value": com_tree_model.createObject(null, {})});
        UniDeskComponentsData.addPage({"text": newPageName, "pid": newPid});
        serialPageCnt += 1;
        // 复制该页面的所有组件
        for (var i = 0; i < component_list.length; i++) {
            var com = component_list[i];
            if (com.pageid === sourcePid) {
                // 复制组件到新页面
                var typename = com.type;
                var data = com.propertyData();
                var typid = typename_list.indexOf(typename);
                if (typid === -1) continue;
                
                var new_com = type_list[typid].createObject(com.parent, {
                    "name": qsTr(typename) + " " + serialComponentCnt,
                    "identification": serialComponentCnt,
                    "pageid": newPid,
                    "comManager": object,
                    "x": com.x,
                    "y": com.y
                });
                
                new_com.loadPropertyData(data);
                new_com.pageid=newPid;
                new_com.name = qsTr(typename) + " " + serialComponentCnt;
                new_com.visible = new_com.pageid === currentPid;
                
                UniDeskComponentsData.addComponent(new_com.propertyData());
                component_list.push(new_com);
                compModels.get(pid2pindex(newPid)).value.append({"display": new_com.identification});
                serialComponentCnt += 1;
            }
        }
        
        return newPid;
    }
    function validateName(name){
        if(name===""||name===qsTr("桌面"))return false;
        for(var i=0;i<component_list.length;i++){
            if(component_list[i].name===name){
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
        if(id==="Desktop"){
            return root.contentItem;
        }
        for(var i=0;i<component_list.length;i++){
            if(component_list[i].identification===id){
                return component_list[i];
            }
        }
        return null;
    }
    function getComByName(name){
        for(var i=0;i<component_list.length;i++){
            if(component_list[i].name===name){
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
            var id_num=data[i].identification;
            var new_com;
            for(var j=0;j<typename_list.length;j++){
                if(data[i].type===typename_list[j]){
                    new_com=type_list[j].createObject(root.contentItem,{"identification":data[i].identification,"pageid": data[i].pageid,"comManager":object,"x":data[i].x,"y":data[i].y});
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
        for(var i=0;i<data.length;i++){
            var id_num=data[i].identification;
            var com=getComById(id_num);
            if(com){
                com.parent=getComById(data[i].parent);
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
        for(var i=0;i<page_list_model.count;i++){
            if(page_list_model.get(i).pid===pid){
                return i;
            }
        }
        return 0;
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
    function mouse_on_any_com(mousePos){
        for(var i=0;i<component_list.length;i++){
            if(component_list[i].visible){
                if(component_list[i].containsGlobalPoint(mousePos)){
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
        return pid2pindex(currentPid)===page_list_model.count-1;
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
}
