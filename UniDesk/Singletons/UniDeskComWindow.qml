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
    width: 500
    height: 350
    title: qsTr("选择控件")
    autoDestroy: false// keep the system appbar hidden (temporary solution)
    autoVisible: false
    property string parentId
    property int pageid
    property var comManager
    ScrollView{
        anchors.fill: parent
        anchors.margins: 10
        ColumnLayout{
            spacing: 10
            anchors.fill: parent
            // 基础控件部分
            UniDeskText{
                text: qsTr("基本控件")
                font: UniDeskTextStyle.small_
            }
            RowLayout{
                spacing: 10
                Repeater{
                    model: basicComponents
                    UniDeskButton{
                        display: Button.TextBesideIcon
                        contentText: modelData.name
                        iconSource: modelData.icon
                        bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                        bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                        borderWidth: 1
                        radius: 5
                        onClicked: {
                            comManager.add_com(modelData.filename, modelData.name, pageid);
                            window.close();
                        }
                    }
                }
            }
            // 高级控件部分
            UniDeskText{
                text: qsTr("高级控件")
                font: UniDeskTextStyle.small_
                visible: extraComponents.length > 0
            }
            RowLayout{
                spacing: 10
                visible: extraComponents.length > 0
                Repeater{
                    model: extraComponents
                    UniDeskButton{
                        display: Button.TextBesideIcon
                        contentText: modelData.name
                        iconSource: modelData.icon
                        bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                        bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                        borderWidth: 1
                        radius: 5
                        onClicked: {
                            window.close();
                        }
                    }
                }
            }
        }
    }
    
    // 动态加载组件信息
    property list<var> basicComponents
    property list<var> extraComponents
    
    onVisibleChanged: {
        if(visible){
            basicComponents = UniDeskComponentsData.getBasicComponentTypes();
            extraComponents = UniDeskComponentsData.getExtraComponentTypes();
        }
    }
}
