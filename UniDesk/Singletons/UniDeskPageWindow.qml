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
    //选中页面功能： 在上方插入，在下方插入，上移，下移，重命名，删除
    //组件功能（正常）：在元件上新建、删除、移动（移动中）：成为其子组件
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
                        font: UniDeskTextStyle.little
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
                        height: 20
                        anchors.verticalCenter: parent.verticalCenter
                        visible: dele.editing
                        onEditingFinished: {
                            dele.editing=false;
                            UniDeskComManager.rename_page(pageIdx,text)
                            option4_listView.model=UniDeskComManager.page_list;
                            rename_page_field.focus=true;
                        }
                    }
                    MouseArea{
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        anchors.fill: parent
                        hoverEnabled: true
                        visible: !dele.editing
                        onClicked: (mouse)=> {
                            window.currentIndex=index;
                            if(mouse.button==Qt.RightButton){
                                m_list.popup(dele,mouseX,mouseY)
                            }
                        }
                    }
                    UniDeskMenu{
                        id: m_list
                        UniDeskMenuItem{
                            text: qsTr("重命名")
                            disabled: index==0
                            onClicked: {
                                rename_page_field.pageIdx=index;
                                rename_page_field.text=model.text
                                dele.editing=true;
                            }
                        }
                        UniDeskMenuItem{
                            text: qsTr("在上方新建")
                            disabled: index==0
                            onClicked: {
                                
                            }
                        }
                        UniDeskMenuItem{
                            text: qsTr("在下方新建")
                            onClicked: {
                                
                            }
                        }
                        UniDeskMenuItem{
                            text: qsTr("上移")
                            disabled: index==0
                            onClicked: {
                                
                            }
                        }
                        UniDeskMenuItem{
                            text: qsTr("下移")
                            disabled: index==0
                            onClicked: {
                                
                            }
                        }
                        UniDeskMenuItem{
                            text: qsTr("删除")
                            disabled: index==0
                            onClicked: {
                                
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
                model: UniDeskComManager.treeModels[window.currentIndex]
            }
            border.width: 1
            border.color: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
            radius: 5
        }
        
    }
}