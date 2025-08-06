import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects
import UniDesk.Controls
import UniDesk.Singletons
import UniDesk.PyPlugin

UniDeskComboBox{
    id: control
    property UniDeskComBase editingComponent
    model: getIds(componentList);
    property list<UniDeskComBase> componentList: UniDeskComManager.component_list
    editable: true
    width: 300
    function getIds(list){
        var ids = [qsTr("桌面")];
        for(var i=0;i<list.length;i++){
            if(list[i]!==editingComponent){  
                ids.push(list[i].identification);
            }
        }
        return ids;
    }
}