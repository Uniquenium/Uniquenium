pragma Singleton
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

UniDeskWindow{
    id: window
    width: 1000
    height: 700
    title: qsTr("页面层级")
    autoDestroy: false// keep the system appbar hidden (temporary solution)
    autoVisible: false
    property int currentIndex: 0
    property int menuIndex: 0
    property bool isMove: false
    property int moveIndex
    property string moveComId
    property bool isMenuPopup: false
    property var comManager
    property var comWindow
    ScrollView{    
        anchors.fill: parent
        Rectangle {
            id: listview_rect
            clip: true
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 10
            color: "transparent"
            ListView{
                id: option4_listView
                model: window.comManager.page_list
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                delegate: Rectangle{
                    property alias renamePageField: rename_page_field
                    property bool editing: false
                    property string text: model.text
                    id: dele
                    anchors.left: parent ? parent.left : undefined
                    anchors.right: parent ? parent.right : undefined
                    UniDeskText{
                        id: textt
                        text: model.text
                        visible: !dele.editing
                        font.family: UniDeskTextStyle.little.family
                        font.pixelSize: UniDeskTextStyle.little.pixelSize
                        font.bold: comManager.pindex2pid(index)===comManager.currentPid   
                        anchors.verticalCenter: parent.verticalCenter
                        x: 10
                    }
                    UniDeskButton{
                        contentText: qsTr("移动到此页面")
                        iconSize: 15
                        anchors.right: parent.right
                        anchors.margins: 10
                        anchors.verticalCenter: parent.verticalCenter
                        iconSource: index==moveIndex ? "qrc:/media/img/close.svg" :"qrc:/media/img/move.svg"
                        bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                        bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                        iconColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1).darker(1.5)
                        radius: width / 2
                        visible: window.isMove
                        onClicked:{
                            window.isMove=false;
                            comManager.move_com_to_page(window.moveComId,index);
                            comManager.toggle_page_to(comManager.pindex2pid(index));
                            window.currentIndex=index;
                            liview.model=comManager.page_list.get(comManager.pid2pindex(window.currentIndex)).value;
                        }
                    }
                    Component.onCompleted: {
                        implicitHeight = textt.height+25;
                    }
                    border.width: 1
                    border.color: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
                    radius: 5
                    color: index==window.currentIndex ? UniDeskSettings.primaryColor : "transparent"
                    UniDeskTextField{
                        id: rename_page_field
                        property string pageid
                        anchors.fill: parent
                        anchors.margins: 5
                        visible: dele.editing
                        onEditingFinished: {
                            dele.editing=false;
                            comManager.rename_page(pageid,text)
                            option4_listView.model=comManager.page_list;
                        }
                    }
                    MouseArea{
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        anchors.fill: parent
                        hoverEnabled: true
                        visible: (!dele.editing)&&(!window.isMove)
                        onClicked: (mouse)=> {
                            if(mouse.button===Qt.LeftButton&&(!isMenuPopup)){
                                window.currentIndex=index;
                                liview.model=comManager.page_list.get(window.currentIndex).value
                            }
                            if(mouse.button===Qt.RightButton){
                                window.menuIndex=index;
                                m_list.popup(dele,mouseX,mouseY)
                                isMenuPopup=true;
                            }
                        }
                    }
                }
                ScrollBar.vertical: ScrollBar {}
            }
            width: 200
            border.width: 1
            border.color: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
            radius: 5
        }
        //place the menu out: the delete menuitem will delete the menu itself
        UniDeskMenu{
            id: m_list
            UniDeskMenuItem{
                id: rename_page_item
                text: qsTr("重命名")
                disabled: window.menuIndex==0
                onClicked: {
                    option4_listView.itemAtIndex(window.menuIndex).renamePageField.pageid=window.menuIndex;
                    option4_listView.itemAtIndex(window.menuIndex).renamePageField.text=option4_listView.itemAtIndex(window.menuIndex).text
                    option4_listView.itemAtIndex(window.menuIndex).editing=true;
                }
            }
            UniDeskMenuItem{
                id: insert_page_item1
                text: qsTr("在上方新建页面")
                disabled: window.menuIndex==0
                onClicked: {
                    comManager.insert_new_page(window.menuIndex)
                }
            }
            UniDeskMenuItem{
                id: insert_page_item2
                text: qsTr("在下方新建页面")
                onClicked: {
                    if(window.menuIndex==comManager.page_list.count-1){
                        comManager.new_page()
                    }
                    else{
                        comManager.insert_new_page(window.menuIndex+1)
                    }
                }
            }
            UniDeskMenuItem{
                id: switch_page_item
                text: qsTr("切换到此页")
                onClicked: {
                    comManager.toggle_page_to(comManager.pindex2pid(window.menuIndex));
                    window.currentIndex=window.menuIndex;
                }
            }
            UniDeskMenuItem{
                id: move_page_up_item
                text: qsTr("上移")
                disabled: window.menuIndex==0 || window.menuIndex==1
                onClicked: {
                    comManager.move_page_up(window.menuIndex)
                }
            }
            UniDeskMenuItem{
                id: move_page_down_item
                text: qsTr("下移")
                disabled: window.menuIndex==0 || window.menuIndex==comManager.page_list.count-1
                onClicked: {
                    comManager.move_page_down(window.menuIndex)
                }
            }
            UniDeskMenuItem{
                id: copy_page_item
                text: qsTr("复制")
                onClicked: {
                    comManager.copy_page(window.menuIndex)
                }
            }
            UniDeskMenuItem{
                id: clear_page_item
                text: qsTr("清空")
                textColor: Qt.rgba(1,0,0,1)
                disabled: comManager.page_list.get(window.menuIndex) ? comManager.page_list.get(window.menuIndex).value.count===0 : false
                onClicked: {
                    comManager.clear_page(window.menuIndex)
                    liview.model=comManager.page_list.get(window.currentIndex).value
                }
            }
            UniDeskMenuItem{
                id: delete_page_item
                text: qsTr("删除")
                textColor: Qt.rgba(1,0,0,1)
                disabled: window.menuIndex==0 || comManager.page_list.get(window.menuIndex).value.count>0
                onClicked: {
                    // 调整currentIndex到安全范围
                    if(window.currentIndex == window.menuIndex){
                        window.currentIndex = 0
                    }
                    // 更新右侧列表的model
                    liview.model = comManager.page_list.get(window.currentIndex).value;
                    comManager.remove_page(window.menuIndex)
                    clear_page_item.disabled=comManager.page_list.get(window.menuIndex) ? comManager.page_list.get(window.menuIndex).value.count===0 : false
                    delete_page_item.disabled=window.menuIndex==0 || comManager.page_list.get(window.menuIndex).value.count>0
                }
            }
            onAboutToHide: {
                window.isMenuPopup=false;
            }
        }
        Rectangle{
            anchors.left: listview_rect.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 10
            color: "transparent"
            clip: true
            TreeView{
                id: liview
                anchors.fill: parent
                anchors.margins: 10
                model: comManager.page_list.get(comManager.pid2pindex(window.currentIndex)).value
                ScrollBar.vertical: ScrollBar {}
                rowSpacing: 10
                delegate: TreeViewDelegate{
                    id: tvitem
                    implicitWidth: childrenRect.width
                    implicitHeight: childrenRect.height
                    
                    Rectangle{
                        id: rect_
                        radius: 5
                        border.width: 1
                        border.color: UniDeskGlobals.isLight? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
                        anchors.fill: parent
                        color: {
                            if(hover_handler.hovered){
                                return UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).lighter(1.2) : Qt.rgba(0,0,0,0.5).darker(1.2)
                            }
                            return "transparent"
                        }
                    }
                    // required property TreeView treeView
                    // required property bool isTreeNode
                    // required property bool expanded
                    // required property bool hasChildren
                    // required property int depth
                    // required property int row
                    // required property int column
                    // required property bool current
                    indentation: 10
                    TapHandler{
                        id: tap_handler
                        onTapped: {
                            if(tvitem.hasChildren){
                                tvitem.treeView.toggleExpanded(tvitem.row)
                            }
                        }
                    }
                    
                    HoverHandler{
                        id: hover_handler
                        onHoveredChanged: {
                            var com=comManager.getComById(model.identification)
                            if(com){
                                com.indicated=hovered;
                            }
                        }
                    }
                    RowLayout{
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        UniDeskIcon{
                            iconSource: tvitem.hasChildren ? 
                            (tvitem.expanded ? "qrc:/media/img/arrow-down-s-line.svg" : "qrc:/media/img/arrow-right-s-line.svg") : "qrc:/media/img/calculator-line.svg"
                            iconSize: 15
                            Layout.preferredWidth: 15
                            Layout.preferredHeight: 15
                            Layout.leftMargin: 10
                        }
                        UniDeskText{
                            Layout.alignment: Qt.AlignVCenter
                            text: comManager.getComById(model.identification) ? comManager.getComById(model.identification).name : ""
                        }
                        RowLayout{
                            property var model
                            Layout.rightMargin: 0
                            Layout.alignment: Qt.AlignVCenter
                            UniDeskButton{
                                contentText: qsTr("添加组件")
                                iconSize: 15
                                iconSource: "qrc:/media/img/add-line.svg"
                                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                                iconColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1).darker(1.5)
                                radius: width / 2
                                onClicked:{
                                    comManager.parentOfNewCom=comManager.getComById(model.identification);
                                    comWindow.pageid=comManager.getComById(model.identification).pageid;
                                    comWindow.show();
                                }
                            }
                            UniDeskButton{
                                contentText: qsTr("编辑")
                                iconSize: 15
                                iconSource: "qrc:/media/img/edit.svg"
                                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                                iconColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1).darker(1.5)
                                radius: width / 2
                                onClicked:{
                                    comManager.toggle_page_to(comManager.pindex2pid(window.currentIndex))
                                    comManager.getComById(model.identification).optionsWindow.show();
                                }
                            }
                            UniDeskButton{
                                contentText: qsTr("复制")
                                iconSize: 15
                                iconSource: "qrc:/media/img/copy.svg"
                                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                                iconColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1).darker(1.5)
                                radius: width / 2
                                onClicked:{
                                    var newCom = comManager.getComById(model.identification).copyCom();
                                    liview.model = comManager.page_list.get(comManager.pid2pindex(window.currentIndex)).value;
                                }
                            }
                            UniDeskButton{
                                contentText: qsTr("删除")
                                iconSize: 15
                                iconSource: "qrc:/media/img/delete-bin.svg"
                                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                                iconColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1).darker(1.5)
                                radius: width / 2
                                onClicked:{
                                    comManager.getComById(model.identification).deleteCom();
                                    liview.model=comManager.page_list.get(comManager.pid2pindex(window.currentIndex)).value
                                }
                            }
                            UniDeskButton{
                                contentText: qsTr("移动到页面")
                                iconSize: 15
                                iconSource: "qrc:/media/img/move.svg"
                                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                                iconColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1).darker(1.5)
                                radius: width / 2
                                onClicked:{
                                    window.moveComId=model.identification
                                    window.moveIndex=window.currentIndex
                                    window.isMove=true;
                                }
                            }
                        }
                    }
                }
            }
            border.width: 1
            border.color: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
            radius: 5
        }
        
    }
}
