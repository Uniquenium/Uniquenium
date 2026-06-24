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
    enableComDelegate: true
    model: getIds(componentList);
    property list<var> componentList: comManager ? comManager.component_list : []
    editable: true
    width: 300
    function getIds(list){
        var ids = [qsTr("桌面")];
        for(var i=0;i<list.length;i++){
            if(list[i]&&(list[i]!==editingComponent)){
                ids.push(list[i].identification);
            }
        }
        return ids;
    }
}
