pragma Singleton
import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects
import UniDesk.Controls
import UniDesk.PyPlugin

UniDeskWindow{
    id: window
    width: 1000
    height: 700
    title: qsTr("页面层级")
    property int currentIndex: 0
    ScrollView{    
        anchors.fill: parent
        Rectangle {
            id: listview_rect
            clip: true
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 10
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
                        font.bold: UniDeskComManager.getPageIdx(index)==UniDeskComManager.pageIndex
                        anchors.verticalCenter: parent.verticalCenter
                        x: 10
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
                        property int pageIdx
                        anchors.fill: parent
                        anchors.margins: 5
                        visible: dele.editing
                        onEditingFinished: {
                            dele.editing=false;
                            UniDeskComManager.rename_page(pageIdx,text)
                            option4_listView.model=UniDeskComManager.page_list;
                        }
                    }
                    MouseArea{
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        anchors.fill: parent
                        hoverEnabled: true
                        visible: !dele.editing
                        onClicked: (mouse)=> {
                            if(mouse.button==Qt.LeftButton){
                                window.currentIndex=index;
                            }
                            if(mouse.button==Qt.RightButton){
                                m_list.popup(dele,mouseX,mouseY)
                            }
                        }
                    }
                    UniDeskMenu{
                        id: m_list
                        UniDeskMenuItem{
                            text: qsTr("重命名")
                            disabled: UniDeskComManager.getPageIdx(index)==0
                            onClicked: {
                                rename_page_field.pageIdx=index;
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
                                UniDeskComManager.toggle_page_to(UniDeskComManager.getPageIdx(index));
                            }
                        }
                        UniDeskMenuItem{
                            text: qsTr("上移")
                            disabled: index==0 || index==1
                            onClicked: {
                                UniDeskComManager.moveUp(index)
                            }
                        }
                        UniDeskMenuItem{
                            text: qsTr("下移")
                            disabled: index==0 || index==UniDeskComManager.page_list.count-1
                            onClicked: {
                                UniDeskComManager.moveDown(index)
                            }
                        }
                        UniDeskMenuItem{
                            text: qsTr("删除")
                            disabled: index==0
                            onClicked: {
                                UniDeskComManager.remove_page(index)
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
        Rectangle{
            anchors.left: listview_rect.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 10
            UniDeskTreeView{
                anchors.fill: parent
                anchors.margins: 10
                enableComDelegate: true
                model: UniDeskComManager.treeModels[UniDeskComManager.pageIdxConvert(window.currentIndex)]
                extraDelegate: Component{
                    RowLayout{
                        property var model
                        spacing: 10
                        UniDeskButton{
                            contentText: qsTr("添加组件")
                            iconSize: 15
                            iconSource: "qrc:/media/img/add-line.svg"
                            bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                            bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                            iconColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1).darker(1.5)
                            radius: width / 2
                            onClicked:{
                                UniDeskComWindow.parentId=model.display;
                                UniDeskComWindow.pageIdx=UniDeskComManager.getComById(model.display).pageIdx;
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