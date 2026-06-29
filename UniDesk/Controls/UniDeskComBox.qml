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
    currentIndex: (currentComponent && currentComponent!==comManager.root.contentItem) ? 
            model.indexOf(currentComponent.name) : 0
    property bool allPages: false
    enableComDelegate: true
    model: getNames(comManager ? comManager.component_list : []);
    editable: true
    width: 300
    function getNames(list){
        var names = [qsTr("桌面")];
        for(var i=0;i<list.length;i++){
            if(list[i]&&(list[i]!==editingComponent)&&(allPages||list[i].pageid===editingComponent.pageid)){
                names.push(list[i].name);
            }
        }
        return names;
    }
    function getComByIndex(index){
        var coms = [comManager.root.contentItem];
        for(var i=0;i<comManager.component_list.length;i++){
            if(comManager.component_list[i]&&(comManager.component_list[i]!==editingComponent)&&(allPages||comManager.component_list[i].pageid===editingComponent.pageid)){
                coms.push(comManager.component_list[i]);
            }
        }
        return coms[index];
    }
}
