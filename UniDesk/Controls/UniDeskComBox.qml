import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects
import UniDesk.Controls
import UniDesk.Singletons
import UniDesk

UniDeskComboBox{
    id: control
    property var editingComponent
    property var currentComponent
    currentIndex: getIndexByCom(currentComponent)
    property bool allPages: false
    enableComDelegate: true
    model: getNames(comManager ? comManager.component_list : []);
    editable: true
    width: 300
    function getNames(list){
        var names = [qsTr("桌面层"),qsTr("壁纸层"),qsTr("置顶层")];
        for(var i=0;i<list.length;i++){
            if(list[i]&&(list[i]!==editingComponent)&&(allPages||list[i].pageid===editingComponent.pageid)){
                names.push(list[i].name);
            }
        }
        return names;
    }
    function getComByIndex(index){
        var coms = [comManager.root.contentItem,comManager.wallpaperLayer.contentItem,comManager.topMostLayer.contentItem];
        for(var i=0;i<comManager.component_list.length;i++){
            if(comManager.component_list[i]&&(comManager.component_list[i]!==editingComponent)&&(allPages||comManager.component_list[i].pageid===editingComponent.pageid)){
                coms.push(comManager.component_list[i]);
            }
        }
        return coms[index];
    }
    function getIndexByCom(com){
        var list = comManager ? comManager.component_list : [];
        if(!comManager)return 0;
        if(com===comManager.root.contentItem){
            return 0;
        }
        else if(com===comManager.wallpaperLayer.contentItem){
            return 1;
        }
        else if(com===comManager.topMostLayer.contentItem){
            return 2;
        }
        for(var i=0;i<list.length;i++){
            if(list[i]&&(list[i]!==editingComponent)&&(allPages||list[i].pageid===editingComponent.pageid)&&(list[i]===com)){
                return i+3;
            }
        }
        return 0;
    }
    onCurrentComponentChanged: {
        currentIndex=getIndexByCom(currentComponent);
    }
}
