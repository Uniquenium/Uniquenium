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
    title: qsTr("选择控件（父控件：") + comManager.getComOrLayerName(comManager.parentOfNewCom) + qsTr("）")
    autoDestroy: false// keep the system appbar hidden (temporary solution)
    autoVisible: false
    property string pageid
    property var comManager
    ScrollView{
        id: scroll_view
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
            Flow{
                spacing: 10
                Layout.preferredWidth: scroll_view.width
                Repeater{
                    model: basicComponents
                    UniDeskButton{
                        display: Button.TextBesideIcon
                        contentText: modelData.name
                        iconSource: modelData.icon
                        iconColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
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
            UniDeskText{
                text: qsTr("模版")
                font: UniDeskTextStyle.small_
                visible: templeteRepeater.count > 0
            }
            Flow{
                spacing: 10
                Layout.preferredWidth: scroll_view.width
                visible: templeteRepeater.count > 0
                Repeater{
                    id: templeteRepeater
                    model: UniDeskTempleteMgr.templeteList
                    UniDeskButton{
                        display: Button.TextOnly
                        contentText: modelData.name ? modelData.name : ""
                        bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                        bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                        borderWidth: 1
                        radius: 5
                        onClicked: {
                            var presetWin = modelData.presetWindow ? modelData.presetWindow : "";
                            if(presetWin.length > 0){
                                var winPath = "file:/" + modelData.dir + "/" + presetWin;
                                var comp = Qt.createComponent(winPath);
                                if(comp.status === Component.Ready){
                                    var win = comp.createObject(window, {"templeteDir": modelData.dir, "comManager": comManager});
                                    win.showActivate();
                                    window.close();
                                } else {
                                    print("Failed to load presetWindow: " + comp.errorString());
                                    UniDeskTempleteMgr.loadTemplete(modelData.dir, ({}));
                                    window.close();
                                }
                            } else {
                                UniDeskTempleteMgr.loadTemplete(modelData.dir, ({}));
                                window.close();
                            }
                        }
                    }
                }
            }
            Repeater{
                model: UniDeskPluginMgr.plugins_list
                ColumnLayout{
                    spacing: 10
                    id: plugin_column
                    required property var modelData
                    UniDeskText{
                        id: com_name_text
                        text: qsTr(plugin_column.modelData.name)
                        font: UniDeskTextStyle.small_
                    }
                    Flow{
                        id: com_flow
                        spacing: 10
                        Layout.preferredWidth: scroll_view.width
                        Repeater{
                            model: plugin_column.modelData.components
                            UniDeskButton{
                                required property var modelData
                                display: Button.TextOnly
                                contentText: modelData.nameTr
                                // iconSource: modelData.icon
                                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                                borderWidth: 1
                                radius: 5
                                onClicked: {
                                    var comTypeId = plugin_column.modelData.author+"."+plugin_column.modelData.id+"."+modelData.name;
                                    comManager.add_com(comTypeId, modelData.nameTr, pageid);
                                    window.close();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 动态加载组件信息
    property list<var> basicComponents
    
    onVisibleChanged: {
        if(visible){
            basicComponents = UniDeskComponentsData.getBasicComponentTypes();
        }
    }
}
