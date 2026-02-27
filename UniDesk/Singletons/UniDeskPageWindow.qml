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
    property int currentIndex: 0
    property bool isMove: false
    property int moveIndex
    property string moveComId
    property bool isMenuPopup: false
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
                model: UniDeskComManager.page_list
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                delegate: Rectangle{
                    property bool editing: false
                    id: dele
                    anchors.left: parent ? parent.left : undefined
                    anchors.right: parent ? parent.right : undefined
                    UniDeskText{
                        id: textt
                        text: model.text
                        visible: !dele.editing
                        font.family: UniDeskTextStyle.little.family
                        font.pixelSize: UniDeskTextStyle.little.pixelSize
                        font.bold: UniDeskComManager.pindex2pid(index)===UniDeskComManager.currentPid
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
                            UniDeskComManager.move_com_to_page(window.moveComId,index);
                            UniDeskComManager.toggle_page_to(UniDeskComManager.pindex2pid(index));
                            window.currentIndex=index;
                            liview.model=UniDeskComManager.compModels.get(UniDeskComManager.pid2pindex(window.currentIndex)).value;
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
                        property int pageid
                        anchors.fill: parent
                        anchors.margins: 5
                        visible: dele.editing
                        onEditingFinished: {
                            dele.editing=false;
                            UniDeskComManager.rename_page(pageid,text)
                            option4_listView.model=UniDeskComManager.page_list;
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
                                liview.model=UniDeskComManager.compModels.get(window.currentIndex).value
                            }
                            if(mouse.button===Qt.RightButton){
                                m_list.popup(dele,mouseX,mouseY)
                                isMenuPopup=true;
                            }
                        }
                    }
                    UniDeskMenu{
                        id: m_list
                        UniDeskMenuItem{
                            text: qsTr("重命名")
                            disabled: UniDeskComManager.pindex2pid(index)===0
                            onClicked: {
                                rename_page_field.pageid=index;
                                rename_page_field.text=model.text
                                dele.editing=true;
                            }
                        }
                        UniDeskMenuItem{
                            text: qsTr("在上方新建页面")
                            disabled: index==0
                            onClicked: {
                                UniDeskComManager.insert_new_page(index)
                            }
                        }
                        UniDeskMenuItem{
                            text: qsTr("在下方新建页面")
                            onClicked: {
                                if(index==UniDeskComManager.page_list.count-1){
                                    UniDeskComManager.new_page()
                                }
                                else{
                                    UniDeskComManager.insert_new_page(index+1)
                                }
                            }
                        }
                        UniDeskMenuItem{
                            text: qsTr("切换到此页")
                            onClicked: {
                                UniDeskComManager.toggle_page_to(UniDeskComManager.pindex2pid(index));
                                currentIndex=index;
                            }
                        }
                        UniDeskMenuItem{
                            text: qsTr("上移")
                            disabled: index==0 || index==1
                            onClicked: {
                                UniDeskComManager.move_page_up(index)
                            }
                        }
                        UniDeskMenuItem{
                            text: qsTr("下移")
                            disabled: index==0 || index==UniDeskComManager.page_list.count-1
                            onClicked: {
                                UniDeskComManager.move_page_down(index)
                            }
                        }
                        UniDeskMenuItem{
                            text: qsTr("删除")
                            disabled: index==0
                            onClicked: {
                                UniDeskComManager.remove_page(index)
                            }
                        }
                        onAboutToHide: {
                            isMenuPopup=false;
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
        Rectangle{
            anchors.left: listview_rect.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 10
            color: "transparent"
            ListView{
                id: liview
                anchors.fill: parent
                anchors.margins: 10
                model: UniDeskComManager.compModels.get(UniDeskComManager.pid2pindex(window.currentIndex)).value
                ScrollBar.vertical: ScrollBar {}
                spacing: 10
                delegate: Rectangle{
                    id: rect_
                    color:  "transparent"
                    radius: 5
                    border.width: 1
                    border.color: UniDeskGlobals.isLight? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
                    anchors.left: parent ? parent.left : undefined
                    anchors.right: parent ? parent.right : undefined
                    height: 30
                    UniDeskText{
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: model.display
                    }
                    HoverHandler{
                        onHoveredChanged: {
                            rect_.color=hovered? UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.05) : Qt.rgba(0,0,0,0.5).lighter(1.05)  : "transparent"   
                            
                            var com=UniDeskComManager.getComById(model.display)
                            if(com){
                                com.indicated=hovered;
                            }
                            
                        }
                    }
                    RowLayout{
                        property var model
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        UniDeskButton{
                            contentText: qsTr("添加组件")
                            iconSize: 15
                            iconSource: "qrc:/media/img/add-line.svg"
                            bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                            bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                            iconColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1).darker(1.5)
                            radius: width / 2
                            visible: UniDeskComManager.getComById(model.display)?UniDeskComManager.getComById(model.display).subComponentable:false
                            onClicked:{
                                UniDeskComWindow.parentId=model.display;
                                UniDeskComWindow.pageid=UniDeskComManager.getComById(model.display).pageid;
                                UniDeskComWindow.showActivate();
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
                                UniDeskComManager.getComById(model.display).deleteCom();
                                liview.model=UniDeskComManager.compModels.value(UniDeskComManager.pid2pindex(window.currentIndex)).value
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
                                window.moveComId=model.display
                                window.moveIndex=window.currentIndex
                                window.isMove=true;
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
