import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQml
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects
import UniDesk.Controls
import UniDesk.Singletons
import UniDesk

Item{
    property var comManager
    property var customWallpaper
    Rectangle{
        id: backgroundRect
        color: "transparent"
        anchors.top: parent.top
        anchors.bottom: pluginsText.top
        anchors.left: parent.left
        anchors.right: parent.right
        radius: 5
        border.width: 1
        border.color: UniDeskGlobals.isLight? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
        anchors.margins: 10
        clip: true
        ListView{
            id: pluginsView
            model: UniDeskPluginMgr.plugins_list
            anchors.fill: parent
            ScrollBar.vertical: ScrollBar {}
            anchors.margins: 10
            spacing: 10
            delegate: Rectangle{
                id: rect_
                color:  "transparent"
                radius: 5
                border.width: 1
                border.color: UniDeskGlobals.isLight? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
                anchors.left: parent ? parent.left : undefined
                anchors.right: parent ? parent.right : undefined
                height: 50
                UniDeskText{
                    id: info_text
                    anchors.fill: parent
                    anchors.margins: 10
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    text: modelData.name + "[v" + modelData.version + "]:" + modelData.description
                }
                RowLayout{
                    property var model
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    UniDeskButton{
                        contentText: qsTr("打开文件夹")
                        iconSize: 15
                        iconSource: "qrc:/media/img/open-folder.svg"
                        bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                        bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                        iconColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1).darker(1.5)
                        radius: width / 2
                        onClicked:{
                            UniDeskTools.openFileOrDir(modelData.dirpath);
                        }
                    }
                }
                HoverHandler{
                    onHoveredChanged: {
                        rect_.color=hovered? UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.05) : Qt.rgba(0,0,0,0.5).lighter(1.05)  : "transparent"    
                    }
                }
            }
        }
    }
    UniDeskText{
        id: pluginsText
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 10
        text: qsTr("已加载")+" "+ UniDeskPluginMgr.plugins_list.length + " " + qsTr("个插件")
    }
}
